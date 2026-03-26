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
        await Controller_Instance
    
    return Controller_Instance
    

static func Get_Instance() -> DJ_Controller:
    return Controller_Instance
      


@export var Use_2_Track_Bus_Layout = true
var Bus_Layout : AudioBusLayout

@onready var AudioPlayerList : Array[AudioStreamPlayer] = [%"Track Stream Player Left",
    %"Track Stream Player Right",
    %"Track Stream Player Left ALT",
    %"Track Stream Player Right ALT"]; 
    
@onready var Channel_1_Left_Bus_Index = BUS_MANAGER.Get_Channel_Index_e(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_ONE_INPUT)
@onready var Channel_2_Right_Bus_Index = BUS_MANAGER.Get_Channel_Index_e(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_TWO_INPUT)
@onready var Channel_3_LeftALT_Bus_Index = BUS_MANAGER.Get_Channel_Index_e(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_THREE_INPUT)
@onready var Channel_4_RightALT_Bus_Index = BUS_MANAGER.Get_Channel_Index_e(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_FOUR_INPUT)

#@onready var Channel_1_FX_Bus_Index := BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_ONE_FX)
#@onready var Channel_2_FX_Bus_Index := BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_TWO_FX)

# Single place: knob paths per channel (trim, hi, mid, low, cfx) EQ uses +-24 dB so high/low gonna be strong

@onready var Core_FX_Knobs_TRIM_L : Knob_Control    =   $"Controls/Left Trim"
@onready var Core_FX_Knobs_EQ_LOW_L : Knob_Control  =   $"Controls/Left Low Gain"
@onready var Core_FX_Knobs_EQ_MID_L : Knob_Control  =   $"Controls/Left Medium Gain"
@onready var Core_FX_Knobs_EQ_HIGH_L : Knob_Control =   $"Controls/Left High Gain"
@onready var Core_FX_Knobs_SOUND_COLOR_FX_L : Knob_Control  =   $"Controls/Left Colour FX"
    


@onready var Core_FX_Knobs_TRIM_R : Knob_Control           =   $"Controls/Right Trim"
@onready var Core_FX_Knobs_EQ_LOW_R : Knob_Control         =   $"Controls/Right Low Gain"
@onready var Core_FX_Knobs_EQ_MID_R : Knob_Control         =   $"Controls/Right Medium Gain"
@onready var Core_FX_Knobs_EQ_HIGH_R : Knob_Control        =   $"Controls/Right High Gain"
@onready var Core_FX_Knobs_SOUND_COLOR_FX_R : Knob_Control =   $"Controls/Right Colour FX"

# One knob sets "power" of whatever Beat FX is active (0 = no effect, 1 = full) — FLX4 style
@onready var Beat_FX_Knob : Knob_Control = $"Controls/Beat FX"


@export var Crossfader_Curve_Left : Curve = preload("res://Components/Controls/Crossfade Curve Left.tres")
@export var Crossfader_Curve_Right : Curve = preload("res://Components/Controls/Crossfade Curve Right.tres")

var Channel_Faders = [1.0, 1.0, 1.0, 1.0] 
var Crossfade_Alpha = 0.5

#var Seek_Thread

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
    if which_song == null:
        AudioPlayerList[which_track].stream = null
        AudioPlayerList[which_track].stream_paused = true
        return
    AudioPlayerList[which_track].stream = which_song.get_audio_stream()
    print("Loading Track ", which_track, " into memory now")
    AudioPlayerList[which_track].stream_paused = true
    
    
      
