@tool
class_name Song
extends Resource

# Where will all of our Music Metadatas be saved to?
const ROOT_MUSIC_DIR = "res://Music/Song Metadatas/"
## User-imported songs (Add Track on device) save .tres here so they persist on Quest/Android.
const USER_SONG_METADATA_DIR: String = "user://Music/"

# Name??
@export var Song_Title: StringName


# Who 'owns' this song? Even if it was a collab
@export var Main_Artist: Artist


# Who was featured on this song too?
@export var Guest_Artists: Array[Artist]


# Which Album does this song belong to? 
# Singles will still have an Album of the same name
@export var Song_Album: Album


# Genres that describe this song
## Done in Ints, use Int_to_Id3Genre_str() to get the Genre Display
@export var Song_Genres: Array[EGenre.E_ID3Genres]

static func Id3_to_DisplayTitle(Genre_ID : int) -> String:
    if Genre_ID == 192:
        return MusicMetadataTools.ID3_GENRE_IDS.get('CR')
    elif Genre_ID == 193:
        return MusicMetadataTools.ID3_GENRE_IDS.get('RX')
    else:
        return MusicMetadataTools.ID3_GENRE_IDS.get(str(Genre_ID), "N/A")
    
    

# What's the actual data for this song? Its MP3/WAV file 
@export var Audio_File: AudioStream
## For user-imported songs (Add Local): path to the file under user:// so it persists.
## When set, get_audio_stream() loads from this path if Audio_File is null.
@export var Audio_File_Path: String
@export var Audio_File_Waveform: Texture2D

# How many Beats Per Minute for this song?
@export var Track_BPM: float


# Whats the root note for this song (if it has multiple I recommend just choose any)
@export var Track_Key_Note: EMusicKey.m_notes_enum


# Is this a Major, Minor, Diminished SOng? If it switches just choose what you think is the most common
@export var Track_Scale: EMusicKey.m_scales_enum


# Derived from Track_Key_Note & Track_Scale
var Track_Key: EMusicKey = EMusicKey.new(Track_Key_Note, Track_Scale)

# Sometimes Track_Key doesn't updated properly with Track_Key_Note & Track_Scale
func Refresh_Music_Key():
    Track_Key = EMusicKey.new(Track_Key_Note, Track_Scale)

# Where did you get this song from? (ONLY LOCAL IS SUPPORTED FOR NOW)
@export var Song_Origin_Platform: ETrackOrigins.Track_Origins_enum


# Well... is it?
@export var Favourite: bool


# Extra information about the song...A personal note
@export var User_Sidenote : String


# This will make future Metadata retrieval easier
@export var MusicBrainz_ID: StringName


## Returns the playable stream: Audio_File if set, otherwise loads from Audio_File_Path (user imports).
func get_audio_stream() -> AudioStream:
    if Audio_File != null:
        return Audio_File
    if Audio_File_Path.is_empty():
        return null
    var ext : String = Audio_File_Path.get_extension().to_lower()
    if ext == "mp3":
        return AudioStreamMP3.load_from_file(Audio_File_Path)
    if ext == "wav":
        # AudioStreamWAV.data is not "whole WAV file bytes".
        # Use the provided decoder to interpret WAV headers/encoding correctly.
        var bytes: PackedByteArray = FileAccess.get_file_as_bytes(Audio_File_Path)
        if bytes.is_empty():
            return null
        return AudioStreamWAV.load_from_buffer(bytes)
    if ext == "ogg":
        # Same rationale as WAV: load and decode via the built-in importer.
        var bytes: PackedByteArray = FileAccess.get_file_as_bytes(Audio_File_Path)
        if bytes.is_empty():
            return null
        return AudioStreamOggVorbis.load_from_buffer(bytes)
    return null

func Attempt_Find_waveform() -> bool:
    # The waveform is expected to be the same name as our audio file
    # but with _WAVEFORM at the end, in the same folder.
    if Audio_File == null:
        push_warning("Attempt_Find_waveform: Audio_File is null.")
        return false

    var audio_res_path: String = Audio_File.resource_path
    if audio_res_path.is_empty():
        push_warning("Attempt_Find_waveform: Audio_File has no resource_path (is it saved as a file asset?).")
        return false

    var dir := audio_res_path.get_base_dir()
    var file_name := audio_res_path.get_file().get_basename() # without extension
    var waveform_path := "%s/%s_WAVEFORM.png" % [dir, file_name]

    if not ResourceLoader.exists(waveform_path):
        push_warning("Attempt_Find_waveform: Could not find waveform texture at %s" % waveform_path)
        return false

    var tex: Resource = load(waveform_path)
    if tex is Texture2D:
        Audio_File_Waveform = tex as Texture2D
        print("Attempt_Find_waveform: Set Audio_File_Waveform to ", waveform_path)
        return true
    else:
        push_warning("Attempt_Find_waveform: Resource at %s is not a Texture2D." % waveform_path)
        return false
    
