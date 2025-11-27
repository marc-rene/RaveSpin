extends Node3D

@export var Track_1_AudioSource : AudioStream;
@export var Track_2_AudioSource : AudioStream;
@export var Track_3_AudioSource : AudioStream; # Only Tracks 1 & 2 are priority
@export var Track_4_AudioSource : AudioStream;
# Too many issues with Init'ing
#var AudioSourceList : Array[AudioStream] = [Track_1_AudioSource, Track_2_AudioSource, Track_3_AudioSource, Track_4_AudioSource]



@export var Use_2_Track_Bus_Layout = true
var Bus_Layout : AudioBusLayout
@onready var AudioPlayerList : Array[AudioStreamPlayer] = [$"../Track Stream Player Left", 
    $"../Track Stream Player Right", 
    $"../Track Stream Player Left ALT", 
    $"../Track Stream Player Right ALT"]; 
    
@onready var Channel_1_Left_Bus_Index = AudioServer.get_bus_index("Channel 1 Input")
@onready var Channel_2_Right_Bus_Index = AudioServer.get_bus_index("Channel 2 Input")
@onready var Channel_3_LeftALT_Bus_Index = AudioServer.get_bus_index("Channel 3 Input")
@onready var Channel_4_RightALT_Bus_Index = AudioServer.get_bus_index("Channel 4 Input")

@export var Crossfader_Curve_Left : Curve = preload("res://Components/Controls/Crossfade Curve Left.tres")
@export var Crossfader_Curve_Right : Curve = preload("res://Components/Controls/Crossfade Curve Right.tres")
var Channel_Faders = [1.0, 1.0, 1.0, 1.0]
var Crossfade_Alpha = 0.5
var In_Channel_Fader = true

# Default is 10% Tempo Adjust Range
@export var BPM_Adjust_Range = 0.1
var Dirty_Tempos = true


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
        if(current_player.playing == false):
            print("Playing Track ", p_which_track, " now @ ", current_player.get_playback_position())
            current_player.stream_paused = false
            current_player.play(current_player.get_playback_position())
        else:
            print("Pausing Track ", p_which_track)
            current_player.stream_paused = true


                       

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

var In_Crossfade = true

func _on_crossfade_on_activated() -> void:
    In_Crossfade = true
    
func _on_crossfade_on_unhovered() -> void:
    In_Crossfade = false
        



func Update_Channel_DBs():
    # Apply Crossfade
    Crossfade_Alpha = clampf($Controls/Crossfade.Value, 0, 1) # 0 = Left 1 = right
    Channel_Faders[0] = clampf($"Controls/L Channel Fader".Value, 0, 1)
    Channel_Faders[1] = clampf($"Controls/R Channel Fader".Value, 0, 1)
    var left_alpha = (Crossfader_Curve_Left.sample_baked(Crossfade_Alpha) * Channel_Faders[0])
    var right_alpha = (Crossfader_Curve_Right.sample_baked(Crossfade_Alpha) * Channel_Faders[1])
    AudioServer.set_bus_volume_db(Channel_1_Left_Bus_Index, remap(left_alpha, 0, 1, -80, 0))
    AudioServer.set_bus_volume_db(Channel_2_Right_Bus_Index, remap(right_alpha, 0, 1, -80, 0))
    

func Update_Channel_Tempo_Adjusts():
    var Left_adj = $"Controls/L Tempo Adjust".Value
    var Right_adj = $"Controls/R Tempo Adjust".Value
    var tolerance = 0.05
    if (abs(0.5 - Left_adj) < tolerance):
        AudioPlayerList[0].pitch_scale = 1
    else:
        AudioPlayerList[0].pitch_scale = remap(Left_adj, 0, 1, (1.0 - BPM_Adjust_Range), (1.0 + BPM_Adjust_Range))
    
    if (abs(0.5 - Right_adj) < tolerance):
        AudioPlayerList[1].pitch_scale = 1
    else:
        AudioPlayerList[1].pitch_scale = remap(Right_adj, 0, 1, (1.0 - BPM_Adjust_Range), (1.0 + BPM_Adjust_Range))
    
    
    
func _physics_process(delta: float) -> void:
    if(In_Crossfade or In_Channel_Fader):
        Update_Channel_DBs()
    if(Dirty_Tempos):
        Update_Channel_Tempo_Adjusts()
    


func _on_LEFT_channel_fader_on_activated() -> void:
    In_Channel_Fader = true

func _on_LEFT_channel_fader_on_unhovered() -> void:
    In_Channel_Fader = false


func _on_RIGHT_channel_fader_on_activated() -> void:
    In_Channel_Fader = true


func _on_RIGHT_channel_fader_on_unhovered() -> void:
    In_Channel_Fader = false



func _on_LEFT_tempo_adjust_on_activated() -> void:
    Dirty_Tempos = true


func _on_LEFT_tempo_adjust_on_unhovered() -> void:
    Dirty_Tempos = false


func _on_RIGHT_tempo_adjust_on_activated() -> void:
    Dirty_Tempos = true


func _on_RIGHT_tempo_adjust_on_unhovered() -> void:
    Dirty_Tempos = false
