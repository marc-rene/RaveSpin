@tool
class_name Song
extends Resource

# Where will all of our Music Metadatas be saved to?
const ROOT_MUSIC_DIR = "res://Music/Song Metadatas/"

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
@export var Song_Genres: Array[EGenre.m_MusicGenres_enum]


# What's the actual data for this song? Its MP3/WAV file 
@export var Audio_File: AudioStream
@export var Audio_File_Waveform : CompressedTexture2D

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

    var tex := load(waveform_path)
    if tex is CompressedTexture2D:
        Audio_File_Waveform = tex
        print("Attempt_Find_waveform: Set Audio_File_Waveform to ", waveform_path)
        return true
    else:
        push_warning("Attempt_Find_waveform: Resource at %s is not a CompressedTexture2D." % waveform_path)
        return false
    
@export_tool_button("Set Waveform from file", "Callable") 
var attempt_find_waveform_texture = Attempt_Find_waveform



func _ready():
    if Track_Key == null and Track_Key_Note != null and Track_Scale == null:
        Track_Key = EMusicKey.new(Track_Key_Note, Track_Scale)
    

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

        
        
# Get the "Res://..." path to all songs
static func Get_All_Song_Paths() -> PackedStringArray :
    return ResourceLoader.list_directory("res://Music/Song Metadatas/")