func Play_Pause(p_which_track : int):
    p_which_track = Utility.Clamp_to_Valid_TrackID(p_which_track)
    
    if(AudioPlayerList[p_which_track].playing == false):
        print("Playing Track ", p_which_track, " now @ ", AudioPlayerList[p_which_track].get_playback_position())
        
        if BeatSyncState == E_BPM_Lock_Status.BOTH_FREE and AudioPlayerList[p_which_track].has_stream_playback():
            AudioPlayerList[p_which_track].stream_paused = false
        elif BeatSyncState == E_BPM_Lock_Status.BOTH_FREE and AudioPlayerList[p_which_track].has_stream_playback() == false:
            AudioPlayerList[p_which_track].stream_paused = false
            AudioPlayerList[p_which_track].play(Utility.Return_Valid(AudioPlayerList[p_which_track].get_playback_position(), 0.0)) 
            
        elif BeatSyncState == E_BPM_Lock_Status.RIGHT_TRACK_SYNCED_TO_LEFT and p_which_track == 1:
            _seek_track_phase_to_match(1, 0)
        elif BeatSyncState == E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT and p_which_track == 0:
            _seek_track_phase_to_match(0, 1)
            
        elif BeatSyncState == E_BPM_Lock_Status.RIGHT_TRACK_SYNCED_TO_LEFT and p_which_track == 0 and AudioPlayerList[p_which_track].has_stream_playback():
            #_seek_track_phase_to_match(0, 0) # this is SCUFFED
            AudioPlayerList[p_which_track].stream_paused = false
            _seek_track_phase_to_match(1, 0)
        elif BeatSyncState == E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT and p_which_track == 1 and AudioPlayerList[p_which_track].has_stream_playback():
            AudioPlayerList[p_which_track].stream_paused = false
            _seek_track_phase_to_match(0, 1)
        else:
            AudioPlayerList[p_which_track].play()
    
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
    if not Utility.all_is_ready:
        #print("CRAP")
        return
    Crossfade_Alpha = clampf($Controls/Crossfade.Value, 0, 1) # 0 = Left 1 = right
    Channel_Faders[0] = clampf($"Controls/L Channel Fader".Value, 0, 1)
    Channel_Faders[1] = clampf($"Controls/R Channel Fader".Value, 0, 1) # TODO: Add [2][3] for Alt decks
    var left_alpha = (Crossfader_Curve_Left.sample_baked(Crossfade_Alpha) * Channel_Faders[0])
    var right_alpha = (Crossfader_Curve_Right.sample_baked(Crossfade_Alpha) * Channel_Faders[1])
    # Update Channel DB based on Crossfader and channel fader
    AudioServer.set_bus_volume_linear(Channel_1_Left_Bus_Index, left_alpha)
    AudioServer.set_bus_volume_linear(Channel_2_Right_Bus_Index, right_alpha)
    #print("Bus: " + AudioServer.get_bus_name(Channel_2_Right_Bus_Index) + " is " + str(AudioServer.get_bus_volume_linear(Channel_2_Right_Bus_Index)))



