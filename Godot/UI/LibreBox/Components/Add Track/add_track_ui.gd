extends PanelContainer
class_name Add_Track

## Add local song: native file picker -> user:// copy -> MusicMetadata + AudioMetadata; waveform PNG via WaveformGenerator only.

## Placeholder row in genre OptionButtons; not written to Song_Genres.
const GENRE_OPTION_ID_NONE: int = -1

## Order matches EMusicKey.m_scales_str (Language/LANG_Translation.csv).
const _SCALE_I18N_KEYS: Array[String] = [
    "KEY_SCALE_UNKNOWN",
    "KEY_SCALE_MAJOR",
    "KEY_SCALE_NATURAL_MINOR",
    "KEY_SCALE_HARMONIC_MINOR",
    "KEY_SCALE_MELODIC_MINOR",
    "KEY_SCALE_GYPSY_MINOR",
    "KEY_SCALE_NEAPOLITAN_MINOR",
    "KEY_SCALE_HUNGARIAN_MINOR",
    "KEY_SCALE_MAJOR_PENTATONIC",
    "KEY_SCALE_MINOR_PENTATONIC",
    "KEY_SCALE_BLUES",
    "KEY_SCALE_DORIAN",
    "KEY_SCALE_PHRYGIAN",
    "KEY_SCALE_LYDIAN",
    "KEY_SCALE_MIXOLYDIAN",
    "KEY_SCALE_LOCRIAN",
    "KEY_SCALE_CHROMATIC",
    "KEY_SCALE_WHOLE_TONE",
    "KEY_SCALE_OCTATONIC",
    "KEY_SCALE_ARABIC",
]

var _pending_song: Song
var _pending_audio_path: String
var _picking_file: bool = false

## Cached ID3 rows { "id": int, "label": String } in catalog order (0..191, 192 CR, 193 RX).
var _id3_genre_catalog_rows: Array[Dictionary] = []

## Cached lists for dropdowns (sorted by name)
var _artists_sorted: Array[Artist] = []
var _albums_sorted: Array[Album] = []

## Genre pickers (first is %GenreOption0)
var _genre_pickers: Array[OptionButton] = []

@onready var _add_local_btn: Button = %Add_Local_Song_btn
@onready var _save_to_library_btn: Button = %"Save to library btn"
@onready var _details_container: VBoxContainer = $"PanelContainer/GridContainer/Row 1/Details input container"
@onready var _row2: HBoxContainer = $"PanelContainer/GridContainer/Row 2"
@onready var _album_art_rect: TextureRect = %"Album Art btn"
@onready var _choose_artist_opt: OptionButton = %ChooseArtistOption
@onready var _choose_album_opt: OptionButton = %ChooseAlbumOption
@onready var _genre_flow: HFlowContainer = %HFlowContainer
@onready var _genre_option0: OptionButton = %GenreOption0
@onready var _music_key_note_option: OptionButton = $"PanelContainer/GridContainer/Row 2/Music Key Note" as OptionButton
@onready var _music_key_scale_option: OptionButton = $"PanelContainer/GridContainer/Row 2/Music Key Scale" as OptionButton

@onready var Parent_XR_2D_3D_Node: XRToolsViewport2DIn3D = $"../.."

var _default_album_art: Texture2D
var _fallback_file_dialog: FileDialog
## Latest [MusicMetadata] from the addon (embedded cover art).
var _last_extracted_music_metadata: MusicMetadata

## Embedded cover texture extracted from the current selected song.
## Used to persist `Album.Album_Artwork` when saving the song to the library.
var _pending_album_artwork_texture: Texture2D


func close_window() -> void:
    Parent_XR_2D_3D_Node.position.y = 10.0
    Parent_XR_2D_3D_Node.set_enabled(false)


func _ready() -> void:
    if _album_art_rect != null and _album_art_rect.texture != null:
        _default_album_art = _album_art_rect.texture
    if _add_local_btn != null:
        _add_local_btn.pressed.connect(_on_add_local_song_pressed)
    if _save_to_library_btn != null:
        _save_to_library_btn.pressed.connect(_on_save_to_library_pressed)
    var close_btn: Button = $"PanelContainer/GridContainer/HBoxContainer/Close btn" as Button
    if close_btn != null:
        close_btn.pressed.connect(close_window)

    _build_id3_genre_catalog_cache()
    _refresh_artist_album_lists()
    _fill_choose_artist_dropdown()
    _fill_choose_album_dropdown()
    if _choose_artist_opt != null:
        _choose_artist_opt.item_selected.connect(_on_choose_artist_selected)
    if _choose_album_opt != null:
        _choose_album_opt.item_selected.connect(_on_choose_album_selected)

    _genre_pickers = [_genre_option0]
    if _genre_option0 != null:
        _genre_option0.item_selected.connect(_on_any_genre_selected.bind(_genre_option0))
    _refresh_all_genre_dropdowns()

    _setup_fallback_file_dialog()
    _fill_music_key_dropdowns()


func _setup_fallback_file_dialog() -> void:
    _fallback_file_dialog = FileDialog.new()
    _fallback_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    _fallback_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    _fallback_file_dialog.title = tr("KEY_CHOOSE_AUDIO_FILE")
    _fallback_file_dialog.min_size = Vector2i(1000, 1000)
    _fallback_file_dialog.ok_button_text = tr("KEY_OPEN")
    _fallback_file_dialog.add_filter("*.mp3", tr("KEY_FILETYPE_MP3"))
    _fallback_file_dialog.add_filter("*.wav", tr("KEY_FILETYPE_WAV"))
    _fallback_file_dialog.add_filter("*.ogg", tr("KEY_FILETYPE_OGG"))
    _fallback_file_dialog.file_selected.connect(_on_fallback_file_dialog_file_selected)
    _fallback_file_dialog.canceled.connect(_on_fallback_file_dialog_canceled)
    get_tree().root.add_child(_fallback_file_dialog)


