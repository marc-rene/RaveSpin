class_name AudioTrack extends Node 

static var All_Artists : Array[StringName]
static var All_Albums : Array[StringName]
static var All_Genres : Array[StringName]


var Audio_File : AudioStream    
var Track_Title : String
var Track_Artist : StringName
var Track_Album : StringName
var Track_Genres : Array[StringName]
var Track_BPM : float
var Track_Runtime_ms : int
var Track_Key : EMusicKeys
var Favourite : bool
    
func _init( p_audio_file : AudioStream,
            p_track_title : String,
            p_track_artist : StringName,
            p_track_album : StringName,
            p_track_genres : Array[StringName],
            p_track_bpm : float,
            p_track_key : EMusicKeys) -> void:
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
    Track_Key = p_track_key if _IsValidKey(p_track_key) else 0
