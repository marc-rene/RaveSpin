extends Node3D
class_name DJ_Controller

#@onready var LibreBox_ref : LibreBox = $LibreboxScene
# Too many issues with Init'ing
#var AudioSourceList : Array[AudioStream] = [Track_1_AudioSource, Track_2_AudioSource, Track_3_AudioSource, Track_4_AudioSource]


signal all_ready


static var Controller_Instance : DJ_Controller = null

static func Get_Instance_await() -> DJ_Controller:
    if Controller_Instance == null:
        await Controller_Instance.all_ready
    
    return Controller_Instance
    

static func Get_Instance() -> DJ_Controller:
    return Controller_Instance
      


@export var Use_2_Track_Bus_Layout = true
var Bus_Layout : AudioBusLayout

@onready var AudioPlayerList : Array[AudioStreamPlayer] = [$"../Track Stream Player Left", 
    $"../Track Stream Player Right", 
    $"../Track Stream Player Left ALT", 
    $"../Track Stream Player Right ALT"]; 
    
@onready var Channel_1_Left_Bus_Index = BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_ONE_INPUT)
@onready var Channel_2_Right_Bus_Index = BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_TWO_INPUT)
@onready var Channel_3_LeftALT_Bus_Index = BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_THREE_INPUT)
@onready var Channel_4_RightALT_Bus_Index = BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_FOUR_INPUT)

@export var Crossfader_Curve_Left : Curve = preload("res://Components/Controls/Crossfade Curve Left.tres")
@export var Crossfader_Curve_Right : Curve = preload("res://Components/Controls/Crossfade Curve Right.tres")

static var Channel_Faders = [1.0, 1.0, 1.0, 1.0]
static var Crossfade_Alpha = 0.5
static var In_Channel_Fader = true


# Default is 10% Tempo Adjust Range
@export var BPM_Adjust_Range = 0.1
static var Dirty_Tempos = true
   