func _fill_music_key_dropdowns() -> void:
    if _music_key_note_option != null:
        _music_key_note_option.clear()
        var note_labels: Array[StringName] = EMusicKey.m_notes_str
        for note_index: int in range(note_labels.size()):
            _music_key_note_option.add_item(String(note_labels[note_index]), note_index)
    if _music_key_scale_option != null:
        _music_key_scale_option.clear()
        var scale_labels: Array[StringName] = EMusicKey.m_scales_str
        for scale_index: int in range(scale_labels.size()):
            _music_key_scale_option.add_item(tr(_SCALE_I18N_KEYS[scale_index]), scale_index)


func _select_music_key_dropdowns(note_enum: EMusicKey.m_notes_enum, scale_enum: EMusicKey.m_scales_enum) -> void:
    var note_id: int = int(note_enum)
    var scale_id: int = int(scale_enum)
    if _music_key_note_option != null:
        for item_index: int in range(_music_key_note_option.item_count):
            if _music_key_note_option.get_item_id(item_index) == note_id:
                _music_key_note_option.select(item_index)
                break
    if _music_key_scale_option != null:
        for item_index: int in range(_music_key_scale_option.item_count):
            if _music_key_scale_option.get_item_id(item_index) == scale_id:
                _music_key_scale_option.select(item_index)
                break


func _build_id3_genre_catalog_cache() -> void:
    _id3_genre_catalog_rows.clear()
    for catalog_index: int in range(0, 192):
        var key: String = str(catalog_index)
        if MusicMetadataTools.ID3_GENRE_IDS.has(key):
            var row: Dictionary = {
                "id": catalog_index,
                "label": String(MusicMetadataTools.ID3_GENRE_IDS[key]),
            }
            _id3_genre_catalog_rows.append(row)
    if MusicMetadataTools.ID3_GENRE_IDS.has("CR"):
        _id3_genre_catalog_rows.append({"id": 192, "label": String(MusicMetadataTools.ID3_GENRE_IDS["CR"])})
    if MusicMetadataTools.ID3_GENRE_IDS.has("RX"):
        _id3_genre_catalog_rows.append({"id": 193, "label": String(MusicMetadataTools.ID3_GENRE_IDS["RX"])})


func _refresh_artist_album_lists() -> void:
    _artists_sorted = _load_artists_from_disk()
    _albums_sorted = _load_albums_from_disk()
    _artists_sorted.sort_custom(func(left: Artist, right: Artist) -> bool: return String(left.Artist_Name) < String(right.Artist_Name))
    _albums_sorted.sort_custom(func(left: Album, right: Album) -> bool: return String(left.Album_Name) < String(right.Album_Name))


func _load_artists_from_disk() -> Array[Artist]:
    var result: Array[Artist] = []
    var seen_keys: Dictionary = {}
    var bases: Array[String] = ["res://Music/Artists/", "user://Music/Artists/"]
    for base_index: int in range(bases.size()):
        var base_path: String = bases[base_index]
        if not DirAccess.dir_exists_absolute(base_path):
            continue
        var dir: DirAccess = DirAccess.open(base_path)
        if dir == null:
            continue
        dir.list_dir_begin()
        var entry_name: String = dir.get_next()
        while entry_name != "":
            if (not dir.current_is_dir()) and entry_name.ends_with(".tres"):
                var resource_path: String = base_path.path_join(entry_name)
                var loaded: Resource = ResourceLoader.load(resource_path)
                if loaded is Artist:
                    var artist: Artist = loaded as Artist
                    var dedupe_key: String = "A:" + String(artist.Artist_Name)
                    if not seen_keys.has(dedupe_key):
                        seen_keys[dedupe_key] = true
                        result.append(artist)
            entry_name = dir.get_next()
        dir.list_dir_end()
    return result


func _load_albums_from_disk() -> Array[Album]:
    var result: Array[Album] = []
    var seen_keys: Dictionary = {}
    var bases: Array[String] = ["res://Music/Albums/", "user://Music/Albums/"]
    for base_index: int in range(bases.size()):
        var base_path: String = bases[base_index]
        if not DirAccess.dir_exists_absolute(base_path):
            continue
        var dir: DirAccess = DirAccess.open(base_path)
        if dir == null:
            continue
        dir.list_dir_begin()
        var entry_name: String = dir.get_next()
        while entry_name != "":
            if (not dir.current_is_dir()) and entry_name.ends_with(".tres"):
                var resource_path: String = base_path.path_join(entry_name)
                var loaded: Resource = ResourceLoader.load(resource_path)
                if loaded is Album:
                    var album: Album = loaded as Album
                    var dedupe_key: String = "L:" + String(album.Album_Name)
                    if not seen_keys.has(dedupe_key):
                        seen_keys[dedupe_key] = true
                        result.append(album)
            entry_name = dir.get_next()
        dir.list_dir_end()
    return result


func _fill_choose_artist_dropdown() -> void:
    if _choose_artist_opt == null:
        return
    _choose_artist_opt.clear()
    _choose_artist_opt.add_item(tr("KEY_CHOOSE_EXISTING_ARTISTS"), 0)
    _choose_artist_opt.set_item_disabled(0, true)
    _choose_artist_opt.add_separator()
    var next_id: int = 1
    _choose_artist_opt.add_item(tr("KEY_ADD_NEW_ARTIST_OPTION"), next_id)
    next_id += 1
    for artist_index: int in range(_artists_sorted.size()):
        var artist: Artist = _artists_sorted[artist_index]
        _choose_artist_opt.add_item(String(artist.Artist_Name), next_id)
        _choose_artist_opt.set_item_metadata(_choose_artist_opt.item_count - 1, artist)
        next_id += 1


func _fill_choose_album_dropdown() -> void:
    if _choose_album_opt == null:
        return
    _choose_album_opt.clear()
    _choose_album_opt.add_item(tr("KEY_CHOOSE_EXISTING_ALBUMS"), 0)
    _choose_album_opt.set_item_disabled(0, true)
    _choose_album_opt.add_separator()
    var next_id: int = 1
    _choose_album_opt.add_item(tr("KEY_ADD_NEW_ALBUM_OPTION"), next_id)
    next_id += 1
    for album_index: int in range(_albums_sorted.size()):
        var album: Album = _albums_sorted[album_index]
        _choose_album_opt.add_item(String(album.Album_Name), next_id)
        _choose_album_opt.set_item_metadata(_choose_album_opt.item_count - 1, album)
        next_id += 1


