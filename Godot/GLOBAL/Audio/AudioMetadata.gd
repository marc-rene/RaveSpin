class_name AudioMetadata
extends RefCounted

## Extracts metadata from audio files (MP3 ID3v2, and fallbacks for WAV/OGG).
## Use extract_from_path() to get a dictionary of title, artist, album, bpm, etc.

const USER_IMPORTS_DIR := "user://ImportedSongs"

## Keys: title, artist, album, album_artist, composer, comment, genre, year, bpm, duration_seconds
static func extract_from_path(path: String) -> Dictionary:
    var result := {
        "title": "",
        "artist": "",
        "album": "",
        "album_artist": "",
        "composer": "",
        "comment": "",
        "genre": "",
        "year": "",
        "bpm": 0.0,
        "duration_seconds": 0.0,
    }
    var ext := path.get_extension().to_lower()
    if ext == "mp3":
        _extract_id3v2(path, result)
    elif ext == "ogg":
        _extract_ogg(path, result)
    else:
        # WAV or unknown: no standard tags, use filename as title
        result["title"] = path.get_file().get_basename()
    # Duration: load stream and get_length() if we have a loader
    var stream := _load_stream_from_path(path)
    if stream:
        result["duration_seconds"] = stream.get_length()
    return result

static func _extract_id3v2(path: String, result: Dictionary) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        result["title"] = path.get_file().get_basename()
        return
    var header := file.get_buffer(10)
    if header.size() < 10:
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    if header[0] != 0x49 or header[1] != 0x44 or header[2] != 0x33: # "ID3"
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    var tag_size := _synchsafe_to_int(header[6], header[7], header[8], header[9])
    if tag_size <= 0:
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    var tag_data := file.get_buffer(mini(tag_size, 256 * 1024)) # cap 256KB of tags
    file.close()
    # Frame ID -> key in result (and optional parser)
    var text_frames := {
        "TIT2": "title",
        "TPE1": "artist",
        "TALB": "album",
        "TPE2": "album_artist",
        "TCOM": "composer",
        "COMM": "comment",
        "TCON": "genre",
        "TYER": "year",
        "TDRC": "year",
        "TBPM": "bpm",
    }
    var pos := 0
    while pos + 10 <= tag_data.size():
        var frame_id := tag_data.slice(pos, pos + 4).get_string_from_ascii()
        var frame_size := _synchsafe_to_int(tag_data[pos+4], tag_data[pos+5], tag_data[pos+6], tag_data[pos+7])
        pos += 10
        if frame_size <= 0 or pos + frame_size > tag_data.size():
            break
        var payload := tag_data.slice(pos, pos + frame_size)
        pos += frame_size
        if frame_id == "TBPM":
            var s := _read_id3_text(payload)
            result["bpm"] = _parse_float(s)
            continue
        if frame_id == "COMM":
            # COMM: encoding(1) + lang(3) + short_desc (null-term) + null + comment
            if payload.size() > 5:
                var enc := payload[0]
                var payload_pos := 4  # after encoding + lang
                while payload_pos < payload.size() and payload[payload_pos] != 0:
                    payload_pos += 1
                payload_pos += 1  # skip null
                if payload_pos < payload.size():
                    var comment_payload := PackedByteArray()
                    comment_payload.append(enc)
                    comment_payload.append_array(payload.slice(payload_pos, payload.size()))
                    result["comment"] = _read_id3_text(comment_payload)
            continue
        if text_frames.has(frame_id):
            var key: String = text_frames[frame_id]
            var value := _read_id3_text(payload)
            if key == "year" and result["year"].is_empty():
                result["year"] = value
            elif key != "year":
                result[key] = value
    if result["title"].is_empty():
        result["title"] = path.get_file().get_basename()

static func _read_id3_text(payload: PackedByteArray) -> String:
    if payload.size() == 0:
        return ""
    var encoding := payload[0]
    var data := payload.slice(1, payload.size())
    if encoding == 0: # ISO-8859-1
        return data.get_string_from_ascii()
    if encoding == 1 or encoding == 2: # UTF-16 with BOM, or UTF-16BE
        return data.get_string_from_utf16()
    return data.get_string_from_utf8()

static func _synchsafe_to_int(a: int, b: int, c: int, d: int) -> int:
    return (a & 0x7f) << 21 | (b & 0x7f) << 14 | (c & 0x7f) << 7 | (d & 0x7f)

static func _parse_float(s: String) -> float:
    var stripped := s.strip_edges()
    if stripped.is_valid_float():
        return stripped.to_float()
    return 0.0

static func _extract_ogg(path: String, result: Dictionary) -> void:
    # OGG Vorbis comments are in the first page; Godot doesn't expose them in 4.4.
    # We could parse OGG pages and "vorbis" comment packet, but keep it simple:
    result["title"] = path.get_file().get_basename()

static func _load_stream_from_path(path: String) -> AudioStream:
    var ext := path.get_extension().to_lower()
    if ext == "mp3":
        return AudioStreamMP3.load_from_file(path)
    if ext == "wav":
        var file := FileAccess.open(path, FileAccess.READ)
        if not file:
            return null
        var wav := AudioStreamWAV.new()
        wav.data = file.get_buffer(file.get_length())
        file.close()
        return wav
    if ext == "ogg":
        var file := FileAccess.open(path, FileAccess.READ)
        if not file:
            return null
        var ogg := AudioStreamOggVorbis.new()
        ogg.data = file.get_buffer(file.get_length())
        file.close()
        return ogg
    return null

## Copies a file to user://ImportedSongs/ and returns the new path (for persistence).
static func copy_to_user_imports(source_path: String) -> String:
    DirAccess.make_dir_recursive_absolute(USER_IMPORTS_DIR)
    var base_name := source_path.get_file()
    # Avoid overwriting: append number if exists
    var dest_path := USER_IMPORTS_DIR.path_join(base_name)
    var counter := 0
    while FileAccess.file_exists(dest_path):
        counter += 1
        var name_no_ext := base_name.get_basename()
        var ext := base_name.get_extension()
        dest_path = USER_IMPORTS_DIR.path_join("%s_%d.%s" % [name_no_ext, counter, ext])
    DirAccess.copy_absolute(source_path, dest_path)
    return dest_path