# Trim (slot 0), EQ Hi/Mid/Low (slot 1), CFX (slot 2 = low pass, slot 3 = high pass) Both channels use same 3-slot layout EQ +-24 dB
func Update_Channel_Trim_EQ_CFX() -> void:
    #var buses: Array = [Channel_1_Left_Bus_Index, Channel_2_Right_Bus_Index]
    var channel_1 : int = BUS_MANAGER.Get_Channel_Index_i(0)
    var channel_2 : int = BUS_MANAGER.Get_Channel_Index_i(1)
    
    
    # step 1 trim / amplify
    #var amp: AudioEffectInstance = AudioServer.get_bus_effect(channel_1, 0) as AudioEffectAmplify
    AudioServer.get_bus_effect(channel_1, 0).volume_db = linear_to_db(remap(Core_FX_Knobs_TRIM_L.Value, 0.0, 1.0, 0.001, 2.0))
    AudioServer.get_bus_effect(channel_2, 0).volume_db = linear_to_db(remap(Core_FX_Knobs_TRIM_R.Value, 0.0, 1.0, 0.001, 2.0))
    
    # step 2: get our converted alphas for hi -> low to DBs
    var Track_1_core_fx_DBs : Dictionary[BUS_MANAGER.E_BAND_HZ, float] = BUS_MANAGER.Calculate_Weights_DB(
        Core_FX_Knobs_EQ_LOW_L.Value, 
        Core_FX_Knobs_EQ_MID_L.Value, 
        Core_FX_Knobs_EQ_HIGH_L.Value
        )
    var Track_2_core_fx_DBs : Dictionary[BUS_MANAGER.E_BAND_HZ, float] = BUS_MANAGER.Calculate_Weights_DB(
        Core_FX_Knobs_EQ_LOW_R.Value,  
        Core_FX_Knobs_EQ_MID_R.Value,  
        Core_FX_Knobs_EQ_HIGH_R.Value       
        )
        
    # go through all bands and set them for left and right   
    #var TEMP_DEBUG_DB = "Track 1 EQ Dbs: "
    for band in BUS_MANAGER.E_BAND_HZ.values():
        #print("Setting Band #" + str(band) + " to " + str(Track_1_core_fx_DBs[band]))
        AudioServer.get_bus_effect(channel_1, 1).set_band_gain_db(int(band), Track_1_core_fx_DBs[band])
        AudioServer.get_bus_effect(channel_2, 1).set_band_gain_db(int(band), Track_2_core_fx_DBs[band])
        #TEMP_DEBUG_DB += str(band) + " = " + str(Track_1_core_fx_DBs[band]) + " | "
    #print(TEMP_DEBUG_DB)
    
    # step 3: Color FX - (0 -> 0.5 is LOW PASS FILTER   0.5 -> 1 High Pass filter)
    # low-pass
    if Core_FX_Knobs_SOUND_COLOR_FX_L.Value < 0.495:
        AudioServer.set_bus_effect_enabled(channel_1, BUS_MANAGER.CFX_LOWPASS_SLOT, true)
        #AudioServer.get_bus_effect(channel_1, BUS_MANAGER.CFX_LOWPASS_SLOT).cutoff_hz = lerpf(BUS_MANAGER.CFX_CUTOFF_CLOSED_HZ, BUS_MANAGER.CFX_CUTOFF_OPEN_HZ, cfx_l * 2.0)
        AudioServer.get_bus_effect(channel_1, BUS_MANAGER.CFX_LOWPASS_SLOT).cutoff_hz = remap(Core_FX_Knobs_SOUND_COLOR_FX_L.Value, 0.0, 0.495, BUS_MANAGER.CFX_CUTOFF_CLOSED_HZ, BUS_MANAGER.CFX_CUTOFF_OPEN_HZ)
    else:
        AudioServer.set_bus_effect_enabled(channel_1, BUS_MANAGER.CFX_LOWPASS_SLOT, false)
    if Core_FX_Knobs_SOUND_COLOR_FX_R.Value < 0.495:
        AudioServer.set_bus_effect_enabled(channel_2, BUS_MANAGER.CFX_LOWPASS_SLOT, true)
        AudioServer.get_bus_effect(channel_2, BUS_MANAGER.CFX_LOWPASS_SLOT).cutoff_hz = remap(Core_FX_Knobs_SOUND_COLOR_FX_R.Value, 0.0, 0.495, BUS_MANAGER.CFX_CUTOFF_CLOSED_HZ, BUS_MANAGER.CFX_CUTOFF_OPEN_HZ)
    else:
        AudioServer.set_bus_effect_enabled(channel_2, BUS_MANAGER.CFX_LOWPASS_SLOT, false)

    # high-pass
    if Core_FX_Knobs_SOUND_COLOR_FX_L.Value > 0.505:
        AudioServer.set_bus_effect_enabled(channel_1, BUS_MANAGER.CFX_HIGHPASS_SLOT, true)
        AudioServer.get_bus_effect(channel_1, BUS_MANAGER.CFX_HIGHPASS_SLOT).cutoff_hz = remap(Core_FX_Knobs_SOUND_COLOR_FX_L.Value, 0.505, 1.0, BUS_MANAGER.CFX_CUTOFF_CLOSED_HZ, BUS_MANAGER.CFX_CUTOFF_OPEN_HZ)
    else:
        AudioServer.set_bus_effect_enabled(channel_1, BUS_MANAGER.CFX_HIGHPASS_SLOT, false)
    if Core_FX_Knobs_SOUND_COLOR_FX_R.Value > 0.505:
        AudioServer.set_bus_effect_enabled(channel_2, BUS_MANAGER.CFX_HIGHPASS_SLOT, true)
        AudioServer.get_bus_effect(channel_2, BUS_MANAGER.CFX_HIGHPASS_SLOT).cutoff_hz = remap(Core_FX_Knobs_SOUND_COLOR_FX_R.Value, 0.505, 1.0, BUS_MANAGER.CFX_CUTOFF_CLOSED_HZ, BUS_MANAGER.CFX_CUTOFF_OPEN_HZ)
    else:
        AudioServer.set_bus_effect_enabled(channel_2, BUS_MANAGER.CFX_HIGHPASS_SLOT, false)
            



