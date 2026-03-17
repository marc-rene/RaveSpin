extends PanelContainer
class_name Add_Track

## "Add local song" flow: native file picker -> copy to user:// -> extract metadata -> populate form.
## Spotify/others will be handled later (persisted credentials, etc.).

var _file_dialog: FileDialog
var _pending_song: Song  # Current import; used when saving to library
var _pending_audio_path: String  # user:// path after copy

@onready var _add_local_btn: Button = %Add_Local_Song_btn
@onready var _save_to_library_btn: Button = %"Save to library btn"
@onready var _details_container: VBoxContainer = $"PanelContainer/GridContainer/Row 1/Details input container"
@onready var _row2: HBoxContainer = $"PanelContainer/GridContainer/Row 2"

@onready var Parent_XR_2D_3D_Node : XRToolsViewport2DIn3D = $"../.."

func close_window():
    Parent_XR_2D_3D_Node.position.y = 10.0
    Parent_XR_2D_3D_Node.set_enabled(false)


func _ready() -> void:
    _setup_file_dialog()
    if _add_local_btn:
        _add_local_btn.pressed.connect(_on_add_local_song_pressed)
    if _save_to_library_btn:
        _save_to_library_btn.pressed.connect(_on_save_to_library_pressed)
    $"PanelContainer/GridContainer/HBoxContainer/Close btn".pressed.connect(close_window)


func _on_save_to_library_pressed() -> void:
    if save_current_song_to_library():
        # Optional: clear form or show success
        pass


func _setup_file_dialog() -> void:
    _file_dialog = FileDialog.new()
    _file_dialog.size = Parent_XR_2D_3D_Node.viewport_size
    _file_dialog.title = "Choose an audio file (MP3 / WAV / OGG)"
    _file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    _file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    _file_dialog.filters = PackedStringArray([
        "*.mp3 ; MP3",
        "*.wav ; WAV",
        "*.ogg ; OGG Vorbis",
    ])
    _file_dialog.file_selected.connect(_on_audio_file_selected)
    add_child(_file_dialog)


func _on_add_local_song_pressed() -> void:
    if _file_dialog:
        _file_dialog.popup_centered_ratio(0.6)


func _on_audio_file_selected(selected_path: String) -> void:
    # Copy to user:// so we have a stable path that persists across runs
    var dest_path: String = AudioMetadata.copy_to_user_imports(selected_path)
    if dest_path.is_empty():
        push_error("Add Track: Failed to copy file to user imports.")
        return

    var meta: Dictionary = AudioMetadata.extract_from_path(dest_path)

    # Build Song resource for this import (Audio_File_Path = user:// path)
    _pending_song = Song.new()
    _pending_song.Audio_File_Path = dest_path
    _pending_song.Song_Title = StringName(meta.get("title", selected_path.get_file().get_basename()))
    _pending_song.Track_BPM = meta.get("bpm", 0.0) as float
    _pending_song.User_Sidenote = meta.get("comment", "")
    _pending_song.Song_Origin_Platform = ETrackOrigins.Track_Origins_enum.LOCAL_STORAGE
    _pending_audio_path = dest_path

    _populate_form_from_metadata(meta)


func _populate_form_from_metadata(meta: Dictionary) -> void:
    # Song title
    var title_edit: LineEdit = _details_container.get_node_or_null("Song Title Row/SongTitleLineEdit")
    if title_edit:
        title_edit.text = meta.get("title", "")

    # New artist name (LineEdit under "New Artist Name")
    var artist_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName")
    if artist_edit:
        artist_edit.text = meta.get("artist", "")

    # New album name (LineEdit under "New Album Name")
    var album_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName")
    if album_edit:
        album_edit.text = meta.get("album", "")

    # BPM and user note (Row 2)
    var bpm_edit: LineEdit = _row2.get_node_or_null("BPM")
    if bpm_edit:
        var bpm_val: float = meta.get("bpm", 0.0) as float
        bpm_edit.text = str(int(bpm_val)) if bpm_val > 0 else ""

    var sidenote_edit: TextEdit = _row2.get_node_or_null("BPM3")
    if sidenote_edit:
        sidenote_edit.text = meta.get("comment", "")