func _artist_id_for_add_new() -> int:
    return 1


func _album_id_for_add_new() -> int:
    return 1


func _on_choose_artist_selected(_unused_index: int) -> void:
    var artist_line_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName") as LineEdit
    if artist_line_edit == null:
        return
    var selected_id: int = _choose_artist_opt.get_item_id(_choose_artist_opt.selected)
    if selected_id <= 0:
        return
    if selected_id == _artist_id_for_add_new():
        artist_line_edit.placeholder_text = tr("KEY_ENTER_NEW_ARTIST_NAME")
        return
    var metadata_value: Variant = _choose_artist_opt.get_item_metadata(_choose_artist_opt.selected)
    if metadata_value is Artist:
        var selected_artist: Artist = metadata_value as Artist
        artist_line_edit.text = String(selected_artist.Artist_Name)


func _on_choose_album_selected(_unused_index: int) -> void:
    var album_line_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName") as LineEdit
    if album_line_edit == null:
        return
    var selected_id: int = _choose_album_opt.get_item_id(_choose_album_opt.selected)
    if selected_id <= 0:
        return
    if selected_id == _album_id_for_add_new():
        album_line_edit.placeholder_text = tr("KEY_ENTER_NEW_ALBUM_NAME")
        return
    var metadata_value: Variant = _choose_album_opt.get_item_metadata(_choose_album_opt.selected)
    if metadata_value is Album:
        var selected_album: Album = metadata_value as Album
        album_line_edit.text = String(selected_album.Album_Name)


func _on_add_local_song_pressed() -> void:
    if _picking_file:
        return
    _picking_file = true
    var filters: PackedStringArray = PackedStringArray([
        "*.mp3 ; MP3",
        "*.wav ; WAV",
        "*.ogg ; OGG Vorbis",
    ])
    if _should_use_native_file_dialog():
        DisplayServer.file_dialog_show(
            tr("KEY_CHOOSE_AUDIO_FILE"),
            "",
            "",
            false,
            DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,
            filters,
            _on_native_file_dialog_result
        )
    else:
        _picking_file = false
        if _fallback_file_dialog != null:
            _fallback_file_dialog.popup_centered_ratio(0.85)


func _should_use_native_file_dialog() -> bool:
    return DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG)


func _on_native_file_dialog_result(status: bool, paths: PackedStringArray, _filter_index: int) -> void:
    _picking_file = false
    if (not status) or paths.is_empty():
        return
    
    var first_path: String = paths[0]
    var file_extension_hint: String = _extension_hint_for_native_path_by_magic(first_path)
    print("Chose file: %s which is a %s" % [first_path, file_extension_hint])
    _on_audio_file_selected(first_path, file_extension_hint)


func _on_fallback_file_dialog_file_selected(path: String) -> void:
    _picking_file = false
    var detected_extension: String = path.get_extension().to_lower()
    _on_audio_file_selected(path, detected_extension)


func _on_fallback_file_dialog_canceled() -> void:
    _picking_file = false


func _on_audio_file_selected(selected_path: String, file_extension_hint: String = "") -> void:
    if selected_path.is_empty():
        return
    var dest_path: String = AudioMetadata.copy_to_user_imports(selected_path, file_extension_hint)
    if dest_path.is_empty():
        push_error("Add Track: Failed to copy file to user imports.")
        return

    var meta: Dictionary = _extract_metadata_merged(dest_path)

    _pending_song = Song.new()
    _pending_song.Audio_File_Path = dest_path
    _pending_song.Song_Title = _meta_title(meta, dest_path)
    _pending_song.Track_BPM = _meta_bpm(meta)
    _pending_song.User_Sidenote = _meta_comment(meta)
    _pending_song.Song_Origin_Platform = ETrackOrigins.Track_Origins_enum.LOCAL_STORAGE
    var musicbrainz_str: String = String(meta.get("musicbrainz_id", "")).strip_edges()
    if musicbrainz_str != "":
        _pending_song.MusicBrainz_ID = StringName(musicbrainz_str)
    _apply_initial_key_from_metadata(meta)
    _pending_song.Refresh_Music_Key()
    _pending_audio_path = dest_path

    _populate_form_from_metadata(meta)
    _apply_album_artwork(_last_extracted_music_metadata)
    _generate_and_assign_waveform_png(dest_path)


## Infers `mp3`/`wav`/`ogg` by reading the first bytes from the native picker URI.
## This works even when the native path has no extension (e.g. `.../document/msf%3A1000000088`).
## Returns "" when the type cannot be determined.
func _extension_hint_for_native_path_by_magic(native_path_string: String) -> String:
    var file_handle: FileAccess = FileAccess.open(native_path_string, FileAccess.READ)
    if file_handle == null:
        return ""

    var header_bytes: PackedByteArray = file_handle.get_buffer(32)
    file_handle.close()
    if header_bytes.is_empty():
        return ""

    # MP3 often starts with "ID3"
    if header_bytes.size() >= 3:
        if header_bytes[0] == 0x49 and header_bytes[1] == 0x44 and header_bytes[2] == 0x33:
            return "mp3"

    # WAV: "RIFF" ... "WAVE" at offset 8
    if header_bytes.size() >= 12:
        var riff_string: String = header_bytes.slice(0, 4).get_string_from_ascii()
        var wave_string: String = header_bytes.slice(8, 12).get_string_from_ascii()
        if riff_string == "RIFF" and wave_string == "WAVE":
            return "wav"

    # OGG: "OggS"
    if header_bytes.size() >= 4:
        var ogg_string: String = header_bytes.slice(0, 4).get_string_from_ascii()
        if ogg_string == "OggS":
            return "ogg"

    return ""


func _extract_metadata_merged(audio_path: String) -> Dictionary:
    var merged: Dictionary = AudioMetadata.extract_from_path(audio_path)
    _last_extracted_music_metadata = AudioMetadata.take_plugin_metadata(merged)
    return merged