var track_1_new_bpm : float = 0
var track_2_new_bpm : float = 0

static func Get_Track_Current_BPM(which_track : int) -> float:
    match which_track:
        0:
            return DJ_Controller.Get_Instance().track_1_new_bpm
        1:
            return DJ_Controller.Get_Instance().track_2_new_bpm
        _:
            return 0.0
    
    
    
    
static func Get_Track_Speed_Mult(which_track : int) -> float:
    match which_track:
        0:
            return DJ_Controller.Get_Instance().track_1_new_bpm / LibreBox.Get_Track_BPM(0)
        1:
            return DJ_Controller.Get_Instance().track_2_new_bpm / LibreBox.Get_Track_BPM(1)
        _:
            return 0.0
                
        


# Adjust BPM/Tempo of our Tracks in range of +-BPM_Adjust_Range 
func Update_Channel_Tempo_Adjusts():
    const tolerance : float = 0.05
    # Where are our Sliders set right now?
    if BeatSyncState == E_BPM_Lock_Status.LEFT_TRACK_SYNCED_TO_RIGHT:
        if LibreBox.Get_Track_BPM(0) > 1.0:
            AudioPlayerList[0].pitch_scale = track_2_new_bpm / LibreBox.Get_Track_BPM(0)
        track_1_new_bpm = track_2_new_bpm  # Synced: left matches right's BPM exactly
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
        track_2_new_bpm = track_1_new_bpm  # Synced: right matches left's BPM exactly
        $"Controls/R Tempo Adjust".UpdateAlpha(0.5)
    else:
        var Right_adj = $"Controls/R Tempo Adjust".Value
        if (abs(0.5 - Right_adj) < tolerance):
            AudioPlayerList[1].pitch_scale = 1
        else:
            AudioPlayerList[1].pitch_scale = remap(Right_adj, 0, 1, (1.0 - BPM_Adjust_Range), (1.0 + BPM_Adjust_Range))
        track_2_new_bpm = LibreBox.Get_Track_BPM(1) * AudioPlayerList[1].pitch_scale
      
    
    # TODO: Do AudioPlayerList[2] + [3]
    
    