## Call this when you add a "Save to library" or "Add song" button to persist the current form into a Song .tres.
## Creates/finds Artist and Album by name, saves the Song to Song.ROOT_MUSIC_DIR.
func save_current_song_to_library() -> bool:
    if _pending_song == null or _pending_audio_path.is_empty():
        push_warning("Add Track: No pending song to save. Pick a file first.")
        return false

    # Read form back into _pending_song
    var title_edit: LineEdit = _details_container.get_node_or_null("Song Title Row/SongTitleLineEdit")
    if title_edit and title_edit.text.strip_edges().length() > 0:
        _pending_song.Song_Title = StringName(title_edit.text.strip_edges())

    var artist_edit: LineEdit = _details_container.get_node_or_null("New Artist Name/New ArtistName")
    if artist_edit and artist_edit.text.strip_edges().length() > 0:
        var name_str: StringName = StringName(artist_edit.text.strip_edges())
        _pending_song.Main_Artist = Artist.Get_Artist_Resource_By_Name(name_str)
        if _pending_song.Main_Artist == null:
            # Create new Artist resource and save it so it can be found next time
            _pending_song.Main_Artist = _create_or_get_artist(name_str)

    var album_edit: LineEdit = _details_container.get_node_or_null("New Album Name/New ArtistName")
    if album_edit and album_edit.text.strip_edges().length() > 0:
        var name_str: StringName = StringName(album_edit.text.strip_edges())
        _pending_song.Song_Album = Album.Get_Album_Resource_By_Name(name_str)
        if _pending_song.Song_Album == null:
            _pending_song.Song_Album = _create_or_get_album(name_str)

    var bpm_edit: LineEdit = _row2.get_node_or_null("BPM")
    if bpm_edit and bpm_edit.text.strip_edges().is_valid_float():
        _pending_song.Track_BPM = bpm_edit.text.strip_edges().to_float()

    var sidenote_edit: TextEdit = _row2.get_node_or_null("BPM3")
    if sidenote_edit:
        _pending_song.User_Sidenote = sidenote_edit.text.strip_edges()

    # Save Song .tres (editor: res://, exported game: user://)
    var safe_name := _pending_song.Song_Title as String
    safe_name = safe_name.replace("/", "-").replace("\\", "-").strip_edges()
    if safe_name.is_empty():
        safe_name = "Untitled"
    var save_dir: String
    if Engine.is_editor_hint():
        save_dir = Song.ROOT_MUSIC_DIR
    else:
        save_dir = "user://Music/Song Metadatas/"
        DirAccess.make_dir_recursive_absolute(save_dir)
    var save_path := "%s%s.tres" % [save_dir, safe_name]
    # Ensure unique path
    var base_path := save_path.get_basename()
    var counter := 0
    while FileAccess.file_exists(save_path) or (save_path.begins_with("res://") and ResourceLoader.exists(save_path)):
        counter += 1
        save_path = "%s_%d.tres" % [base_path, counter]

    var err := ResourceSaver.save(_pending_song, save_path)
    if err != OK:
        push_error("Add Track: Failed to save song to %s (error %d)" % [save_path, err])
        return false
    print("Add Track: Saved song to ", save_path)
    return true


func _create_or_get_artist(name_str: StringName) -> Artist:
    var artist := Artist.new()
    artist.Artist_Name = name_str
    var safe_name := (name_str as String).replace("/", "-").replace(" ", "_")
    var base_dir: String
    var artist_path: String
    if Engine.is_editor_hint():
        base_dir = "res://Music/Artists"
        artist_path = "%s/%s_Artist.tres" % [base_dir, safe_name]
        DirAccess.make_dir_recursive_absolute(base_dir + "/")
    else:
        base_dir = "user://Music/Artists"
        artist_path = "%s/%s_Artist.tres" % [base_dir, safe_name]
        DirAccess.make_dir_recursive_absolute(base_dir + "/")
    ResourceSaver.save(artist, artist_path)
    return ResourceLoader.load(artist_path) as Artist


func _create_or_get_album(name_str: StringName) -> Album:
    var album := Album.new()
    album.Album_Name = name_str
    if _pending_song.Main_Artist:
        album.Album_Artist = _pending_song.Main_Artist
    var safe_name := (name_str as String).replace("/", "-").replace(" ", "_")
    var base_dir: String
    var album_path: String
    if Engine.is_editor_hint():
        base_dir = "res://Music/Albums"
        album_path = "%s/%s_Album.tres" % [base_dir, safe_name]
        DirAccess.make_dir_recursive_absolute(base_dir + "/")
    else:
        base_dir = "user://Music/Albums"
        album_path = "%s/%s_Album.tres" % [base_dir, safe_name]
        DirAccess.make_dir_recursive_absolute(base_dir + "/")
    ResourceSaver.save(album, album_path)
    return ResourceLoader.load(album_path) as Album
