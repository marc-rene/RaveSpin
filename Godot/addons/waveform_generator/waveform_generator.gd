class_name WaveformGenerator
extends RefCounted

## Generates waveform PNGs from audio at runtime.
## On Android/Quest uses the WaveformGenerator plugin (ffmpeg-kit). On desktop uses the GDExtension if loaded.

const NAN_STRING: StringName = &"NaN"
const NAN_STRING_ARRAY: Array[StringName] = [NAN_STRING]

static func generate(audio_path: String, output_png_path: String, width: int = 1200, height: int = 320) -> int:
	if OS.get_name() == "Android":
		if Engine.has_singleton("WaveformGenerator"):
			return Engine.get_singleton("WaveformGenerator").generate(audio_path, output_png_path, width, height)
		push_error("WaveformGenerator: Android plugin not found. Enable the plugin and use Gradle build.")
		return -1
	else:
		# Desktop: use GDExtension class if available (registered as WaveformGeneratorNative)
		if ClassDB.class_exists("WaveformGeneratorNative"):
			var gen = ClassDB.instantiate("WaveformGeneratorNative")
			if gen:
				return gen.generate(audio_path, output_png_path, width, height)
		push_error("WaveformGenerator: GDExtension not loaded on desktop. Build and load the extension, or use only on Android.")
		return -1


static func get_song_title(audio_path: String) -> StringName:
	var tags := _get_tags(audio_path)
	return _to_name(_pick_first(tags, ["title"]))


static func get_main_artist(audio_path: String) -> StringName:
	var tags := _get_tags(audio_path)
	return _to_name(_pick_first(tags, ["album_artist", "albumartist", "artist"]))


static func get_supporting_artists(audio_path: String) -> Array[StringName]:
	var tags := _get_tags(audio_path)
	var raw := _pick_first(tags, ["artists", "performer", "performers", "featuring"])
	var arr := _split_multi(raw)
	if arr.is_empty():
		return NAN_STRING_ARRAY.duplicate()
	return arr


static func get_album_name(audio_path: String) -> StringName:
	var tags := _get_tags(audio_path)
	return _to_name(_pick_first(tags, ["album"]))


static func extract_album_artwork(audio_path: String, output_image_path: String = "") -> String:
	if output_image_path.is_empty():
		var base := audio_path.get_file().get_basename()
		output_image_path = "user://waveforms/%s_artwork.jpg" % base
	var global_audio := ProjectSettings.globalize_path(audio_path)
	var global_out := ProjectSettings.globalize_path(output_image_path)
	var code := -1
	if OS.get_name() == "Android" and Engine.has_singleton("WaveformGenerator"):
		code = Engine.get_singleton("WaveformGenerator").extractArtwork(global_audio, global_out)
	else:
		var output := []
		var args := PackedStringArray(["-y", "-i", global_audio, "-an", "-vcodec", "copy", global_out])
		code = OS.execute("ffmpeg", args, output, true)
	if code == 0 and FileAccess.file_exists(global_out):
		return output_image_path
	return "NaN"


static func get_album_artwork_texture(audio_path: String) -> Texture2D:
	var path := extract_album_artwork(audio_path)
	if path == "NaN":
		return null
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null:
		return null
	return ImageTexture.create_from_image(img)


static func get_comment(audio_path: String) -> StringName:
	var tags := _get_tags(audio_path)
	return _to_name(_pick_first(tags, ["comment", "description"]))


static func get_bpm(audio_path: String) -> float:
	var tags := _get_tags(audio_path)
	var raw := _pick_first(tags, ["bpm", "tbpm"])
	if raw == "":
		return NAN
	return float(raw)


static func get_genres(audio_path: String) -> Array[StringName]:
	var tags := _get_tags(audio_path)
	var raw := _pick_first(tags, ["genre", "genres"])
	var arr := _split_multi(raw)
	if arr.is_empty():
		return NAN_STRING_ARRAY.duplicate()
	return arr


static func get_musicbrainz_id(audio_path: String) -> StringName:
	var tags := _get_tags(audio_path)
	return _to_name(_pick_first(tags, [
		"musicbrainz_trackid",
		"musicbrainz_releasegroupid",
		"musicbrainz_recordingid",
		"musicbrainz_albumid"
	]))


static func get_full_metadata(audio_path: String) -> Dictionary:
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
	var global_audio := ProjectSettings.globalize_path(audio_path)
	var metadata_json := "{}"
	if OS.get_name() == "Android" and Engine.has_singleton("WaveformGenerator"):
		metadata_json = Engine.get_singleton("WaveformGenerator").getMetadataJson(global_audio)
	else:
		var output := []
		var args := PackedStringArray(["-v", "quiet", "-print_format", "json", "-show_format", "-show_streams", global_audio])
		var code := OS.execute("ffprobe", args, output, true)
		if code == 0 and output.size() > 0:
			metadata_json = str(output[0])
	var parsed := JSON.parse_string(metadata_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var format_obj: Dictionary = parsed.get("format", {})
	return format_obj.get("tags", {})


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
	var raw := value.strip_edges()
	if raw == "":
		return []
	var normalized := raw.replace(" feat. ", ";").replace(" feat ", ";").replace(",", ";").replace("/", ";").replace("&", ";")
	var parts := normalized.split(";", false)
	var out: Array[StringName] = []
	for p in parts:
		var item := p.strip_edges()
		if item != "":
			out.append(StringName(item))
	return out