func _physics_process(delta: float) -> void:
           
    Update_Channel_Tempo_Adjusts()
    Update_Channel_DBs() # crossfades and stuff
    Update_Channel_Trim_EQ_CFX() # trim, EQ hi/mid/low, CFX per track
    # Beat FX "power": 0 = inaudible, 1 = full effect
    BUS_MANAGER.Apply_Beat_FX_Level(0, Beat_FX_Knob.Value)
    BUS_MANAGER.Apply_Beat_FX_Level(1, Beat_FX_Knob.Value)

    $"General Status".text = tr("KEY_CROSSFADE_STATUS") + ": " + str("%0.3f" % remap(Crossfade_Alpha, 0.0, 1.0, -1.0, 1.0))

    

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
    $"Controls/Left Trim".UpdateAlpha(0.5)
    $"Controls/Right Trim".UpdateAlpha(0.5)
    $"Controls/Left High Gain".UpdateAlpha(0.5)
    $"Controls/Left Medium Gain".UpdateAlpha(0.5)
    $"Controls/Left Low Gain".UpdateAlpha(0.5)
    $"Controls/Right High Gain".UpdateAlpha(0.5)
    $"Controls/Right Medium Gain".UpdateAlpha(0.5)
    $"Controls/Right Low Gain".UpdateAlpha(0.5)
    $"Controls/Left Colour FX".UpdateAlpha(0.5)
    $"Controls/Right Colour FX".UpdateAlpha(0.5)
    $"Controls/Beat FX".UpdateAlpha(0.0)

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



# Im sorry for cramming all the vars up here... this function HITCHES bad and the profiles 
# TODO: Offload _seek_track_phase_to_match to a different thread and pray that the result is the same but with no hitch??
var ref_bpm : float = 0.0
var move_bpm : float = 0.0
var stream_length: float
var ref_beat_stream: float
var move_beat_stream: float
var latency_correction: float
var ref_pos: float
var move_pos: float
var phase_ratio: float
var move_beat_index: int
var new_pos: float
# Aligns track_to_move so its beat phase matches reference_track. Only adjusts phase (same pos
# within the beat); never snaps the moved track to the reference track's position in the song
func _seek_track_phase_to_match(track_to_move: int, reference_track: int):
    track_to_move = Utility.Clamp_to_Valid_TrackID(track_to_move)
    reference_track = Utility.Clamp_to_Valid_TrackID(reference_track)
    if AudioPlayerList[reference_track].stream == null or AudioPlayerList[track_to_move].stream == null:
        return

    stream_length = AudioPlayerList[track_to_move].stream.get_length()

    # Beat boundaries in the file are fixed by metadata BPM
    # so we need beat length in stream seconds (60 / base BPM), not real-time.
    ref_bpm = LibreBox.Get_Track_BPM(reference_track)
    move_bpm = LibreBox.Get_Track_BPM(track_to_move)
    
    if ref_bpm <= 0.0 or move_bpm <= 0.0:
        return
    
    ref_beat_stream = 60.0 / ref_bpm   # seconds of reference stream per beat
    move_beat_stream = 60.0 / move_bpm # seconds of move stream per beat

    # Latency-correct positions so we align to what the listener actually hears (like RhythmNotifier)
    latency_correction = AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
    ref_pos = Utility.Return_Valid(AudioPlayerList[reference_track].get_playback_position(), 0.0)
    
    if AudioPlayerList[reference_track].playing:
        ref_pos += latency_correction
        
    move_pos = Utility.Return_Valid(AudioPlayerList[track_to_move].get_playback_position(), 0.0)
    if AudioPlayerList[track_to_move].playing:
        move_pos += latency_correction

    # Phase as a ratio 0..1 within the beat (same for any BPM)
    phase_ratio = fmod(ref_pos, ref_beat_stream) / ref_beat_stream
    
    # Keep the moved track in the same beat region of its own song; only fix the phase
    move_beat_index = int(floor(move_pos / move_beat_stream))
    new_pos = move_beat_index * move_beat_stream + phase_ratio * move_beat_stream
    new_pos = clampf(new_pos, 0.0, maxf(0.0, stream_length - 0.001))

    if AudioPlayerList[track_to_move].has_stream_playback():
        AudioPlayerList[track_to_move].stream_paused = false
        AudioPlayerList[track_to_move].seek(new_pos)
    else:
        AudioPlayerList[track_to_move].play(new_pos)

    


func _on_Select_FX_activated() -> void:
    pass