## Writes a waveform PNG next to the imported audio file and assigns [member Song.Audio_File_Waveform].
## Uses [WaveformGenerator] Android plugin only for image generation (no metadata).
func _generate_and_assign_waveform_png(audio_path: String) -> void:
    if _pending_song == null:
        return
    var base_name: String = audio_path.get_file().get_basename()
    var output_png: String = audio_path.get_base_dir().path_join("%s_WAVEFORM.png" % base_name)
    print("Add_Track: Generating waveform PNG")
    
    print("Add_Track: audio_path (user://): %s" % audio_path)
    
    var temp_input_global: String = ProjectSettings.globalize_path(audio_path)
    print("Add_Track: GLOBAL audio_path : %s" % temp_input_global)
    
    print("Add_Track: output_png (user://): %s" % output_png)
    
    var temp_output_global: String = ProjectSettings.globalize_path(output_png)
    print("Add_Track: GLOBAL output png : %s" % temp_output_global)
    
    var exit_code: int = WaveformGenerator.generate(temp_input_global, temp_output_global, 1200, 240)
    print("ADD_TRACK 1: Exit code was %d" % exit_code)
    
    # Some Android plugin writes asynchronously; poll briefly.
    var wait_slices: int = 0
    while wait_slices < 20 and (not FileAccess.file_exists(output_png)): 
        await get_tree().create_timer(0.05).timeout
        wait_slices += 1
    
    if FileAccess.file_exists(temp_output_global):
        print("THE WAVEFORM EXISTS! %s IS REAL" % temp_output_global)
        var temp_waveform_texture : CompressedTexture2D = load(temp_output_global)
        await temp_waveform_texture
        if temp_waveform_texture:
            print("YES!!")
            _pending_song.Audio_File_Waveform = temp_waveform_texture
        else:
            print("shit")
    else:
        print("Crap... The waveform doesn't exist! %s isn't real" % temp_output_global)
        if await _fallback_generate_waveform_png_with_audio_preview(temp_input_global, temp_output_global):
            print("YAY NEVERMIND THE FALLBACK WORKED")
            var temp_waveform_texture : CompressedTexture2D = load(temp_output_global)
            await temp_waveform_texture
            if temp_waveform_texture:
                print("YES THE WAVEFORMS SET!!")
            _pending_song.Audio_File_Waveform = temp_waveform_texture
        else:
            print("Not even the fallback worked")
            
    #var output_directory_user: String = output_png.get_base_dir()
    #DirAccess.make_dir_recursive_absolute(output_directory_user)
    #DirAccess.make_dir_recursive_absolute("user://waveforms/")
#
    ## Wrapper now globalizes paths internally (matches extract_album_artwork behavior).
    #print("Add_Track: waveform generator exit_code: %d" % exit_code)
#
    #var temp_output_global: String = ProjectSettings.globalize_path(output_png)
    #print("ADD_TRACK: Global Path of PNG is at %s" % output_png)
    #var temp_output_alt_internal: String = _android_alt_internal_files_fallback(temp_output_global)
    #var temp_output_external: String = _android_external_files_fallback(temp_output_global)
    #var target_output_global: String = ProjectSettings.globalize_path(output_png)
#
    ## Some Android plugin writes asynchronously; poll briefly.
    #var wait_slices: int = 0
    #while wait_slices < 20 \
            #and (not FileAccess.file_exists(temp_output_global)) \
            #and (temp_output_alt_internal.is_empty() or (not FileAccess.file_exists(temp_output_alt_internal))) \
            #and (temp_output_external.is_empty() or (not FileAccess.file_exists(temp_output_external))):
        #await get_tree().create_timer(0.05).timeout
        #wait_slices += 1
#
    #var found_temp_global: String = ""
    #if FileAccess.file_exists(temp_output_global):
        #found_temp_global = temp_output_global
    #elif not temp_output_alt_internal.is_empty() and FileAccess.file_exists(temp_output_alt_internal):
        #found_temp_global = temp_output_alt_internal
    #elif not temp_output_external.is_empty() and FileAccess.file_exists(temp_output_external):
        #found_temp_global = temp_output_external
#
    #if found_temp_global.is_empty():
        #print("Add_Track: waveform temp PNG not found after generation: %s" % temp_output_global)
        #if not temp_output_alt_internal.is_empty():
            #print("Add_Track: also not found at alt internal path: %s" % temp_output_alt_internal)
        #if not temp_output_external.is_empty():
            #print("Add_Track: also not found at external path: %s" % temp_output_external)
        #await _fallback_generate_waveform_png_with_audio_preview(audio_path, target_output_global)
        #_pending_song.Attempt_Find_waveform_from_audio_file_path()
        #return
#
    ## Copy beside the audio file so existing loaders keep working.
    #var copy_error: Error = DirAccess.copy_absolute(found_temp_global, target_output_global)
    #if copy_error != OK:
        #print("Add_Track: failed to copy waveform PNG to target: %s (error=%d)" % [target_output_global, copy_error])
        #return
#
    #_pending_song.Attempt_Find_waveform_from_audio_file_path()


func _android_external_files_fallback(internal_global_path: String) -> String:
    if not OS.has_feature("android"):
        return ""
    var marker: String = "/data/data/"
    var idx: int = internal_global_path.find(marker)
    if idx < 0:
        return ""
    var after: String = internal_global_path.substr(idx + marker.length())
    var slash_idx: int = after.find("/")
    if slash_idx < 0:
        return ""
    var package_name: String = after.substr(0, slash_idx)
    var rest: String = after.substr(slash_idx) # includes "/files/..."
    return "/storage/emulated/0/Android/data/%s%s" % [package_name, rest]


func _android_alt_internal_files_fallback(internal_global_path: String) -> String:
    if not OS.has_feature("android"):
        return ""
    # Some environments expose app files under /data/<package>/files instead of /data/data/<package>/files
    var marker: String = "/data/data/"
    var idx: int = internal_global_path.find(marker)
    if idx < 0:
        return ""
    var after: String = internal_global_path.substr(idx + marker.length())
    var slash_idx: int = after.find("/")
    if slash_idx < 0:
        return ""
    var package_name: String = after.substr(0, slash_idx)
    var rest: String = after.substr(slash_idx) # includes "/files/..."
    return "/data/%s%s" % [package_name, rest]


