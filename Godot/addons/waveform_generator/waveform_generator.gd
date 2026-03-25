class_name WaveformGenerator
extends RefCounted

## Meta Quest 3 / Android only — uses WaveformGenerator plugin singleton (ffmpeg/ffprobe via ffmpeg-kit).
## Do not use OS.execute/ffprobe on Android; all paths go through the plugin.

const NAN_STRING: StringName = &"NaN"
const NAN_STRING_ARRAY: Array[StringName] = [NAN_STRING]


static func _singleton() -> Object:
    if Engine.has_singleton("WaveformGenerator"):
        return Engine.get_singleton("WaveformGenerator")
    push_error("WaveformGenerator: Android plugin not found. Enable the addon and enable Gradle export.")
    return null


static func generate(audio_path: String, output_png_path: String, width: int = 1200, height: int = 320) -> int:
    var s: Object = _singleton()
    if s == null:
        return -1
    return s.generate(audio_path, output_png_path, width, height)


static func get_song_title(audio_path: String) -> StringName:
    var tags: Dictionary = _get_tags(audio_path)
    return _to_name(_pick_first(tags, ["title"]))


static func get_main_artist(audio_path: String) -> StringName:
    var tags: Dictionary = _get_tags(audio_path)
    return _to_name(_pick_first(tags, ["album_artist", "albumartist", "artist"]))


static func get_supporting_artists(audio_path: String) -> Array[StringName]:
    var tags: Dictionary = _get_tags(audio_path)
    var raw: String = _pick_first(tags, ["artists", "performer", "performers", "featuring"])
    var arr: Array[StringName] = _split_multi(raw)
    if arr.is_empty():
        return NAN_STRING_ARRAY.duplicate()
    return arr


static func get_album_name(audio_path: String) -> StringName:
    var tags: Dictionary = _get_tags(audio_path)
    return _to_name(_pick_first(tags, ["album"]))


static func extract_album_artwork(audio_path: String, output_image_path: String = "") -> String:
    if output_image_path.is_empty():
        var base: String = audio_path.get_file().get_basename()
        output_image_path = "user://waveforms/%s_artwork.jpg" % base
    var global_audio: String = ProjectSettings.globalize_path(audio_path)
    var global_out: String = ProjectSettings.globalize_path(output_image_path)
    var s: Object = _singleton()
    if s == null:
        return "NaN"
    var code: int = s.extractArtwork(global_audio, global_out)
    if code == 0 and FileAccess.file_exists(global_out):
        return output_image_path
    return "NaN"


static func get_album_artwork_texture(audio_path: String) -> Texture2D:
    var path: String = extract_album_artwork(audio_path)
    if path == "NaN":
        return null
    var img: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
    if img == null:
        return null
    return ImageTexture.create_from_image(img)


static func get_comment(audio_path: String) -> StringName:
    var tags: Dictionary = _get_tags(audio_path)
    return _to_name(_pick_first(tags, ["comment", "description"]))


static func get_bpm(audio_path: String) -> float:
    var tags: Dictionary = _get_tags(audio_path)
    var raw: String = _pick_first(tags, ["bpm", "tbpm"])
    if raw == "":
        return NAN
    return float(raw)


static func get_genres(audio_path: String) -> Array[StringName]:
    var tags: Dictionary = _get_tags(audio_path)
    var raw: String = _pick_first(tags, ["genre", "genres"])
    var arr: Array[StringName] = _split_multi(raw)
    if arr.is_empty():
        return NAN_STRING_ARRAY.duplicate()
    return arr


static func get_musicbrainz_id(audio_path: String) -> StringName:
    var tags: Dictionary = _get_tags(audio_path)
    return _to_name(_pick_first(tags, [
        "musicbrainz_trackid",
        "musicbrainz_releasegroupid",
        "musicbrainz_recordingid",
		"musicbrainz_albumid"
    ]))


static func getMetadataJson(audio_path: String) -> Dictionary:
    return {
        "title": get_song_title(audio_path),
        "main_artist": get_main_artist(audio_path),
        "supporting_artists": get_supporting_artists(audio_path),
        "album": get_album_name(audio_path),
        "comment": get_comment(audio_path),
        "bpm": get_bpm(audio_path),
        "genres": get_genres(audio_path),
        "musicbrainz_id": get_musicbrainz_id(audio_path)
    }


static func _get_tags(audio_path: String) -> Dictionary:
    var global_audio: String = ProjectSettings.globalize_path(audio_path)
    var s: Object = _singleton()
    if s == null:
        return {}
    # Kotlin may return null; never assign Variant directly to String
    var raw_json: Variant = s.getMetadataJson(global_audio)
    var metadata_json: String = "{}"
    if raw_json != null and typeof(raw_json) == TYPE_STRING:
        var sjson: String = raw_json
        if sjson.strip_edges().begins_with("{"):
            metadata_json = sjson
    var parsed: Variant = JSON.parse_string(metadata_json)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var format_obj: Dictionary = parsed.get("format", {})
    var tags: Variant = format_obj.get("tags", {})
    if typeof(tags) != TYPE_DICTIONARY:
        return {}
    return tags as Dictionary


static func _pick_first(tags: Dictionary, keys: Array[String]) -> String:
    for key in keys:
        if tags.has(key) and str(tags[key]).strip_edges() != "":
            return str(tags[key]).strip_edges()
    return ""


static func _to_name(value: String) -> StringName:
    if value.strip_edges() == "":
        return NAN_STRING
    return StringName(value.strip_edges())


static func _split_multi(value: String) -> Array[StringName]:
    var raw: String = value.strip_edges()
    if raw == "":
        return []
    var normalized: String = raw.replace(" feat. ", ";").replace(" feat ", ";").replace(",", ";").replace("/", ";").replace("&", ";")
    var parts: PackedStringArray = normalized.split(";", false)
    var out: Array[StringName] = []
    for p: String in parts:
        var item: String = p.strip_edges()
        if item != "":
            out.append(StringName(item))
    return out
