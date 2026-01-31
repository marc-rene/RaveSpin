@tool
class_name AudioTrack extends Object
 

static var All_Track_UID : Array[int]
static var Next_Available_UID = 7

var UID : int

@export var Audio_File : AudioStream 
static var All_Audio_Files : Dictionary[int, AudioStream]

@export var Track_Title : String
static var All_Track_Titles : Dictionary[int, String]

@export var Track_Artist : StringName
static var All_Track_Artists : Dictionary[int, StringName]

@export var Track_Album : StringName
static var All_Track_Albums : Dictionary[int, StringName]
static var Album_Arts : Dictionary[StringName, Texture2D]

@export var Track_Genres : Array[StringName]
static var All_Track_Genres : Dictionary[int, Array]

@export var Track_BPM : float
static var All_Track_BPMs : Dictionary[int, float]

@export var Track_Runtime_ms : int
# Dont need a tracker for this because we can defer this from All_Audio_Files.length()

@export var Track_Key_Note : MusicKey.m_notes_enum
@export var Track_Scale : MusicKey.m_scales_enum
var Track_Key : MusicKey

static var All_Track_Keys : Dictionary[int, MusicKey]

@export var Favourite : bool
static var All_Favourites : Array[int]

@export_tool_button("Set Details from AudioStream file", "Callable") 
var attempt_populate = Attempt_Automatic_Data_Fill_From_Audio_File

func Attempt_Automatic_Data_Fill_From_Audio_File():
    print("Attempting grab data from file")
    if Audio_File == null:
        return false
    Track_Runtime_ms = Audio_File.get_length() * 1000
    
    if Audio_File.is_class("AudioStreamWAV") == false:
        Track_BPM = Audio_File.get_bpm()
        
    if Audio_File.is_class("AudioStreamMP3"):
        print("That's all we can get from an MP3")
        return false
        
    print("Discovered meta data for ", Track_Title, " : ", Audio_File.tags)
    Track_Title = Audio_File.tags["title"]
    Track_Artist = Audio_File.tags["artist"]
    Track_Album = Audio_File.tags["album"]
    #Track_Genres = Audio_File.get_meta("")
    #Track_Key = Audio_File.get_meta("")
    
    return true
    
    
# TODO: When we manually select a new Audio stream, make the other vars update automaticallty
func _validate_property(property: Dictionary):
    print("Checking %s" % property.name)
    if (property.name == &"Audio File") and (Track_Title == null):
        Attempt_Automatic_Data_Fill_From_Audio_File()
    
    
func _init( p_audio_file : AudioStream = null,
            p_track_title : String = "NA",
            p_track_artist : StringName = "NA",
            p_track_album : StringName = "NA",
            p_track_genres : Array[StringName] = [],
            p_track_bpm : float = 0,
            p_track_key : MusicKey = MusicKey.Make_with_Enum(0,0)):
    Audio_File = p_audio_file
    Track_Title = p_track_title.to_upper().strip_escapes().strip_edges()
    Track_Artist = p_track_artist.to_upper().strip_escapes().strip_edges()
    Track_Album = p_track_album
    
    for genre in p_track_genres:
        # is unique? 
        if not Track_Genres.has(genre.to_upper().strip_escapes().strip_edges()):
            Track_Genres.append(genre.to_upper().strip_escapes().strip_edges())
    
    Track_BPM = p_track_bpm
    Track_Runtime_ms = int(p_audio_file.get_length() * 1000) 
    Track_Key = p_track_key
    Favourite = false

    UID = Next_Available_UID
    Next_Available_UID += 1
    
    All_Audio_Files[UID] = Audio_File
    All_Track_Titles[UID] = Track_Title
    All_Track_Artists[UID] = Track_Artist
    All_Track_Albums[UID] = Track_Album
    All_Track_Genres[UID] = Track_Genres
    All_Track_BPMs[UID] = Track_BPM
    All_Track_Keys[UID] = Track_Key


func Set_Favourite(We_Like = true):
    if We_Like and (All_Favourites.has(UID) == false):   
        All_Favourites.append(UID)
    elif We_Like == false:
        All_Favourites.erase(UID)
        

func _exit_tree() -> void:
    All_Audio_Files.erase(UID)
    All_Track_Titles.erase(UID)
    All_Track_Artists.erase(UID)
    All_Track_Albums.erase(UID)
    All_Track_Genres.erase(UID) 
    All_Track_BPMs.erase(UID)
    All_Track_Keys.erase(UID)
    All_Favourites.erase(UID)