@export_tool_button("Set Waveform from file", "Callable") 
var attempt_find_waveform_texture = Attempt_Find_waveform


## Attempts to load the generated `*_WAVEFORM.png` from next to `Audio_File_Path`.
## This is useful for user-imported songs where `Audio_File` is null.
func Attempt_Find_waveform_from_audio_file_path() -> bool:
    if Audio_File_Waveform != null:
        return true
    if Audio_File_Path.is_empty():
        return false

    var base_dir: String = Audio_File_Path.get_base_dir()
    var base_name: String = Audio_File_Path.get_file().get_basename()
    var candidate_base_names: Array[String] = [base_name, _sanitize_waveform_base_name(base_name)]
    var candidate_global_paths: Array[String] = []

    for candidate_index: int in range(candidate_base_names.size()):
        var candidate_base: String = candidate_base_names[candidate_index]
        var near_audio: String = "%s/%s_WAVEFORM.png" % [base_dir, candidate_base]
        candidate_global_paths.append(ProjectSettings.globalize_path(near_audio))

        var in_waveforms: String = "user://waveforms/%s_WAVEFORM.png" % candidate_base
        candidate_global_paths.append(ProjectSettings.globalize_path(in_waveforms))

    var found_global_path: String = ""
    for path_index: int in range(candidate_global_paths.size()):
        if FileAccess.file_exists(candidate_global_paths[path_index]):
            found_global_path = candidate_global_paths[path_index]
            break

    if found_global_path.is_empty():
        # Extra Android check: external app-specific storage (readable via adb):
        # /storage/emulated/0/Android/data/<package>/files/...
        for path_index: int in range(candidate_global_paths.size()):
            var external_global_waveform_path: String = _android_external_files_fallback(candidate_global_paths[path_index])
            if not external_global_waveform_path.is_empty() and FileAccess.file_exists(external_global_waveform_path):
                found_global_path = external_global_waveform_path
                break

    if found_global_path.is_empty():
        # Extra Android check: alternate internal folder layout /data/<package>/files/...
        for path_index: int in range(candidate_global_paths.size()):
            var alt_internal: String = _android_alt_internal_files_fallback(candidate_global_paths[path_index])
            if not alt_internal.is_empty() and FileAccess.file_exists(alt_internal):
                found_global_path = alt_internal
                break

    if found_global_path.is_empty():
        print("Song: waveform PNG missing: %s" % ProjectSettings.globalize_path("%s/%s_WAVEFORM.png" % [base_dir, base_name]))
        return false

    var loaded_image: Image = Image.load_from_file(found_global_path)
    if loaded_image == null:
        print("Song: waveform PNG load failed: %s" % found_global_path)
        return false

    var loaded_texture: ImageTexture = ImageTexture.create_from_image(loaded_image)
    Audio_File_Waveform = loaded_texture as Texture2D
    print("Song: waveform PNG loaded: %s" % found_global_path)
    return true


func _sanitize_waveform_base_name(raw_base_name: String) -> String:
    var sanitized: String = raw_base_name.strip_edges()
    sanitized = sanitized.replace("%", "_")
    sanitized = sanitized.replace(":", "_")
    sanitized = sanitized.replace("/", "_")
    sanitized = sanitized.replace("\\", "_")
    sanitized = sanitized.replace(" ", "_")
    while sanitized.contains("__"):
        sanitized = sanitized.replace("__", "_")
    sanitized = sanitized.strip_edges()
    if sanitized.is_empty():
        sanitized = "ImportedSong"
    return sanitized


func _android_external_files_fallback(internal_global_path: String) -> String:
    if not OS.has_feature("android"):
        return ""
    # Try to map: /data/data/<pkg>/files/<rel> -> /storage/emulated/0/Android/data/<pkg>/files/<rel>
    # We do not reliably know <pkg> at runtime without Android APIs, but we can extract it if present.
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



func _ready():
    if Track_Key == null and Track_Key_Note != null and Track_Scale == null:
        Track_Key = EMusicKey.new(Track_Key_Note, Track_Scale)
    
## @deprecated
func Attempt_Automatic_Data_Fill_From_Audio_File():
    print("Attempting grab data from file")
    if Audio_File == null:
        return false

    if Audio_File.is_class("AudioStreamWAV") == false:
        Track_BPM = Audio_File.get_bpm()
        
    if Audio_File.is_class("AudioStreamMP3"):
        print("That's all we can get from an MP3")
        return false
    
    Song_Title = Audio_File.resource_name

    print("Discovered meta data for ", Song_Title, " : ", Audio_File.tags)
    
    Song_Title = Audio_File.tags["title"]
    var track_artist_str = Audio_File.tags["artist"]
    Main_Artist = Artist.Get_Artist_Resource_By_Name(track_artist_str)

    var track_album_str = Audio_File.tags["album"]
    Song_Album = Album.Get_Album_Resource_By_Name(track_album_str)
    
    User_Sidenote = Audio_File.tags["comment"]
    
    