static func Get_Track_Playback_Position(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return Utility.Return_Valid(Controller_Instance.AudioPlayerList[which_track].get_playback_position(), 0.0)


    
    

static func Get_Track_Playback_Alpha(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var total_seconds : float = Controller_Instance.AudioPlayerList[which_track].stream.get_length()
    var played_for_seconds : float =  Controller_Instance.AudioPlayerList[which_track].get_playback_position()
    return remap(played_for_seconds, 0.0, total_seconds, 0.0, 1.0)


static func Get_Track_Playback_Player(which_track : int) -> AudioStreamPlayer:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return Controller_Instance.AudioPlayerList[which_track]


func LoadTrackIntoMemory(which_track : int, which_song : Song):
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    print("Spawned Player for Track ", which_track)
    
    AudioPlayerList[which_track].stream = which_song.Audio_File
    print("Loading Track ", which_track, " into memory now")
    
    AudioPlayerList[which_track].stream_paused = true
    
    
      
func Play_Pause(p_which_track : int):
    p_which_track = Utility.Clamp_to_Valid_TrackID(p_which_track)
        
    if(AudioPlayerList[p_which_track].playing == false):
        print("Playing Track ", p_which_track, " now @ ", AudioPlayerList[p_which_track].get_playback_position())
        AudioPlayerList[p_which_track].stream_paused = false
        AudioPlayerList[p_which_track].play(AudioPlayerList[p_which_track].get_playback_position())
    
    else:
        print("Pausing Track ", p_which_track)
        AudioPlayerList[p_which_track].stream_paused = true


                       

func _ready() -> void:
    #LoadTrackIntoMemory(0)
    #LoadTrackIntoMemory(1)
    #if (Use_2_Track_Bus_Layout == false):
        #LoadTrackIntoMemory(2)
        #LoadTrackIntoMemory(3)
    Controller_Instance = self
    AudioPlayerList[0].stream_paused = true
    AudioPlayerList[1].stream_paused = true
    AudioPlayerList[2].stream_paused = true
    AudioPlayerList[3].stream_paused = true
    
    _on_reset_area_area_entered(null)
    all_ready.emit()
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
        


# Adjust Channel Decibel output
func Update_Channel_DBs():
    # Apply Crossfade
    Crossfade_Alpha = clampf($Controls/Crossfade.Value, 0, 1) # 0 = Left 1 = right
    Channel_Faders[0] = clampf($"Controls/L Channel Fader".Value, 0, 1)
    Channel_Faders[1] = clampf($"Controls/R Channel Fader".Value, 0, 1) # TODO: Add [2][3] for Alt decks
    var left_alpha = (Crossfader_Curve_Left.sample_baked(Crossfade_Alpha) * Channel_Faders[0])
    var right_alpha = (Crossfader_Curve_Right.sample_baked(Crossfade_Alpha) * Channel_Faders[1])
    # Update Channel DB based on Crossfader and channel fader
    AudioServer.set_bus_volume_linear(Channel_1_Left_Bus_Index, left_alpha)
    AudioServer.set_bus_volume_linear(Channel_2_Right_Bus_Index, right_alpha)
    

# incase we want to set tempos without using the sliders
func Set_Channel_Tempo(which_track: int, new_tempo: float) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    Ensure_BPM_Adjust_Range_contains(new_tempo)
    AudioPlayerList[which_track].pitch_scale = new_tempo
    manual_change_this_frame = true
    Update_Channel_Tempo_Adjusts()


# Expand BPM_Adjust_Range so it encompasses the given pitch_scale (so sliders can show it)
func Ensure_BPM_Adjust_Range_contains(pitch_value: float) -> void:
    var margin = absf(pitch_value - 1.0)
    if margin > BPM_Adjust_Range:
        BPM_Adjust_Range = margin 


# Adjust BPM/Tempo of our Tracks in range of +-BPM_Adjust_Range 
func Update_Channel_Tempo_Adjusts():
    # Slider positions are driven by current pitch_scale (not the other way around)
    var left_pitch = AudioPlayerList[0].pitch_scale
    var right_pitch = AudioPlayerList[1].pitch_scale
    var tolerance = 0.05
    # Remap pitch_scale (1-BPM_Adjust_Range .. 1+BPM_Adjust_Range) to slider position (0..1)
    var left_min = 1.0 - BPM_Adjust_Range
    var left_max = 1.0 + BPM_Adjust_Range
    var right_min = 1.0 - BPM_Adjust_Range
    var right_max = 1.0 + BPM_Adjust_Range
    # Snap to center (0.5) when close to 1.0
    var left_adj = remap(left_pitch, left_min, left_max, 0.0, 1.0) if abs(1.0 - left_pitch) >= tolerance else 0.5
    var right_adj = remap(right_pitch, right_min, right_max, 0.0, 1.0) if abs(1.0 - right_pitch) >= tolerance else 0.5
    $"Controls/L Tempo Adjust".UpdateAlpha(clampf(left_adj, 0.0, 1.0))
    $"Controls/R Tempo Adjust".UpdateAlpha(clampf(right_adj, 0.0, 1.0))
    # TODO: Do AudioPlayerList[2] + [3]
    

var manual_change_this_frame : bool = false
func _process(delta: float) -> void:
    #if(In_Crossfade or In_Channel_Fader):
    if manual_change_this_frame == false:
        Update_Channel_DBs()
        #if(Dirty_Tempos):
        Update_Channel_Tempo_Adjusts()
    
    # TODO: Change this to a proper UI  
    #var left_status_text = "Song file path: %s\n" % AudioPlayerList[0].stream.resource_path.get_file()
    #var right_status_text = "Song file path: %s\n" % AudioPlayerList[1].stream.resource_path.get_file()
    #left_status_text += "Volume: %.1fdb\n"   % [AudioServer.get_bus_volume_db(Channel_1_Left_Bus_Index)]
    #right_status_text += "Volume: %.1fdb\n"  % [AudioServer.get_bus_volume_db(Channel_2_Right_Bus_Index)]
    #left_status_text += "BPM Multiplier: %.2f\n"  % AudioPlayerList[0].pitch_scale
    #right_status_text += "BPM Multiplier: %.2f\n" % AudioPlayerList[1].pitch_scale
    #
    #$"LEFT Status Text".text = left_status_text
    #$"RIGHT Status Text".text = right_status_text
    $"General Status".text = "Crossfade: %.3f" % remap(Crossfade_Alpha, 0.0, 1.0, -1.0, 1.0)
    manual_change_this_frame = false
    


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


func _on_reset_area_area_entered(area: Area3D) -> void:
    #LoadTrackIntoMemory(0)
    #LoadTrackIntoMemory(1)
    #if (Use_2_Track_Bus_Layout == false):
        #LoadTrackIntoMemory(2)
        #LoadTrackIntoMemory(3)
    AudioPlayerList[0].stream_paused = true
    AudioPlayerList[1].stream_paused = true
    AudioPlayerList[2].stream_paused = true
    AudioPlayerList[3].stream_paused = true
    $"Controls/Crossfade".UpdateAlpha(0.5)
    $"Controls/L Channel Fader".UpdateAlpha(0.5)
    $"Controls/L Tempo Adjust".UpdateAlpha(0.5)
    $"Controls/R Tempo Adjust".UpdateAlpha(0.5)
    $"Controls/R Channel Fader".UpdateAlpha(0.5)
    
    for child in $Controls.get_children():
        child.reset_highlight()
    
    Update_Channel_DBs()
    Update_Channel_Tempo_Adjusts()






var debug_visable = true

func _set_collision_shapes_visible_recursive(node: Node, visible: bool) -> void:
    if node is CollisionShape3D and node not in [$Node3D/ResetArea/CollisionShape3D, $Node3D/DisableDebigShapes/CollisionShape3D]:
        node.visible = visible
        node.debug_color = Color(node.debug_color.r, node.debug_color.g, node.debug_color.b, 1.0 if visible else 0.0)
        node.debug_fill = visible
    for child in node.get_children():
        _set_collision_shapes_visible_recursive(child, visible)
        
func _on_disable_debig_shapes_area_entered(area: Area3D) -> void:
    debug_visable = !debug_visable
    _set_collision_shapes_visible_recursive(get_tree().current_scene, debug_visable)
    
    


func _on_left_low_gain_on_activated() -> void:
    pass # Replace with function body.
