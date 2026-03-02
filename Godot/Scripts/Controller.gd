extends Node3D
class_name DJ_Controller

#@onready var LibreBox_ref : LibreBox = $LibreboxScene
# Too many issues with Init'ing
#var AudioSourceList : Array[AudioStream] = [Track_1_AudioSource, Track_2_AudioSource, Track_3_AudioSource, Track_4_AudioSource]


signal all_ready

enum E_BPM_Lock_Status
{
    BOTH_FREE,
    LEFT_TRACK_SYNCED_TO_RIGHT,
    RIGHT_TRACK_SYNCED_TO_LEFT,
}

var BeatSyncState : E_BPM_Lock_Status = E_BPM_Lock_Status.BOTH_FREE


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

var Channel_Faders = [1.0, 1.0, 1.0, 1.0]
var Crossfade_Alpha = 0.5



# Default is 10% Tempo Adjust Range
@export var BPM_Adjust_Range = 0.1
   

static func Get_Track_Playback_Position(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return Utility.Return_Valid(Controller_Instance.AudioPlayerList[which_track].get_playback_position(), 0.0)


    
    

static func Get_Track_Playback_Alpha(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if Controller_Instance.AudioPlayerList[which_track].stream:
        var total_seconds : float = Controller_Instance.AudioPlayerList[which_track].stream.get_length()
        var played_for_seconds : float =  Controller_Instance.AudioPlayerList[which_track].get_playback_position()
        return remap(played_for_seconds, 0.0, total_seconds, 0.0, 1.0)
    else:
        #push_warning("HEY! Audio Player #" + str(which_track) + " doesn't have a stream assigned to it... HOW DID THIS GET MESSED UP?")
        return -1.0


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
    

## incase we want to set tempos from beatsync or something
#func Update_Channel_Tempos() -> void:
    ##which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    ##Ensure_BPM_Adjust_Range_contains(new_tempo)
    #match BeatSyncState:
        #E_BPM_Lock_Status.LEFT
    #AudioPlayerList[which_track].pitch_scale = new_tempo
    #manual_change_this_frame = true
    #Update_Channel_Tempo_Adjusts()



var track_1_new_bpm : float = 0
var track_2_new_bpm : float = 0

# Adjust BPM/Tempo of our Tracks in range of +-BPM_Adjust_Range 
func Update_Channel_Tempo_Adjusts():
    const tolerance : float = 0.05
    # Where are our Sliders set right now?
    if BeatSyncState == E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT:
        if LibreBox.Get_Track_BPM(0) > 1.0:
            AudioPlayerList[0].pitch_scale = track_2_new_bpm / LibreBox.Get_Track_BPM(0) 
        $"Controls/L Tempo Adjust".UpdateAlpha(0.5)
    else:  
        var Left_adj = $"Controls/L Tempo Adjust".Value # between 0...1
        # meh, it's close enough to snap to middle (0.5), assume no change in tempo
        if (abs(0.5 - Left_adj) < tolerance):
            AudioPlayerList[0].pitch_scale = 1 
        else:
            # BPM Adjust range is 0.16, 
            # so our tempo multiplier will be between 0.84...1.16
            # Remap our sliders (0...1) to (0.84...1.16) 
            AudioPlayerList[0].pitch_scale = remap(Left_adj, 0, 1, (1.0 - BPM_Adjust_Range), (1.0 + BPM_Adjust_Range))
        track_1_new_bpm = LibreBox.Get_Track_BPM(0) * AudioPlayerList[0].pitch_scale
        
    if BeatSyncState == E_BPM_Lock_Status.RIGHT_TRACK_SYNCED_TO_LEFT:  
        if LibreBox.Get_Track_BPM(1) > 1.0:
            AudioPlayerList[1].pitch_scale = track_1_new_bpm / LibreBox.Get_Track_BPM(1) 
        $"Controls/R Tempo Adjust".UpdateAlpha(0.5)
    else:
        var Right_adj = $"Controls/R Tempo Adjust".Value
        if (abs(0.5 - Right_adj) < tolerance):
            AudioPlayerList[1].pitch_scale = 1
        else:
            AudioPlayerList[1].pitch_scale = remap(Right_adj, 0, 1, (1.0 - BPM_Adjust_Range), (1.0 + BPM_Adjust_Range))
        track_2_new_bpm = LibreBox.Get_Track_BPM(1) * AudioPlayerList[1].pitch_scale
      
    
    # TODO: Do AudioPlayerList[2] + [3]
    
    
func _process(delta: float) -> void:
           
    Update_Channel_Tempo_Adjusts()    
    Update_Channel_DBs() # crossfades and stuff

    $"General Status".text = "Crossfade: %.3f" % remap(Crossfade_Alpha, 0.0, 1.0, -1.0, 1.0)

    

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
    


signal Sync_LeftTrackBPM_to_RightTrackBPM
func _on_left_beat_sync_on_activated():
    if AudioPlayerList[1].stream != null:
        if BeatSyncState == E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT:
            BeatSyncState = E_BPM_Lock_Status.BOTH_FREE
        else:
            BeatSyncState = E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT
            _seek_track_phase_to_match(0, 1)  # Track 1 seeks to match track 2's beat
        Sync_LeftTrackBPM_to_RightTrackBPM.emit()


signal Sync_RightTrackBPM_to_LeftTrackBPM
func _on_right_beat_sync_on_activated():
    if AudioPlayerList[0].stream != null:
        if BeatSyncState == E_BPM_Lock_Status.RIGHT_TRACK_SYNCED_TO_LEFT:
            BeatSyncState = E_BPM_Lock_Status.BOTH_FREE
        else:
            BeatSyncState = E_BPM_Lock_Status.RIGHT_TRACK_SYNCED_TO_LEFT
            _seek_track_phase_to_match(1, 0)  # Track 2 seeks to match track 1's beat
        Sync_RightTrackBPM_to_LeftTrackBPM.emit()


# Aligns track_to_move so beat matches reference_track
func _seek_track_phase_to_match(track_to_move: int, reference_track: int):
    track_to_move = Utility.Clamp_to_Valid_TrackID(track_to_move)
    reference_track = Utility.Clamp_to_Valid_TrackID(reference_track)
    if AudioPlayerList[reference_track].stream == null or AudioPlayerList[track_to_move].stream == null:
        return

    var stream_length: float = AudioPlayerList[track_to_move].stream.get_length()
    var ref_current_bpm : float = 0.0
    match reference_track:
        0:
            ref_current_bpm = track_1_new_bpm
        1:
            ref_current_bpm = track_2_new_bpm
        # TODO: Add 3,4
    
    # After sync, the moved track will run at the reference's effective BPM, so use reference beat length for phase
    var beat_length: float = 60.0 / ref_current_bpm
    var ref_pos: float = Utility.Return_Valid(AudioPlayerList[reference_track].get_playback_position(), 0.0)
    var move_pos: float = Utility.Return_Valid(AudioPlayerList[track_to_move].get_playback_position(), 0.0)
    var phase: float = fmod(ref_pos, beat_length)
    
    # Place the moved track at the same phase within its current beat (nearest beat boundary)
    var new_pos: float = floor(move_pos / beat_length) * beat_length + phase
    # Clamp to stream and avoid negative
    new_pos = clampf(new_pos, 0.0, maxf(0.0, stream_length - 0.001))
    AudioPlayerList[track_to_move].seek(new_pos)
    AudioPlayerList[track_to_move].play(new_pos)

    
