class_name AudioMetadata
extends RefCounted

## Unified metadata extraction: [MusicMetadata] addon first, then hand-written parsers as backup.
## Does not use WaveformGenerator (waveforms are generated separately via WaveformGenerator.generate).

const USER_IMPORTS_DIR: String = "user://Music"
## Internal key: [MusicMetadata] instance for album art; stripped before persisting.
const PLUGIN_METADATA_KEY: StringName = &"_plugin_music_metadata"

## Keys: title, artist, album, album_artist, composer, comment, genre, genres, year, bpm,
## duration_seconds, musicbrainz_id, initial_key, plus PLUGIN_METADATA_KEY (MusicMetadata).
static func extract_from_path(path: String) -> Dictionary:
    var result: Dictionary = _empty_result()
    var music_meta: MusicMetadata = _build_music_metadata(path)
    _apply_music_metadata_plugin(music_meta, result)
    _backup_fill_from_legacy_parsers(path, result, music_meta)
    _finalize_genres_array(result)
    var stream_duration: AudioStream = _load_stream_from_path(path)
    if stream_duration != null:
        var length_seconds: float = stream_duration.get_length()
        if length_seconds > 0.0 and length_seconds < INF:
            if float(result["duration_seconds"]) <= 0.0:
                result["duration_seconds"] = length_seconds
    result[PLUGIN_METADATA_KEY] = music_meta
    return result


## Removes and returns the embedded [MusicMetadata] from a dict returned by [method extract_from_path].
static func take_plugin_metadata(result: Dictionary) -> MusicMetadata:
    var embedded: Variant = result.get(PLUGIN_METADATA_KEY, null)
    result.erase(PLUGIN_METADATA_KEY)
    if embedded is MusicMetadata:
        return embedded as MusicMetadata
    return null


static func _empty_result() -> Dictionary:
    return {
        "title": "",
        "artist": "",
        "album": "",
        "album_artist": "",
        "comment": "",
        "genre": "",
        "genres": PackedStringArray(),
        "year": "",
        "bpm": 0.0,
        "duration_seconds": 0.0,
        "musicbrainz_id": "",
        "initial_key": "",
    }


static func _build_music_metadata(path: String) -> MusicMetadata:
    var music_meta: MusicMetadata = MusicMetadata.new()
    var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
    if not file_bytes.is_empty():
        var parse_err: int = music_meta.update_from_bytes(file_bytes)
        if parse_err != OK:
            var loaded_stream: AudioStream = _load_stream_from_path(path)
            if loaded_stream != null:
                music_meta.update_from_stream(loaded_stream)
    return music_meta


static func _apply_music_metadata_plugin(music_meta: MusicMetadata, result: Dictionary) -> void:
    if String(music_meta.title).strip_edges() != "":
        result["title"] = music_meta.title
    if String(music_meta.artist).strip_edges() != "":
        result["artist"] = music_meta.artist
    if String(music_meta.album_artist).strip_edges() != "":
        result["album_artist"] = music_meta.album_artist
    if String(music_meta.album).strip_edges() != "":
        result["album"] = music_meta.album
    if String(music_meta.comments).strip_edges() != "":
        result["comment"] = music_meta.comments
    var tag_comment: Variant = music_meta.get_tag("comment", "")
    if String(tag_comment).strip_edges() != "" and String(result["comment"]).strip_edges() == "":
        result["comment"] = String(tag_comment)
    if int(music_meta.bpm) > 0:
        result["bpm"] = float(music_meta.bpm)
    if int(music_meta.year) > 0:
        result["year"] = str(music_meta.year)
    if String(music_meta.genre).strip_edges() != "":
        result["genre"] = music_meta.genre
    var tag_key: Variant = music_meta.get_tag("initial_key", "")
    if String(tag_key).strip_edges() != "":
        result["initial_key"] = String(tag_key)
    var tag_key2: Variant = music_meta.get_tag("initialkey", "")
    if String(result["initial_key"]).strip_edges() == "" and String(tag_key2).strip_edges() != "":
        result["initial_key"] = String(tag_key2)
    _apply_musicbrainz_from_plugin(music_meta, result)