## WAV-only fallback waveform generator using `addons/audio_preview` (pure GDScript).
## This is only used when WaveformGenerator says success but no PNG appears on disk.
func _fallback_generate_waveform_png_with_audio_preview(audio_path: String, output_png_global_path: String) -> bool:
    var success : bool = false
    var extension_lower: String = audio_path.get_extension().to_lower()
    if extension_lower != "wav":
        return false

    var stream_variant: Variant = _pending_song.get_audio_stream() if _pending_song != null else null
    if not (stream_variant is AudioStreamWAV):
        return false
    var wav_stream: AudioStreamWAV = stream_variant as AudioStreamWAV

    var generator_scene: PackedScene = preload("res://addons/audio_preview/voice_preview_generator.tscn")
    var generator_node: Node = generator_scene.instantiate()
    add_child(generator_node)

    var texture: Texture2D = await _await_audio_preview_texture(generator_node, wav_stream)
    if texture is ImageTexture:
        var image_texture: ImageTexture = texture as ImageTexture
        var image: Image = image_texture.get_image()
        if image != null:
            var save_error: Error = image.save_png(output_png_global_path)
            if save_error == OK:
                print("Add_Track: audio_preview waveform PNG saved: %s" % output_png_global_path)
                success = true
    generator_node.queue_free()
    return success


func _await_audio_preview_texture(generator_node: Node, wav_stream: AudioStreamWAV) -> Texture2D:
    var texture_variant: Variant = null
    var callable: Callable = func(tex: Variant) -> void: texture_variant = tex
    generator_node.connect("texture_ready", callable)
    await generator_node.call("generate_preview", wav_stream, 1200)
    while texture_variant == null:
        await get_tree().process_frame
    if texture_variant is Texture2D:
        return texture_variant as Texture2D
    return null


func _sanitize_waveform_base_name(raw_base_name: String) -> String:
    var sanitized: String = raw_base_name.strip_edges()
    # FFmpeg treats '%' specially (image sequences). Also avoid other path-hostile chars.
    sanitized = sanitized.replace("%", "_")
    sanitized = sanitized.replace(":", "_")
    sanitized = sanitized.replace("/", "_")
    sanitized = sanitized.replace("\\", "_")
    sanitized = sanitized.replace("?", "_")
    sanitized = sanitized.replace("*", "_")
    sanitized = sanitized.replace("\"", "_")
    sanitized = sanitized.replace("<", "_")
    sanitized = sanitized.replace(">", "_")
    sanitized = sanitized.replace("|", "_")
    sanitized = sanitized.replace(" ", "_")
    while sanitized.contains("__"):
        sanitized = sanitized.replace("__", "_")
    sanitized = sanitized.strip_edges()
    if sanitized.is_empty():
        sanitized = "ImportedSong"
    return sanitized


func _append_genre_tag_strings_to(target: PackedStringArray, raw_genre: String) -> void:
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


func _packed_string_array_contains_ci(haystack: PackedStringArray, needle: String) -> bool:
    var needle_upper: String = needle.to_upper()
    for stack_index: int in range(haystack.size()):
        if haystack[stack_index].to_upper() == needle_upper:
            return true
    return false


func _apply_initial_key_from_metadata(meta: Dictionary) -> void:
    if _pending_song == null:
        return
    var key_text: String = String(meta.get("initial_key", "")).strip_edges()
    if key_text.is_empty():
        _select_music_key_dropdowns(_pending_song.Track_Key_Note, _pending_song.Track_Scale)
        return
    if key_text.find(" ") >= 0:
        var parsed_key: EMusicKey = EMusicKey.String_to_MusicKey(key_text)
        _pending_song.Track_Key_Note = parsed_key.m_note_index
        _pending_song.Track_Scale = parsed_key.m_scale_index
    _select_music_key_dropdowns(_pending_song.Track_Key_Note, _pending_song.Track_Scale)



func _meta_title(meta: Dictionary, dest_path: String) -> StringName:
    var title_text: String = String(meta.get("title", ""))
    if title_text.is_empty():
        return StringName(dest_path.get_file().get_basename())
    return StringName(title_text)


func _meta_bpm(meta: Dictionary) -> float:
    var raw: Variant = meta.get("bpm", 0.0)
    if raw is float:
        var bpm_float: float = raw as float
        if not is_nan(bpm_float):
            return bpm_float
    if raw is int:
        return float(raw as int)
    return 0.0


func _meta_comment(meta: Dictionary) -> String:
    return String(meta.get("comment", ""))


## Map tag text / numeric ID3 index from files into Song's int genre IDs (0..191, 192 CR, 193 RX, or none).
func _resolve_genre_tag_to_id3_int(genre_tag: String) -> int:
    var trimmed: String = genre_tag.strip_edges()
    if trimmed.is_empty():
        return GENRE_OPTION_ID_NONE
    if trimmed.is_valid_int():
        var numeric: int = int(trimmed)
        if numeric >= 0 and numeric <= 191:
            var key: String = str(numeric)
            if MusicMetadataTools.ID3_GENRE_IDS.has(key):
                return numeric
    if trimmed == "CR" or trimmed.to_upper() == "COVER":
        return 192
    if trimmed == "RX" or trimmed.to_upper() == "REMIX":
        return 193
    var upper_label: String = trimmed.to_upper()
    for row_index: int in range(_id3_genre_catalog_rows.size()):
        var row: Dictionary = _id3_genre_catalog_rows[row_index]
        var label: String = String(row.get("label", "")).to_upper()
        if label == upper_label:
            return int(row.get("id", GENRE_OPTION_ID_NONE))
    return GENRE_OPTION_ID_NONE


func _apply_album_artwork(music_meta: MusicMetadata) -> void:
    if _album_art_rect == null:
        return
    var artwork_texture: Texture2D
    _pending_album_artwork_texture = null
    if music_meta != null:
        var embedded_cover: ImageTexture = music_meta.get_most_relevent_cover()
        if embedded_cover != null:
            artwork_texture = embedded_cover
    if artwork_texture != null:
        _pending_album_artwork_texture = artwork_texture
        _album_art_rect.texture = artwork_texture
    elif _default_album_art != null:
        _album_art_rect.texture = _default_album_art