@export_tool_button("Set Details from AudioStream file", "Callable") 
var attempt_populate = Attempt_Automatic_Data_Fill_From_Audio_File


func _to_string() -> String:
    return Song_Title + " - " + Song_Album.Album_Name + " - " + Main_Artist.Artist_Name

#func _init( p_audio_file : AudioStream = null,
            #p_track_title : String = "N/A",
            #p_track_artist : Artist = null,
            #p_track_album : Album = null,
            #p_track_genres : Array[EGenre.m_MusicGenres_enum] = [],
            #p_track_bpm : float = 0,
            #p_track_key : EMusicKey = EMusicKey.new(),
            #p_user_note : String = "N/A",
            #p_track_origin : ETrackOrigins.Track_Origins_enum = ETrackOrigins.Track_Origins_enum.OTHER,
            #p_MusicBrainz_ID = "N/A"
            #):
    #Audio_File = p_audio_file
    #Song_Title = p_track_title.to_upper().strip_escapes().strip_edges()
    #Main_Artist = p_track_artist.to_upper().strip_escapes().strip_edges()
    #Song_Album = p_track_album
    #
    #for genre in p_track_genres:
        ## is unique? 
        #if not Song_Genres.has(genre):
            #Song_Genres.append(genre)
            #
    #Track_BPM = p_track_bpm
    #Track_Key = p_track_key
    #Track_Key_Note = p_track_key.m_note_index
    #Track_Scale = p_track_key.m_scale_index
    #
    #Favourite = false
    #User_Sidenote = p_user_note
    #Song_Origin_Platform = p_track_origin

        
        
# Get paths to all song metadata .tres under res:// and user:// (no guaranteed order).
static func Get_All_Song_Paths() -> PackedStringArray:
    var paths: PackedStringArray = PackedStringArray()
    if DirAccess.dir_exists_absolute(ROOT_MUSIC_DIR):
        for entry_name: String in ResourceLoader.list_directory(ROOT_MUSIC_DIR):
            if entry_name.ends_with(".tres"):
                paths.append(ROOT_MUSIC_DIR.path_join(entry_name))
    DirAccess.make_dir_recursive_absolute(USER_SONG_METADATA_DIR)
    if DirAccess.dir_exists_absolute(USER_SONG_METADATA_DIR):
        var user_dir: DirAccess = DirAccess.open(USER_SONG_METADATA_DIR)
        if user_dir != null:
            user_dir.list_dir_begin()
            var user_entry: String = user_dir.get_next()
            while user_entry != "":
                if (not user_dir.current_is_dir()) and user_entry.ends_with(".tres"):
                    paths.append(USER_SONG_METADATA_DIR.path_join(user_entry))
                user_entry = user_dir.get_next()
            user_dir.list_dir_end()
    return paths


## Deletes a user-imported song: the `.tres` metadata file, optional `Audio_File_Path` under `user://`,
## and a waveform PNG next to the audio if present. Built-in `res://` library tracks are not removable at runtime.
static func try_delete_song_at_metadata_path(metadata_resource_path: String) -> Dictionary:
    var result: Dictionary = {
        "ok": false,
        "message": "",
    }
    if metadata_resource_path.is_empty() or not metadata_resource_path.ends_with(".tres"):
        result["message"] = "Invalid song file path."
        return result
    if metadata_resource_path.begins_with("res://"):
        result["message"] = "Built-in tracks cannot be removed."
        return result
    if not metadata_resource_path.begins_with("user://"):
        result["message"] = "Only user-imported tracks can be removed."
        return result
    if not FileAccess.file_exists(metadata_resource_path):
        result["message"] = "Song file is already gone."
        return result

    var song_to_remove: Song = load(metadata_resource_path) as Song
    if song_to_remove == null:
        result["message"] = "Could not load song data."
        return result

    var audio_path: String = String(song_to_remove.Audio_File_Path).strip_edges()
    if audio_path.begins_with("user://") and FileAccess.file_exists(audio_path):
        var waveform_png_path: String = "%s/%s_WAVEFORM.png" % [
            audio_path.get_base_dir(),
            audio_path.get_file().get_basename(),
        ]
        if FileAccess.file_exists(waveform_png_path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(waveform_png_path))
        DirAccess.remove_absolute(ProjectSettings.globalize_path(audio_path))

    var remove_err: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(metadata_resource_path))
    if remove_err != OK:
        result["message"] = "Failed to delete metadata (%d)." % remove_err
        return result

    result["ok"] = true
    result["message"] = "Removed."
    return result