static func _apply_musicbrainz_from_plugin(music_meta: MusicMetadata, result: Dictionary) -> void:
    var urls: Dictionary = music_meta.urls
    for url_key in urls.keys():
        var key_upper: String = String(url_key).to_upper()
        if key_upper.contains("MUSICBRAINZ") or key_upper.contains("MBID") or key_upper.contains("MUSICBRAINZ_TRACKID"):
            var url_value: String = String(urls[url_key]).strip_edges()
            if url_value != "":
                result["musicbrainz_id"] = url_value
                return
    var mb_tag: Variant = music_meta.get_tag("musicbrainz_trackid", "")
    if String(mb_tag).strip_edges() != "":
        result["musicbrainz_id"] = String(mb_tag).strip_edges()


static func _backup_fill_from_legacy_parsers(path: String, result: Dictionary, _music_meta: MusicMetadata) -> void:
    var ext: String = path.get_extension().to_lower()
    var backup: Dictionary = _empty_result()
    if ext == "mp3":
        _extract_id3v2(path, backup)
    elif ext == "ogg":
        _extract_ogg_vorbis(path, backup)
    elif ext == "wav":
        _extract_wav_info(path, backup)
    else:
        backup["title"] = path.get_file().get_basename()

    _merge_backup_if_empty(result, backup)


static func _merge_backup_if_empty(primary: Dictionary, backup: Dictionary) -> void:
    var keys: Array[String] = [
        "title", "artist", "album", "album_artist", "comment", "genre", "year",
        "initial_key", "musicbrainz_id",
    ]
    for key_index: int in range(keys.size()):
        var key_name: String = keys[key_index]
        
        if String(primary.get(key_name, "")).strip_edges() == "" and String(backup.get(key_name, "")).strip_edges() != "":
            primary[key_name] = backup[key_name]
    if float(primary["bpm"]) <= 0.0 and float(backup["bpm"]) > 0.0:
        primary["bpm"] = backup["bpm"]
    if float(primary["duration_seconds"]) <= 0.0 and float(backup["duration_seconds"]) > 0.0:
        primary["duration_seconds"] = backup["duration_seconds"]


static func _finalize_genres_array(result: Dictionary) -> void:
    var packed: PackedStringArray = PackedStringArray()
    _append_genre_tokens(packed, String(result["genre"]))
    if packed.is_empty() and String(result["genre"]).strip_edges() != "":
        _append_genre_tokens(packed, String(result["genre"]))
    result["genres"] = packed


static func _append_genre_tokens(target: PackedStringArray, raw_genre: String) -> void:
    var trimmed: String = raw_genre.strip_edges()
    if trimmed.is_empty():
        return
    var normalized: String = trimmed.replace("|", ";")
    var pieces: PackedStringArray = normalized.split(";", false)
    for piece_index: int in range(pieces.size()):
        var segment: String = pieces[piece_index].strip_edges()
        if segment.is_empty():
            continue
        var subparts: PackedStringArray = segment.split("/", false)
        for sub_index: int in range(subparts.size()):
            var label: String = subparts[sub_index].strip_edges()
            if label.is_empty():
                continue
            if not _packed_string_array_contains_ci(target, label):
                target.append(label)


static func _packed_string_array_contains_ci(haystack: PackedStringArray, needle: String) -> bool:
    var needle_upper: String = needle.to_upper()
    for stack_index: int in range(haystack.size()):
        if haystack[stack_index].to_upper() == needle_upper:
            return true
    return false