func _populate_form_from_metadata(meta: Dictionary) -> void:
    var title_edit: LineEdit = _details_container.get_node_or_null("Song Title Row/SongTitleLineEdit") as LineEdit
    if title_edit != null:
        title_edit.text = String(meta.get("title", ""))

    var artist_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName") as LineEdit
    if artist_edit != null:
        artist_edit.text = String(meta.get("artist", ""))

    var album_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName") as LineEdit
    if album_edit != null:
        album_edit.text = String(meta.get("album", ""))

    var bpm_edit: LineEdit = _row2.get_node_or_null("BPM") as LineEdit
    if bpm_edit != null:
        var bpm_value: float = _meta_bpm(meta)
        if bpm_value > 0.0:
            bpm_edit.text = str(int(bpm_value))
        else:
            bpm_edit.text = ""

    var sidenote_edit: TextEdit = _row2.get_node_or_null("BPM3") as TextEdit
    if sidenote_edit != null:
        sidenote_edit.text = String(meta.get("comment", ""))

    _sync_dropdowns_from_text()

    if _music_key_note_option != null and _pending_song != null:
        _select_music_key_dropdowns(_pending_song.Track_Key_Note, _pending_song.Track_Scale)

    var raw_genres: Variant = meta.get("genres", PackedStringArray())
    _reset_genre_pickers_to_unknown()
    var genre_labels: Array[String] = []
    if raw_genres is PackedStringArray:
        var packed: PackedStringArray = raw_genres as PackedStringArray
        for packed_index: int in range(packed.size()):
            genre_labels.append(String(packed[packed_index]))
    elif raw_genres is Array:
        var genre_array: Array = raw_genres as Array
        for genre_array_index: int in range(genre_array.size()):
            genre_labels.append(String(genre_array[genre_array_index]))
    if genre_labels.size() > 0:
        var first_id: int = _resolve_genre_tag_to_id3_int(genre_labels[0])
        _set_genre_picker_by_id3_id(_genre_pickers[0], first_id)
        for extra_index: int in range(1, genre_labels.size()):
            _spawn_genre_picker_if_needed()
            if extra_index < _genre_pickers.size():
                var next_id: int = _resolve_genre_tag_to_id3_int(genre_labels[extra_index])
                _set_genre_picker_by_id3_id(_genre_pickers[extra_index], next_id)


func _sync_dropdowns_from_text() -> void:
    var artist_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName") as LineEdit
    var album_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName") as LineEdit
    if artist_edit == null or _choose_artist_opt == null:
        return
    var artist_text: String = artist_edit.text.strip_edges()
    for artist_item_index: int in range(_choose_artist_opt.item_count):
        var artist_meta: Variant = _choose_artist_opt.get_item_metadata(artist_item_index)
        if artist_meta is Artist:
            var from_dropdown: Artist = artist_meta as Artist
            if String(from_dropdown.Artist_Name) == artist_text:
                _choose_artist_opt.select(artist_item_index)
                break
    if album_edit != null and _choose_album_opt != null:
        var album_text: String = album_edit.text.strip_edges()
        for album_item_index: int in range(_choose_album_opt.item_count):
            var album_meta: Variant = _choose_album_opt.get_item_metadata(album_item_index)
            if album_meta is Album:
                var album_from_dropdown: Album = album_meta as Album
                if String(album_from_dropdown.Album_Name) == album_text:
                    _choose_album_opt.select(album_item_index)
                    break


func _reset_genre_pickers_to_unknown() -> void:
    while _genre_pickers.size() > 1:
        var removed_picker: OptionButton = _genre_pickers.pop_back() as OptionButton
        if is_instance_valid(removed_picker):
            removed_picker.queue_free()
    _refresh_all_genre_dropdowns()
    _set_genre_picker_by_id3_id(_genre_pickers[0], GENRE_OPTION_ID_NONE)


func _set_genre_picker_by_id3_id(genre_option: OptionButton, id3_genre_id: int) -> void:
    if genre_option == null:
        return
    genre_option.set_block_signals(true)
    for item_index: int in range(genre_option.item_count):
        if genre_option.get_item_id(item_index) == id3_genre_id:
            genre_option.select(item_index)
            genre_option.set_block_signals(false)
            return
    genre_option.select(0)
    genre_option.set_block_signals(false)


func _selected_id3_genre_ids_excluding(genre_option: OptionButton) -> Array[int]:
    var taken_ids: Array[int] = []
    for picker_index: int in range(_genre_pickers.size()):
        var candidate: OptionButton = _genre_pickers[picker_index]
        if candidate == genre_option:
            continue
        var other_selected_id: int = candidate.get_item_id(candidate.selected)
        if other_selected_id != GENRE_OPTION_ID_NONE:
            taken_ids.append(other_selected_id)
    return taken_ids

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        _fill_choose_artist_dropdown()
        _fill_choose_album_dropdown()
        _fill_music_key_dropdowns()
        if _pending_song != null:
            _select_music_key_dropdowns(_pending_song.Track_Key_Note, _pending_song.Track_Scale)
        _refresh_all_genre_dropdowns()
        
func _refresh_all_genre_dropdowns() -> void:
    for picker_index: int in range(_genre_pickers.size()):
        var genre_option: OptionButton = _genre_pickers[picker_index]
        genre_option.set_block_signals(true)
        genre_option.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
        var current_selection_id: int = genre_option.get_item_id(genre_option.selected)
        var exclude_ids: Array[int] = _selected_id3_genre_ids_excluding(genre_option)
        genre_option.clear()
        genre_option.add_item(tr("KEY_GENRE_UNKNOWN"), GENRE_OPTION_ID_NONE)
        for row_index: int in range(_id3_genre_catalog_rows.size()):
            var row: Dictionary = _id3_genre_catalog_rows[row_index]
            var catalog_id: int = int(row.get("id", GENRE_OPTION_ID_NONE))
            var label_text: String = String(row.get("label", ""))
            if catalog_id in exclude_ids and catalog_id != current_selection_id:
                continue
            genre_option.add_item(label_text, catalog_id)
        var found_match: bool = false
        for rebuild_index: int in range(genre_option.item_count):
            if genre_option.get_item_id(rebuild_index) == current_selection_id:
                genre_option.select(rebuild_index)
                found_match = true
                break
        if not found_match:
            genre_option.select(0)
        genre_option.set_block_signals(false)


