@tool
class_name AudioTrackResource extends Resource
 
## Legacy flat track metadata resource.
## Kept for compatibility with older metadata flows.

@export var Audio_File : AudioStream

@export var Track_Title : String

@export var Track_Artist : StringName

@export var Track_Album : StringName
@export var Track_Album_Art : CompressedTexture2D

@export var Track_Genres : Array[StringName]

@export var Track_BPM : float

## Cached runtime in milliseconds derived from the audio stream length.
# Dont need a tracker for this because we can defer this from All_Audio_Files.length()
var Track_Runtime_ms : int

@export var Track_Key_Note : EMusicKey.m_notes_enum
@export var Track_Scale : EMusicKey.m_scales_enum
var Track_Key : EMusicKey

@export var Track_Origin_Platform : ETrackOrigins.Track_Origins_enum

@export var Favourite : bool

@export var User_Sidenote : String
    

    
    
## Creates a metadata resource from supplied values.
func _init( p_audio_file : AudioStream = null,
            p_track_title : String = "NA",
            p_track_artist : StringName = "NA",
            p_track_album : StringName = "NA",
            p_track_album_art : CompressedTexture2D = null,
            p_track_genres : Array[StringName] = [],
            p_track_bpm : float = 0,
            p_track_key : EMusicKey = EMusicKey.new(),
            p_user_note : String = "N/A",
            p_track_origin : ETrackOrigins.Track_Origins_enum = ETrackOrigins.Track_Origins_enum.OTHER):
    Audio_File = p_audio_file
    Track_Title = p_track_title.to_upper().strip_escapes().strip_edges()
    Track_Artist = p_track_artist.to_upper().strip_escapes().strip_edges()
    Track_Album = p_track_album
    Track_Album_Art = p_track_album_art

    for genre in p_track_genres:
        # is unique? 
        if not Track_Genres.has(genre.strip_edges()):
            Track_Genres.append(genre.strip_edges())
            
    Track_BPM = p_track_bpm
    Track_Runtime_ms = Utility.Return_Valid(int(p_audio_file.get_length() * 1000), 0) 
    Track_Key = p_track_key
    Track_Origin_Platform = p_track_origin
    Favourite = false
    
    if Utility.is_Valid(p_user_note) or p_user_note != "N/A":
        User_Sidenote = p_user_note