static func _extract_id3v2(path: String, result: Dictionary) -> void:
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        result["title"] = path.get_file().get_basename()
        return
    var header: PackedByteArray = file.get_buffer(10)
    if header.size() < 10:
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    if header[0] != 0x49 or header[1] != 0x44 or header[2] != 0x33:
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    var tag_size: int = _synchsafe_to_int(header[6], header[7], header[8], header[9])
    if tag_size <= 0:
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    var tag_data: PackedByteArray = file.get_buffer(mini(tag_size, 256 * 1024))
    file.close()

    var text_frames: Dictionary = {
        "TIT2": "title",
        "TPE1": "artist",
        "TALB": "album",
        "TPE2": "album_artist",
        "TCOM": "composer",
        "TCON": "genre",
        "TYER": "year",
        "TDRC": "year",
        "TBPM": "bpm",
        "TKEY": "initial_key",
    }
    var pos: int = 0
    while pos + 10 <= tag_data.size():
        var frame_id: String = tag_data.slice(pos, pos + 4).get_string_from_ascii()
        var frame_size: int = _synchsafe_to_int(tag_data[pos + 4], tag_data[pos + 5], tag_data[pos + 6], tag_data[pos + 7])
        pos += 10
        if frame_size <= 0 or pos + frame_size > tag_data.size():
            break
        var payload: PackedByteArray = tag_data.slice(pos, pos + frame_size)
        pos += frame_size
        if frame_id == "TBPM":
            var bpm_str: String = _read_id3_text(payload)
            result["bpm"] = _parse_float(bpm_str)
            continue
        if frame_id == "COMM":
            if payload.size() > 5:
                var enc: int = payload[0]
                var payload_pos: int = 4
                while payload_pos < payload.size() and payload[payload_pos] != 0:
                    payload_pos += 1
                payload_pos += 1
                if payload_pos < payload.size():
                    var comment_payload: PackedByteArray = PackedByteArray()
                    comment_payload.append(enc)
                    comment_payload.append_array(payload.slice(payload_pos, payload.size()))
                    result["comment"] = _read_id3_text(comment_payload)
            continue
        if text_frames.has(frame_id):
            var map_key: String = text_frames[frame_id]
            var value: String = _read_id3_text(payload)
            if map_key == "year" and String(result["year"]).is_empty():
                result["year"] = value
            elif map_key == "bpm":
                result["bpm"] = _parse_float(value)
            elif map_key != "year":
                result[map_key] = value
    if String(result["title"]).is_empty():
        result["title"] = path.get_file().get_basename()


static func _extract_ogg_vorbis(path: String, result: Dictionary) -> void:
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        result["title"] = path.get_file().get_basename()
        return
    var data: PackedByteArray = file.get_buffer(file.get_length())
    file.close()
    if data.is_empty():
        result["title"] = path.get_file().get_basename()
        return
    var search_start: int = 0
    while search_start < data.size() - 20:
        var idx: int = data.find(0x03, search_start)
        if idx < 0:
            break
        if idx + 7 > data.size():
            break
        var vorbis_magic: String = data.slice(idx + 1, idx + 7).get_string_from_ascii()
        if vorbis_magic == "vorbis":
            if _try_parse_vorbis_comment_packet(data, idx, result):
                break
        search_start = idx + 1
    if String(result["title"]).is_empty():
        result["title"] = path.get_file().get_basename()


static func _try_parse_vorbis_comment_packet(data: PackedByteArray, offset: int, result: Dictionary) -> bool:
    if offset + 11 > data.size():
        return false
    if data[offset] != 0x03:
        return false
    if data.slice(offset + 1, offset + 7).get_string_from_ascii() != "vorbis":
        return false
    var pos: int = offset + 7
    if pos + 4 > data.size():
        return false
    var vendor_len: int = data.decode_u32(pos)
    if vendor_len < 0 or vendor_len > 65536:
        return false
    pos += 4 + vendor_len
    if pos + 4 > data.size():
        return false
    var comment_count: int = data.decode_u32(pos)
    if comment_count < 0 or comment_count > 4096:
        return false
    pos += 4
    for comment_index: int in range(comment_count):
        if pos + 4 > data.size():
            break
        var comment_len: int = data.decode_u32(pos)
        pos += 4
        if comment_len < 0 or pos + comment_len > data.size():
            break
        var line: String = data.slice(pos, pos + comment_len).get_string_from_utf8()
        pos += comment_len
        var eq: int = line.find("=")
        if eq <= 0:
            continue
        var label: String = line.substr(0, eq).strip_edges().to_upper()
        var value: String = line.substr(eq + 1).strip_edges()
        match label:
            "TITLE":
                if String(result["title"]).is_empty():
                    result["title"] = value
            "ARTIST":
                if String(result["artist"]).is_empty():
                    result["artist"] = value
            "ALBUM":
                if String(result["album"]).is_empty():
                    result["album"] = value
            "ALBUMARTIST":
                if String(result["album_artist"]).is_empty():
                    result["album_artist"] = value
            "GENRE":
                if String(result["genre"]).is_empty():
                    result["genre"] = value
            "COMMENT":
                if String(result["comment"]).is_empty():
                    result["comment"] = value
            "DESCRIPTION":
                if String(result["comment"]).is_empty():
                    result["comment"] = value
            "BPM":
                if float(result["bpm"]) <= 0.0:
                    result["bpm"] = _parse_float(value)
            "TBPM":
                if float(result["bpm"]) <= 0.0:
                    result["bpm"] = _parse_float(value)
            "DATE":
                if String(result["year"]).is_empty():
                    result["year"] = value
            "INITIALKEY", "KEY":
                if String(result["initial_key"]).is_empty():
                    result["initial_key"] = value
            "MUSICBRAINZ_TRACKID":
                if String(result["musicbrainz_id"]).is_empty():
                    result["musicbrainz_id"] = value
            "MUSICBRAINZ RECORDING ID":
                if String(result["musicbrainz_id"]).is_empty():
                    result["musicbrainz_id"] = value
    return true