func _on_any_genre_selected(_unused_item_index: int, genre_option: OptionButton) -> void:
    var selected_genre_id: int = genre_option.get_item_id(genre_option.selected)
    var picker_slot_index: int = _genre_pickers.find(genre_option)

    if picker_slot_index > 0 and selected_genre_id == GENRE_OPTION_ID_NONE:
        _genre_pickers.remove_at(picker_slot_index)
        genre_option.queue_free()
        _refresh_all_genre_dropdowns()
        return

    _refresh_all_genre_dropdowns()

    var last_picker: OptionButton = _genre_pickers[_genre_pickers.size() - 1]
    if genre_option == last_picker and selected_genre_id != GENRE_OPTION_ID_NONE:
        var new_genre_option: OptionButton = OptionButton.new()
        new_genre_option.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        new_genre_option.item_selected.connect(_on_any_genre_selected.bind(new_genre_option))
        _genre_flow.add_child(new_genre_option)
        _genre_pickers.append(new_genre_option)
        _refresh_all_genre_dropdowns()


func _spawn_genre_picker_if_needed() -> void:
    if _genre_pickers.is_empty():
        return
    var new_genre_option: OptionButton = OptionButton.new()
    new_genre_option.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    new_genre_option.item_selected.connect(_on_any_genre_selected.bind(new_genre_option))
    _genre_flow.add_child(new_genre_option)
    _genre_pickers.append(new_genre_option)
    _refresh_all_genre_dropdowns()


func _collect_song_genres() -> Array[EGenre.E_ID3Genres]:
    var id3_ids: Array[EGenre.E_ID3Genres] = []
    for picker_index: int in range(_genre_pickers.size()):
        var genre_option: OptionButton = _genre_pickers[picker_index]
        var selected_id: int = genre_option.get_item_id(genre_option.selected)
        if selected_id == GENRE_OPTION_ID_NONE:
            continue
        if selected_id >= 0 and selected_id <= 193:
            id3_ids.append(selected_id as EGenre.E_ID3Genres)
    return id3_ids


func _on_save_to_library_pressed() -> void:
    var error_message: String = _save_internal()
    var succeeded: bool = error_message.is_empty()
    if succeeded:
        _save_to_library_btn.text = tr("KEY_SONG_ADDED_SUCCESS")
        _reset_form_after_success()
    else:
        _save_to_library_btn.text = tr("KEY_ERROR_WITH_MESSAGE") + ": " + error_message
    await get_tree().create_timer(2.5).timeout
    if is_instance_valid(_save_to_library_btn):
        _save_to_library_btn.text = tr("KEY_SAVE_TO_LIBRARY")


func _save_internal() -> String:
    if _pending_song == null or _pending_audio_path.is_empty():
        return tr("KEY_ERR_NO_SONG")

    var title_edit: LineEdit = _details_container.get_node_or_null("Song Title Row/SongTitleLineEdit") as LineEdit
    if title_edit != null and title_edit.text.strip_edges().length() > 0:
        _pending_song.Song_Title = StringName(title_edit.text.strip_edges())

    var artist_line_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName") as LineEdit
    var artist_choice_id: int = -1
    if _choose_artist_opt != null:
        artist_choice_id = _choose_artist_opt.get_item_id(_choose_artist_opt.selected)

    if artist_choice_id == _artist_id_for_add_new() or artist_choice_id <= 0:
        if artist_line_edit != null and artist_line_edit.text.strip_edges().length() > 0:
            var new_artist_name: StringName = StringName(artist_line_edit.text.strip_edges())
            _pending_song.Main_Artist = Artist.Get_Artist_Resource_By_Name(new_artist_name)
            if _pending_song.Main_Artist == null:
                _pending_song.Main_Artist = _create_or_get_artist(new_artist_name)
            if _pending_song.Main_Artist == null:
                return tr("KEY_ERR_FAILED_ARTIST")
        else:
            return tr("KEY_ERR_ARTIST_EMPTY")
    else:
        var artist_pick: Variant = _choose_artist_opt.get_item_metadata(_choose_artist_opt.selected)
        if artist_pick is Artist:
            _pending_song.Main_Artist = artist_pick as Artist
        else:
            return tr("KEY_ERR_ARTIST_INVALID")

    var album_line_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName") as LineEdit
    var album_choice_id: int = -1
    if _choose_album_opt != null:
        album_choice_id = _choose_album_opt.get_item_id(_choose_album_opt.selected)

    if album_choice_id == _album_id_for_add_new() or album_choice_id <= 0:
        if album_line_edit != null and album_line_edit.text.strip_edges().length() > 0:
            var new_album_name: StringName = StringName(album_line_edit.text.strip_edges())
            _pending_song.Song_Album = Album.Get_Album_Resource_By_Name(new_album_name)
            if _pending_song.Song_Album == null:
                _pending_song.Song_Album = _create_or_get_album(new_album_name)
            if _pending_song.Song_Album == null:
                return tr("KEY_ERR_FAILED_ALBUM")
        else:
            return tr("KEY_ERR_ALBUM_EMPTY")
    else:
        var album_pick: Variant = _choose_album_opt.get_item_metadata(_choose_album_opt.selected)
        if album_pick is Album:
            _pending_song.Song_Album = album_pick as Album
        else:
            return tr("KEY_ERR_ALBUM_INVALID")

    # Persist extracted cover art onto the selected album resource (if the album has none yet).
    if _pending_song.Song_Album != null and _pending_album_artwork_texture != null and _pending_song.Song_Album.Album_Artwork == null:
        _pending_song.Song_Album.Album_Artwork = _pending_album_artwork_texture
        if not _pending_song.Song_Album.resource_path.is_empty():
            var save_album_error: Error = ResourceSaver.save(_pending_song.Song_Album, _pending_song.Song_Album.resource_path)
            if save_album_error != OK:
                push_warning("Add_Track: Could not save Album artwork to %s" % _pending_song.Song_Album.resource_path)

    var bpm_edit: LineEdit = _row2.get_node_or_null("BPM") as LineEdit
    if bpm_edit != null and bpm_edit.text.strip_edges().is_valid_float():
        _pending_song.Track_BPM = bpm_edit.text.strip_edges().to_float()

    var sidenote_edit: TextEdit = _row2.get_node_or_null("BPM3") as TextEdit
    if sidenote_edit != null:
        _pending_song.User_Sidenote = sidenote_edit.text.strip_edges()

    if _music_key_note_option != null:
        _pending_song.Track_Key_Note = EMusicKey.m_notes_str_to_m_notes_enum(_music_key_note_option.get_item_text(_music_key_note_option.selected))
    if _music_key_scale_option != null:
        _pending_song.Track_Scale = EMusicKey.m_scales_str_to_m_scales_enum(_music_key_scale_option.get_item_text(_music_key_scale_option.selected))
    _pending_song.Refresh_Music_Key()

    _pending_song.Song_Genres = _collect_song_genres()

    var audio_stream_to_validate: AudioStream = _pending_song.get_audio_stream()
    if audio_stream_to_validate == null:
        return tr("KEY_ERR_IMPORT_AUDIO")

    var safe_name: String = String(_pending_song.Song_Title)
    safe_name = safe_name.replace("/", "-").replace("\\", "-").strip_edges()
    if safe_name.is_empty():
        safe_name = "Untitled"
    safe_name = _sanitize_resource_filename(safe_name)
    var save_dir: String
    if Engine.is_editor_hint():
        save_dir = Song.ROOT_MUSIC_DIR
    else:
        save_dir = Song.USER_SONG_METADATA_DIR
        DirAccess.make_dir_recursive_absolute(save_dir)
    var save_path: String = "%s%s.tres" % [save_dir, safe_name]
    var base_path: String = save_path.get_basename()
    var suffix_counter: int = 0
    while FileAccess.file_exists(save_path) or (save_path.begins_with("res://") and ResourceLoader.exists(save_path)):
        suffix_counter += 1
        save_path = "%s_%d.tres" % [base_path, suffix_counter]

    var save_result: Error = ResourceSaver.save(_pending_song, save_path)
    if save_result != OK:
        var output: String = tr("KEY_ERR_SAVE_FAILED") + ": " + str(save_result)
        return output

    _refresh_artist_album_lists()
    _fill_choose_artist_dropdown()
    _fill_choose_album_dropdown()
    _refresh_librebox_track_selections()
    return ""


