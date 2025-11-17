extends Node3D

@export var Track_1_AudioSource : AudioStream;
@export var Track_2_AudioSource : AudioStream;
@export var Track_3_AudioSource : AudioStream; # Only Tracks 1 & 2 are priority
@export var Track_4_AudioSource : AudioStream;
# Too many issues with Init'ing
#var AudioSourceList : Array[AudioStream] = [Track_1_AudioSource, Track_2_AudioSource, Track_3_AudioSource, Track_4_AudioSource]



@export var Use_2_Track_Bus_Layout = true
var Bus_Layout : AudioBusLayout
@onready var AudioPlayerList = [$"../Track Stream Player Left", 
    $"../Track Stream Player Right", 
    $"../Track Stream Player Left ALT", 
    $"../Track Stream Player Right ALT"]; 



func CheckRange(minimum, maximum, value, function_name = "") -> bool:
    if (value < minimum or value > maximum):
        if (function_name != ""):
            print(function_name, " was given an invalid int, it's only between ", minimum, " and ", maximum)
        else:
            print("Incorrect int given, it's only between ", minimum, " and ", maximum)
        return false
    else:
        return true

       
            
func LoadTrackIntoMemory(p_which_track : int):
    if(CheckRange(0, 3, p_which_track, "LoadTrackIntoMemory")):
        print("Spawned Player for Track ", p_which_track)
        var current_stream : AudioStream;
        match p_which_track:
            0:
                current_stream = Track_1_AudioSource
            1:
                current_stream = Track_2_AudioSource
            2:
                current_stream = Track_3_AudioSource
            3:
                current_stream = Track_4_AudioSource
                
        AudioPlayerList[p_which_track].stream = current_stream
        print("Loading Track ", p_which_track, " into memory now")
    
    
      
func Play_Pause(p_which_track : int):
    if(CheckRange(0, 3, p_which_track, "Play_Pause")):
        var current_player = AudioPlayerList[p_which_track]
        if(current_player.playing):
            print("Pausing Track ", p_which_track)
            current_player.stream_paused = true
        else:
            print("Playing Track ", p_which_track, " now @ ", current_player.get_playback_position())
            current_player.stream_paused = false
            current_player.play(current_player.get_playback_position())



                       

func _ready() -> void:
    LoadTrackIntoMemory(0)
    LoadTrackIntoMemory(1)
    if (Use_2_Track_Bus_Layout == false):
        LoadTrackIntoMemory(2)
        LoadTrackIntoMemory(3)
    #CreateInteractableControl(btn_PausePlay_ref, E_CONTROLTYPE.BUTTON)
    


func _on_left_play_on_activated() -> void:
    Play_Pause(0)


func _on_right_play_on_activated() -> void:
     Play_Pause(1)