static func _extract_wav_info(path: String, result: Dictionary) -> void:
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        result["title"] = path.get_file().get_basename()
        return
    if file.get_buffer(4).get_string_from_ascii() != "RIFF":
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    file.get_32()
    if file.get_buffer(4).get_string_from_ascii() != "WAVE":
        file.close()
        result["title"] = path.get_file().get_basename()
        return
    while file.get_position() + 8 <= file.get_length():
        var chunk_id: String = file.get_buffer(4).get_string_from_ascii()
        var chunk_size: int = file.get_32()
        if chunk_size < 0:
            break
        var chunk_body_start: int = file.get_position()
        var chunk_body_end: int = chunk_body_start + chunk_size
        if chunk_id == "LIST":
            var list_type: String = file.get_buffer(4).get_string_from_ascii()
            if list_type == "INFO":
                while file.get_position() + 8 <= chunk_body_end and file.get_position() + 8 <= file.get_length():
                    var sub_id: String = file.get_buffer(4).get_string_from_ascii()
                    var sub_size: int = file.get_32()
                    if sub_size <= 0:
                        break
                    var sub_data: PackedByteArray = file.get_buffer(sub_size)
                    var sub_pad: int = sub_size % 2
                    if sub_pad != 0:
                        file.get_buffer(sub_pad)
                    var text: String = sub_data.get_string_from_utf8().strip_edges()
                    match sub_id:
                        "INAM":
                            if String(result["title"]).is_empty():
                                result["title"] = text
                        "IART":
                            if String(result["artist"]).is_empty():
                                result["artist"] = text
                        "IPRD":
                            if String(result["album"]).is_empty():
                                result["album"] = text
                        "ICMT":
                            if String(result["comment"]).is_empty():
                                result["comment"] = text
                        "IGNR":
                            if String(result["genre"]).is_empty():
                                result["genre"] = text
                        "ICRD":
                            if String(result["year"]).is_empty():
                                result["year"] = text
                file.seek(chunk_body_end)
            else:
                file.seek(chunk_body_end)
        else:
            file.seek(chunk_body_end)
        if chunk_size % 2 == 1:
            file.seek(file.get_position() + 1)
    file.close()
    if String(result["title"]).is_empty():
        result["title"] = path.get_file().get_basename()


static func _read_id3_text(payload: PackedByteArray) -> String:
    if payload.size() == 0:
        return ""
    var encoding: int = payload[0]
    var data: PackedByteArray = payload.slice(1, payload.size())
    if encoding == 0:
        return data.get_string_from_ascii()
    if encoding == 1 or encoding == 2:
        return data.get_string_from_utf16()
    return data.get_string_from_utf8()


static func _synchsafe_to_int(a: int, b: int, c: int, d: int) -> int:
    return (a & 0x7f) << 21 | (b & 0x7f) << 14 | (c & 0x7f) << 7 | (d & 0x7f)