func _reset_form_after_success() -> void:
    _pending_song = null
    _pending_audio_path = ""
    _pending_album_artwork_texture = null
    if _album_art_rect != null and _default_album_art != null:
        _album_art_rect.texture = _default_album_art
    var title_edit: LineEdit = _details_container.get_node_or_null("Song Title Row/SongTitleLineEdit") as LineEdit
    if title_edit != null:
        title_edit.text = ""
    var artist_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName") as LineEdit
    if artist_edit != null:
        artist_edit.text = ""
    var album_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName") as LineEdit
    if album_edit != null:
        album_edit.text = ""
    var bpm_edit: LineEdit = _row2.get_node_or_null("BPM") as LineEdit
    if bpm_edit != null:
        bpm_edit.text = ""
    var user_note: TextEdit = _row2.get_node_or_null("BPM3") as TextEdit
    if user_note != null:
        user_note.text = ""
    if _choose_artist_opt != null:
        _choose_artist_opt.select(0)
    if _choose_album_opt != null:
        _choose_album_opt.select(0)
    _reset_genre_pickers_to_unknown()
    _select_music_key_dropdowns(EMusicKey.m_notes_enum.C, EMusicKey.m_scales_enum.UNKNOWN)


func _refresh_librebox_track_selections() -> void:
    LibreBox.refresh_both_track_selection_lists()


## Kept for external callers
func save_current_song_to_library() -> bool:
    return _save_internal().is_empty()


func _create_or_get_artist(name_str: StringName) -> Artist:
    var artist: Artist = Artist.new()
    artist.Artist_Name = name_str
    var safe_filename: String = _sanitize_resource_filename(String(name_str))
    var artist_path: String
    if Engine.is_editor_hint():
        var editor_dir: String = "res://Music/Artists"
        artist_path = "%s/%s_Artist.tres" % [editor_dir, safe_filename]
        DirAccess.make_dir_recursive_absolute(editor_dir + "/")
    else:
        var user_dir: String = "user://Music/Artists"
        artist_path = "%s/%s_Artist.tres" % [user_dir, safe_filename]
        DirAccess.make_dir_recursive_absolute(user_dir + "/")
    var save_error: Error = ResourceSaver.save(artist, artist_path)
    if save_error != OK:
        return null
    return ResourceLoader.load(artist_path) as Artist


func _create_or_get_album(name_str: StringName) -> Album:
    var album: Album = Album.new()
    album.Album_Name = name_str
    if _pending_song.Main_Artist != null:
        album.Album_Artist = _pending_song.Main_Artist
    var safe_filename: String = _sanitize_resource_filename(String(name_str))
    var album_path: String
    if Engine.is_editor_hint():
        var editor_dir: String = "res://Music/Albums"
        album_path = "%s/%s_Album.tres" % [editor_dir, safe_filename]
        DirAccess.make_dir_recursive_absolute(editor_dir + "/")
    else:
        var user_dir: String = "user://Music/Albums"
        album_path = "%s/%s_Album.tres" % [user_dir, safe_filename]
        DirAccess.make_dir_recursive_absolute(user_dir + "/")
    var save_error: Error = ResourceSaver.save(album, album_path)
    if save_error != OK:
        return null
    return ResourceLoader.load(album_path) as Album


func _sanitize_resource_filename(raw_name: String) -> String:
    var sanitized: String = raw_name.strip_edges()
    sanitized = sanitized.replace("/", "-").replace("\\", "-")
    sanitized = sanitized.replace(" ", "_")

    # Replace any character that isn't a safe filename char.
    var invalid_char_regex: RegEx = RegEx.new()
    invalid_char_regex.compile("[^A-Za-z0-9_-]")
    sanitized = invalid_char_regex.sub(sanitized, "_", true)

    sanitized = sanitized.strip_edges()
    if sanitized.is_empty():
        sanitized = "Unknown"
    return sanitized