static func _parse_float(text: String) -> float:
    var stripped: String = text.strip_edges()
    if stripped.is_valid_float():
        return stripped.to_float()
    return 0.0


static func _load_stream_from_path(path: String) -> AudioStream:
    var ext: String = path.get_extension().to_lower()
    if ext == "mp3":
        return AudioStreamMP3.load_from_file(path)
    if ext == "wav":
        # AudioStreamWAV.data is decoded PCM payload, not the whole WAV file bytes.
        # Decode via load_from_buffer to respect WAV encoding/header.
        var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
        if bytes.is_empty():
            return null
        return AudioStreamWAV.load_from_buffer(bytes)
    if ext == "ogg":
        # Decode via load_from_buffer to avoid interpreting container bytes as payload.
        var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
        if bytes.is_empty():
            return null
        return AudioStreamOggVorbis.load_from_buffer(bytes)
    return null


static func copy_to_user_imports(source_path: String, file_extension_hint: String = "") -> String:
    DirAccess.make_dir_recursive_absolute(USER_IMPORTS_DIR)

    var original_file_name: String = source_path.get_file()
    var cleaned_file_name: String = original_file_name.strip_edges()

    # If the native picker gives a path like "..._16." (no real extension), remove trailing dots.
    while cleaned_file_name.ends_with("."):
        cleaned_file_name = cleaned_file_name.substr(0, cleaned_file_name.length() - 1)

    var original_extension: String = source_path.get_extension().to_lower().strip_edges()
    var normalized_extension_hint: String = file_extension_hint.to_lower().strip_edges()
    if normalized_extension_hint.begins_with("."):
        normalized_extension_hint = normalized_extension_hint.substr(1, normalized_extension_hint.length() - 1)

    var audio_extension: String = ""
    if not normalized_extension_hint.is_empty():
        audio_extension = normalized_extension_hint
    elif not original_extension.is_empty():
        audio_extension = original_extension

    if audio_extension.is_empty():
        audio_extension = _infer_audio_extension_from_file_magic(source_path)

    var output_base_name: String = cleaned_file_name
    if not audio_extension.is_empty():
        output_base_name = cleaned_file_name.get_basename()

    var initial_dest_file_name: String = ""
    if audio_extension.is_empty():
        initial_dest_file_name = output_base_name
    else:
        initial_dest_file_name = "%s.%s" % [output_base_name, audio_extension]

    var dest_path: String = USER_IMPORTS_DIR.path_join(initial_dest_file_name)
    var counter: int = 0
    while FileAccess.file_exists(dest_path):
        counter += 1
        if audio_extension.is_empty():
            dest_path = USER_IMPORTS_DIR.path_join("%s_%d" % [output_base_name, counter])
        else:
            dest_path = USER_IMPORTS_DIR.path_join("%s_%d.%s" % [output_base_name, counter, audio_extension])

    var copy_error: Error = DirAccess.copy_absolute(source_path, dest_path)
    if copy_error != OK:
        return ""

    return dest_path


static func _infer_audio_extension_from_file_magic(source_path: String) -> String:
    var file: FileAccess = FileAccess.open(source_path, FileAccess.READ)
    if file == null:
        return ""

    var header_bytes: PackedByteArray = file.get_buffer(32)
    file.close()
    if header_bytes.is_empty():
        return ""

    # MP3 (often ID3 at the beginning)
    if header_bytes.size() >= 3 and header_bytes[0] == 0x49 and header_bytes[1] == 0x44 and header_bytes[2] == 0x33:
        return "mp3"

    # WAV starts with "RIFF" then "WAVE"
    if header_bytes.size() >= 12:
        var riff_str: String = header_bytes.slice(0, 4).get_string_from_ascii()
        var wave_str: String = header_bytes.slice(8, 12).get_string_from_ascii()
        if riff_str == "RIFF" and wave_str == "WAVE":
            return "wav"

    # OGG starts with "OggS"
    if header_bytes.size() >= 4:
        var ogg_str: String = header_bytes.slice(0, 4).get_string_from_ascii()
        if ogg_str == "OggS":
            return "ogg"

    return ""
