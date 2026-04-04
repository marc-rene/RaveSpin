extends Node3D
class_name DJ_Controller

## Central FLX4-style runtime controller.
## Owns deck state, transport, loop/cue/pad modes, and per-frame mixer/audio updates.
#@onready var LibreBox_ref : LibreBox = $LibreboxScene
# Too many issues with Init'ing
#var AudioSourceList : Array[AudioStream] = [Track_1_AudioSource, Track_2_AudioSource, Track_3_AudioSource, Track_4_AudioSource]

## Cached playback position/length values to avoid repeated per-frame lookups elsewhere.
@export var Track_1_playback_pos : float
@export var Track_2_playback_pos : float
@export var Track_1_playback_length : float
@export var Track_2_playback_length : float

signal all_ready

enum E_BPM_Lock_Status
{
    BOTH_FREE,
    LEFT_TRACK_SYNCED_TO_RIGHT,
    RIGHT_TRACK_SYNCED_TO_LEFT,
}

var BeatSyncState : E_BPM_Lock_Status = E_BPM_Lock_Status.BOTH_FREE


static var Controller_Instance : DJ_Controller = null

## Waits until singleton instance exists, then returns it.
static func Get_Instance_await() -> DJ_Controller:
    if Controller_Instance == null:
        await Controller_Instance
    
    return Controller_Instance
    

## Returns the active singleton instance.
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

@onready var Left_Jogwheel_Node: Node3D = $"Controls/Left Jogwheel"
@onready var Right_Jogwheel_Node: Node3D = $"Controls/Right Jogwheel"
@onready var Left_Jogwheel_Activation: Area3D = $"Controls/Left Jogwheel/Activation"
@onready var Right_Jogwheel_Activation: Area3D = $"Controls/Right Jogwheel/Activation"
@onready var Left_Jogwheel_Collision_Shape: CollisionShape3D = $"Controls/Left Jogwheel/Activation/CollisionShape3D"
@onready var Right_Jogwheel_Collision_Shape: CollisionShape3D = $"Controls/Right Jogwheel/Activation/CollisionShape3D"

#@onready var Channel_1_FX_Bus_Index := BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_ONE_FX)
#@onready var Channel_2_FX_Bus_Index := BUS_MANAGER.Get_Channel_Index(BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_TWO_FX)

## Core mixer knob references for both decks (trim, EQ low/mid/high, colour FX).

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

## Beat FX intensity control (0 = no audible effect, 1 = full effect).
@onready var Beat_FX_Knob : Knob_Control = $"Controls/Beat FX"


@export var Crossfader_Curve_Left : Curve = preload("res://Components/Controls/Crossfade Curve Left.tres")
@export var Crossfader_Curve_Right : Curve = preload("res://Components/Controls/Crossfade Curve Right.tres")

var Channel_Faders = [1.0, 1.0, 1.0, 1.0] 
var Crossfade_Alpha = 0.5

#var Seek_Thread

## Tempo slider range as a multiplier offset around 1.0 (default +/-10%).
@export var BPM_Adjust_Range = 0.1
@export var Restrict_Jogwheel_To_Matching_Hand: bool = false
## Track-time warp amount for one full jogwheel rotation.
## Example: 1.0 means one full turn seeks by one second.
@export var Jogwheel_Audio_Warp_Seconds_Per_Full_Rotation: float = 1.0
@export var Jogwheel_Auto_Spin_Rotations_Per_Second_At_Normal_Speed: float = 1.0
@export var Jogwheel_Grab_Radius_Meters: float = 0.06
@export var Use_Multi_Threaded_Jog_Warp: bool = false
@export var Use_Snap_Style_Jogwheel_Grab: bool = false
@export var Jogwheel_Enable_Audible_Scratching: bool = true

var Left_Jogwheel_Mesh: MeshInstance3D = null
var Right_Jogwheel_Mesh: MeshInstance3D = null
var Left_Jogwheel_Finger: Player_Finger = null
var Right_Jogwheel_Finger: Player_Finger = null
var _jog_last_angle_radians: Array[float] = [0.0, 0.0]
var _jog_has_last_angle: Array[bool] = [false, false]
var _jog_seek_threads: Array[Thread] = [null, null]
var _jog_seek_thread_run: Array[bool] = [false, false]
var _jog_pending_seek_seconds: Array[float] = [-1.0, -1.0]
var _jog_touch_active: Array[bool] = [false, false]
var _jog_resume_after_touch: Array[bool] = [false, false]
var _jog_virtual_position_seconds: Array[float] = [0.0, 0.0]
var _jog_has_virtual_position: Array[bool] = [false, false]
var _all_player_fingers: Array[Player_Finger] = []
   




static func Get_Track_Playback_Position(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return Utility.Return_Valid(Controller_Instance.AudioPlayerList[which_track].get_playback_position(), 0.0)


    
    

## Returns 0..1 progress through current track stream, or -1 when missing stream.
static func Get_Track_Playback_Alpha(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if Controller_Instance.AudioPlayerList[which_track].stream:
        var total_seconds : float = Controller_Instance.AudioPlayerList[which_track].stream.get_length()
        var played_for_seconds : float =  Controller_Instance.AudioPlayerList[which_track].get_playback_position()
        return remap(played_for_seconds, 0.0, total_seconds, 0.0, 1.0)
    else:
        #push_warning("HEY! Audio Player #" + str(which_track) + " doesn't have a stream assigned to it... HOW DID THIS GET MESSED UP?")
        return -1.0


## Returns AudioStreamPlayer backing the requested deck.
static func Get_Track_Playback_Player(which_track : int) -> AudioStreamPlayer:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return Controller_Instance.AudioPlayerList[which_track]


## Loop handling must stay threaded for stable runtime behaviour on target XR hardware.
## Disabling this has previously caused startup/runtime failures on device.
const Use_Multi_threaded_looping : bool = true # DO NOT CHANGE THIS EVER





## --- Loop management (per track) ---
## Loop points are stored in stream seconds (`get_playback_position()` space).
## Beat snapping uses base BPM metadata (`LibreBox.Get_Track_BPM`).
var Loop_Point_Snapping_Enabled: Array[bool] = [true, true, true, true]
var Loop_Enabled: Array[bool] = [false, false, false, false]
var Loop_Start_Sec: Array[float] = [0.0, 0.0, 0.0, 0.0]
var Loop_End_Sec: Array[float] = [0.0, 0.0, 0.0, 0.0]
var Loop_Start_Armed: Array[bool] = [false, false, false, false]
var Loop_End_Armed: Array[bool] = [false, false, false, false]

var _loop_threads: Array[Thread] = [null, null, null, null]
var _loop_thread_run: Array[bool] = [false, false, false, false]
var _loop_last_seek_ms: Array[int] = [0, 0, 0, 0]
const LOOP_SEEK_COOLDOWN_MS: int = 40

const LOOP_MIN_BEATS: float = 1.0 / 16.0
const LOOP_MAX_BEATS: float = 128.0

const PERFORMANCE_PAD_COUNT: int = 8
const HOT_CUE_UNSET_SEC: float = -1.0
## FLX4 default Beat Jump mapping:
## pad 1/2 = -/+1 beat, 3/4 = -/+2 beats, 5/6 = -/+4 beats, 7/8 = -/+8 beats.
const BEAT_JUMP_STEPS_BEATS: Array[float] = [-1.0, 1.0, -2.0, 2.0, -4.0, 4.0, -8.0, 8.0]
## FLX4 default Key Shift mapping:
## pads 1..8 = +4, +5, +6, +7, 0, +1, +2, +3 semitones.
const KEY_SHIFT_STEPS_SEMITONES: Array[int] = [4, 5, 6, 7, 0, 1, 2, 3]
const PERFORMANCE_PAD_COLOURS: Array[Color] = [
    Color(0.99, 0.46, 0.24, 1.0),
    Color(0.99, 0.73, 0.21, 1.0),
    Color(0.98, 0.93, 0.31, 1.0),
    Color(0.53, 0.91, 0.35, 1.0),
    Color(0.30, 0.86, 0.78, 1.0),
    Color(0.35, 0.64, 0.98, 1.0),
    Color(0.66, 0.47, 0.96, 1.0),
    Color(0.94, 0.37, 0.72, 1.0),
]
const FX_SET_1_TYPES: Array[BUS_MANAGER.E_BEAT_FX_TYPE] = [
    BUS_MANAGER.E_BEAT_FX_TYPE.DELAY,
    BUS_MANAGER.E_BEAT_FX_TYPE.ECHO,
    BUS_MANAGER.E_BEAT_FX_TYPE.REVERB,
    BUS_MANAGER.E_BEAT_FX_TYPE.TRANS,
    BUS_MANAGER.E_BEAT_FX_TYPE.FLANGER,
    BUS_MANAGER.E_BEAT_FX_TYPE.PHASER,
    BUS_MANAGER.E_BEAT_FX_TYPE.PITCH,
    BUS_MANAGER.E_BEAT_FX_TYPE.CRUSH,
]
const FX_SET_2_TYPES: Array[BUS_MANAGER.E_BEAT_FX_TYPE] = [
    BUS_MANAGER.E_BEAT_FX_TYPE.COMPRESSOR,
    BUS_MANAGER.E_BEAT_FX_TYPE.LIMITER,
    BUS_MANAGER.E_BEAT_FX_TYPE.BAND_PASS,
    BUS_MANAGER.E_BEAT_FX_TYPE.PANNER,
    BUS_MANAGER.E_BEAT_FX_TYPE.STEREO_ENHANCE,
    BUS_MANAGER.E_BEAT_FX_TYPE.DISTORTION,
    BUS_MANAGER.E_BEAT_FX_TYPE.DELAY,
    BUS_MANAGER.E_BEAT_FX_TYPE.REVERB,
]

enum E_Performance_Pad_Mode
{
    HOT_CUE,
    SAMPLER,
    FX_SET_1,
    FX_SET_2,
    BEAT_JUMP,
    KEY_SHIFT,
}

var Performance_Pad_Mode_By_Track: Array[int] = [E_Performance_Pad_Mode.HOT_CUE, E_Performance_Pad_Mode.HOT_CUE]
var Hot_Cue_Add_Mode_By_Track: Array[bool] = [true, true]
var Selected_FX_Set_By_Track: Array[int] = [1, 1]
var Key_Shift_Semitones_By_Track: Array[int] = [0, 0]
var Hot_Cue_Sec_By_Track: Array = []
var Regular_Cue_Sec_By_Track: Array[float] = [0.0, 0.0]
var _regular_cue_is_set_by_track: Array[bool] = [false, false]
var _regular_cue_hold_active_by_track: Array[bool] = [false, false]
var _regular_cue_hold_was_playing_by_track: Array[bool] = [false, false]
var _performance_pad_controls_by_track: Array = [[], []]
var _performance_pad_sampler_players_by_track: Array = [[], []]
var _performance_pad_pulse_materials_by_track: Array = [[], []]
var _performance_pad_fx_hold_active_by_track: Array = [[], []]
var _performance_pad_pulse_time: float = 0.0

static func Get_Performance_Pad_Mode(which_track: int) -> int:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Performance_Pad_Mode_By_Track[which_track]

static func Set_Performance_Pad_Mode(which_track: int, mode: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    mode = clampi(mode, E_Performance_Pad_Mode.HOT_CUE, E_Performance_Pad_Mode.KEY_SHIFT)
    var inst := DJ_Controller.Get_Instance()
    var previous_mode: int = inst.Performance_Pad_Mode_By_Track[which_track]
    inst.Performance_Pad_Mode_By_Track[which_track] = mode
    if mode == E_Performance_Pad_Mode.FX_SET_1:
        inst.Selected_FX_Set_By_Track[which_track] = 1
    elif mode == E_Performance_Pad_Mode.FX_SET_2:
        inst.Selected_FX_Set_By_Track[which_track] = 2

    var was_fx_mode: bool = previous_mode == E_Performance_Pad_Mode.FX_SET_1 or previous_mode == E_Performance_Pad_Mode.FX_SET_2
    var is_fx_mode: bool = mode == E_Performance_Pad_Mode.FX_SET_1 or mode == E_Performance_Pad_Mode.FX_SET_2
    if was_fx_mode and not is_fx_mode:
        inst._clear_held_fx_for_track(which_track)

static func Get_Hot_Cue_Add_Mode(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Hot_Cue_Add_Mode_By_Track[which_track]

static func Set_Hot_Cue_Add_Mode(which_track: int, add_mode_enabled: bool) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    DJ_Controller.Get_Instance().Hot_Cue_Add_Mode_By_Track[which_track] = add_mode_enabled

static func Get_Selected_FX_Set(which_track: int) -> int:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Selected_FX_Set_By_Track[which_track]


static func Has_Regular_Cue(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance()._regular_cue_is_set_by_track[which_track]


static func Get_Regular_Cue_Sec(which_track: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Regular_Cue_Sec_By_Track[which_track]

static func Has_Hot_Cue(which_track: int, cue_index: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    cue_index = clampi(cue_index, 0, PERFORMANCE_PAD_COUNT - 1)
    return DJ_Controller.Get_Instance().Hot_Cue_Sec_By_Track[which_track][cue_index] >= 0.0

static func Get_Hot_Cue_Sec(which_track: int, cue_index: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    cue_index = clampi(cue_index, 0, PERFORMANCE_PAD_COUNT - 1)
    return DJ_Controller.Get_Instance().Hot_Cue_Sec_By_Track[which_track][cue_index]

static func Clear_All_Hot_Cues(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    for cue_index: int in range(PERFORMANCE_PAD_COUNT):
        DJ_Controller.Get_Instance().Hot_Cue_Sec_By_Track[which_track][cue_index] = HOT_CUE_UNSET_SEC


static func Get_Performance_Pad_Color(pad_index: int) -> Color:
    pad_index = clampi(pad_index, 0, PERFORMANCE_PAD_COLOURS.size() - 1)
    return PERFORMANCE_PAD_COLOURS[pad_index]

static func Is_Loop_Enabled(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_Enabled[which_track]

static func Get_Loop_Start_Sec(which_track: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_Start_Sec[which_track]

static func Get_Loop_End_Sec(which_track: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_End_Sec[which_track]

static func Is_Loop_Start_Armed(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_Start_Armed[which_track]

static func Is_Loop_End_Armed(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_End_Armed[which_track]

static func Is_Loop_Point_Snapping_Enabled(which_track: int) -> bool:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    return DJ_Controller.Get_Instance().Loop_Point_Snapping_Enabled[which_track]

static func Set_Loop_Point_Snapping_Enabled(which_track: int, enabled: bool) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    DJ_Controller.Get_Instance().Loop_Point_Snapping_Enabled[which_track] = enabled

static func Clear_Loop(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var inst := DJ_Controller.Get_Instance()
    inst.Loop_Enabled[which_track] = false
    inst.Loop_Start_Armed[which_track] = false
    inst.Loop_End_Armed[which_track] = false


func _setup_performance_pad_defaults() -> void:
    Hot_Cue_Sec_By_Track.clear()
    for which_track: int in range(0, 2):
        var cue_slots: Array[float] = []
        cue_slots.resize(PERFORMANCE_PAD_COUNT)
        for cue_index: int in range(PERFORMANCE_PAD_COUNT):
            cue_slots[cue_index] = HOT_CUE_UNSET_SEC
        Hot_Cue_Sec_By_Track.append(cue_slots)

    Performance_Pad_Mode_By_Track = [E_Performance_Pad_Mode.HOT_CUE, E_Performance_Pad_Mode.HOT_CUE]
    Hot_Cue_Add_Mode_By_Track = [true, true]
    Selected_FX_Set_By_Track = [1, 1]
    Key_Shift_Semitones_By_Track = [0, 0]
    _performance_pad_controls_by_track = [[], []]
    _performance_pad_sampler_players_by_track = [[], []]
    _performance_pad_pulse_materials_by_track = [[], []]
    _performance_pad_fx_hold_active_by_track = [[], []]
    _performance_pad_pulse_time = 0.0


func _setup_performance_pad_nodes_and_signals() -> void:
    var left_group: Node = get_node_or_null("Controls/Performance Pads Left")
    var right_group: Node = get_node_or_null("Controls/Performance Pads Right")

    _cache_and_connect_performance_pads_for_track(0, left_group)
    _cache_and_connect_performance_pads_for_track(1, right_group)



func _cache_and_connect_performance_pads_for_track(which_track: int, pad_group: Node) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if pad_group == null:
        return

    var controls_for_track: Array[Base_Control] = []
    var players_for_track: Array[AudioStreamPlayer] = []
    var pulse_materials_for_track: Array[StandardMaterial3D] = []
    var fx_hold_active_for_track: Array[bool] = []

    for child_node: Node in pad_group.get_children():
        var pad_control: Base_Control = child_node as Base_Control
        if pad_control == null:
            continue
        controls_for_track.append(pad_control)

    controls_for_track.sort_custom(func(a: Base_Control, b: Base_Control) -> bool:
        return String(a.name).naturalnocasecmp_to(String(b.name)) < 0
    )

    for pad_index: int in range(min(PERFORMANCE_PAD_COUNT, controls_for_track.size())):
        var pad_control: Base_Control = controls_for_track[pad_index]
        if pad_control == null:
            continue
        var perf_pad_control: Performance_Pad_Control = pad_control as Performance_Pad_Control
        if perf_pad_control != null:
            perf_pad_control.PAD_INDEX = pad_index
            perf_pad_control.which_track_we_targetting = which_track

        var on_activated_callable := Callable(self, "_on_performance_pad_on_activated").bind(which_track, pad_index)
        if not pad_control.is_connected("on_activated", on_activated_callable):
            pad_control.connect("on_activated", on_activated_callable)
        if perf_pad_control != null:
            var on_pressed_callable := Callable(self, "_on_performance_pad_pressed").bind(which_track, pad_index)
            if not perf_pad_control.is_connected("on_pad_pressed", on_pressed_callable):
                perf_pad_control.connect("on_pad_pressed", on_pressed_callable)
            var on_released_callable := Callable(self, "_on_performance_pad_released").bind(which_track, pad_index)
            if not perf_pad_control.is_connected("on_pad_released", on_released_callable):
                perf_pad_control.connect("on_pad_released", on_released_callable)

        var sampler_player: AudioStreamPlayer = null
        if pad_control.has_method("get_sampler_player"):
            sampler_player = pad_control.get_sampler_player()
        if not sampler_player:
            sampler_player = pad_control.get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
        
        if sampler_player == null:
            sampler_player = pad_control.get_node_or_null("Performance Pad Sampler StreamPlayer") as AudioStreamPlayer
        players_for_track.append(sampler_player)

        # TODO: Figure out someway to preload this
        var pulse_mat : StandardMaterial3D = StandardMaterial3D.new()
        pulse_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        pulse_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        pulse_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.0)
        pulse_materials_for_track.append(pulse_mat)
        fx_hold_active_for_track.append(false)

    _performance_pad_controls_by_track[which_track] = controls_for_track
    _performance_pad_sampler_players_by_track[which_track] = players_for_track
    _performance_pad_pulse_materials_by_track[which_track] = pulse_materials_for_track
    _performance_pad_fx_hold_active_by_track[which_track] = fx_hold_active_for_track


func _on_performance_pad_on_activated(which_track: int, pad_index: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    pad_index = clampi(pad_index, 0, PERFORMANCE_PAD_COUNT - 1)

    var selected_mode: int = Performance_Pad_Mode_By_Track[which_track]
    match selected_mode:
        E_Performance_Pad_Mode.HOT_CUE:
            _performance_pad_handle_hot_cue(which_track, pad_index)
        E_Performance_Pad_Mode.SAMPLER:
            _performance_pad_handle_sampler(which_track, pad_index)
        E_Performance_Pad_Mode.FX_SET_1, E_Performance_Pad_Mode.FX_SET_2:
            pass
        E_Performance_Pad_Mode.BEAT_JUMP:
            _performance_pad_handle_beat_jump(which_track, pad_index)
        E_Performance_Pad_Mode.KEY_SHIFT:
            _performance_pad_handle_key_shift(which_track, pad_index)


func _performance_pad_handle_hot_cue(which_track: int, pad_index: int) -> void:
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return

    if Hot_Cue_Add_Mode_By_Track[which_track]:
        if Has_Hot_Cue(which_track, pad_index):
            var cue_sec: float = Hot_Cue_Sec_By_Track[which_track][pad_index]
            _apply_track_seek(which_track, cue_sec)
        else:
            Hot_Cue_Sec_By_Track[which_track][pad_index] = Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
    else:
        Hot_Cue_Sec_By_Track[which_track][pad_index] = HOT_CUE_UNSET_SEC


func _performance_pad_handle_sampler(which_track: int, pad_index: int) -> void:
    var players_for_track: Array = _performance_pad_sampler_players_by_track[which_track]
    if players_for_track.is_empty():
        return
    if pad_index < 0 or pad_index >= players_for_track.size():
        return
    var sampler_player: AudioStreamPlayer = players_for_track[pad_index] as AudioStreamPlayer
    if sampler_player == null or sampler_player.stream == null:
        return
    sampler_player.play()


func _performance_pad_handle_fx_hold(which_track: int, pad_index: int, is_pressed: bool) -> void:
    var selected_set: int = Selected_FX_Set_By_Track[which_track]
    var fx_list: Array[BUS_MANAGER.E_BEAT_FX_TYPE] = FX_SET_1_TYPES if selected_set == 1 else FX_SET_2_TYPES
    if pad_index < 0 or pad_index >= fx_list.size():
        return

    var hold_state: Array = _performance_pad_fx_hold_active_by_track[which_track]
    if pad_index < 0 or pad_index >= hold_state.size():
        return

    var fx_type: BUS_MANAGER.E_BEAT_FX_TYPE = fx_list[pad_index]
    if is_pressed:
        if not BUS_MANAGER.is_beat_fx_active(fx_type, which_track):
            BUS_MANAGER.add_beat_fx(fx_type, which_track)
        hold_state[pad_index] = true
    else:
        BUS_MANAGER.remove_beat_fx(fx_type, which_track)
        hold_state[pad_index] = false


func _clear_held_fx_for_track(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var hold_state: Array = _performance_pad_fx_hold_active_by_track[which_track]
    for pad_index: int in range(min(PERFORMANCE_PAD_COUNT, hold_state.size())):
        if bool(hold_state[pad_index]):
            _performance_pad_handle_fx_hold(which_track, pad_index, false)


func _performance_pad_handle_beat_jump(which_track: int, pad_index: int) -> void:
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return

    var beat_len_stream_sec: float = _beat_len_stream_sec(which_track)
    if beat_len_stream_sec <= 0.0:
        return

    var jump_beats: float = BEAT_JUMP_STEPS_BEATS[pad_index]
    var current_pos_sec: float = Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
    var stream_len_sec: float = _stream_len_sec(which_track)
    var new_pos_sec: float = current_pos_sec + (jump_beats * beat_len_stream_sec)
    if stream_len_sec > 0.0:
        new_pos_sec = clampf(new_pos_sec, 0.0, maxf(0.0, stream_len_sec - 0.001))
    _apply_track_seek(which_track, new_pos_sec)


func _performance_pad_handle_key_shift(which_track: int, pad_index: int) -> void:
    var semitones: int = KEY_SHIFT_STEPS_SEMITONES[pad_index]
    Key_Shift_Semitones_By_Track[which_track] = semitones

    if not BUS_MANAGER.is_beat_fx_active(BUS_MANAGER.E_BEAT_FX_TYPE.PITCH, which_track):
        BUS_MANAGER.add_beat_fx(BUS_MANAGER.E_BEAT_FX_TYPE.PITCH, which_track)

    BUS_MANAGER.Set_Pitch_Shift_Semitone_Override(which_track, semitones)


func _update_performance_pad_feedback(delta: float) -> void:
    _performance_pad_pulse_time += delta
    var pulse_wave: float = 0.5 + 0.5 * sin(_performance_pad_pulse_time * TAU * 0.9)
    var pulse_alpha: float = lerpf(0.16, 0.34, pulse_wave)

    for which_track: int in range(0, 2):
        var controls_for_track: Array = _performance_pad_controls_by_track[which_track]
        var players_for_track: Array = _performance_pad_sampler_players_by_track[which_track]
        var pulse_materials_for_track: Array = _performance_pad_pulse_materials_by_track[which_track]
        var fx_hold_state_for_track: Array = _performance_pad_fx_hold_active_by_track[which_track]
        var hot_cue_mode_active: bool = Performance_Pad_Mode_By_Track[which_track] == E_Performance_Pad_Mode.HOT_CUE
        var sampler_mode_active: bool = Performance_Pad_Mode_By_Track[which_track] == E_Performance_Pad_Mode.SAMPLER
        var fx_mode_active: bool = (
            Performance_Pad_Mode_By_Track[which_track] == E_Performance_Pad_Mode.FX_SET_1
            or Performance_Pad_Mode_By_Track[which_track] == E_Performance_Pad_Mode.FX_SET_2
        )

        for pad_index: int in range(min(PERFORMANCE_PAD_COUNT, controls_for_track.size(), players_for_track.size(), pulse_materials_for_track.size(), fx_hold_state_for_track.size())):
            var pad_control: Base_Control = controls_for_track[pad_index] as Base_Control
            var sampler_player: AudioStreamPlayer = players_for_track[pad_index] as AudioStreamPlayer
            var pulse_mat: StandardMaterial3D = pulse_materials_for_track[pad_index] as StandardMaterial3D
            if pad_control == null or pulse_mat == null or pad_control.Target_Mesh == null:
                continue

            var sampler_playing: bool = sampler_mode_active and sampler_player != null and sampler_player.playing
            var should_pulse: bool = (
                (hot_cue_mode_active and Has_Hot_Cue(which_track, pad_index))
                or sampler_playing
                or (fx_mode_active and bool(fx_hold_state_for_track[pad_index]))
            )
            if should_pulse and pad_control.fully_exited:
                var pad_color: Color = Get_Performance_Pad_Color(pad_index)
                pulse_mat.albedo_color = Color(pad_color.r, pad_color.g, pad_color.b, pulse_alpha)
                pad_control.Target_Mesh.material_overlay = pulse_mat
            else:
                if pad_control.Target_Mesh.material_overlay == pulse_mat:
                    pad_control.Target_Mesh.material_overlay = null
            _update_performance_pad_label(which_track, pad_index, pad_control)


func _update_performance_pad_label(which_track: int, pad_index: int, pad_control: Base_Control) -> void:
    if pad_control == null:
        return

    var perf_pad_control: Performance_Pad_Control = pad_control as Performance_Pad_Control
    if perf_pad_control != null:
        var mode: int = Performance_Pad_Mode_By_Track[which_track]
        var jump_beats: float = BEAT_JUMP_STEPS_BEATS[pad_index]
        var key_shift_semis: int = KEY_SHIFT_STEPS_SEMITONES[pad_index]
        var fx_context: Dictionary = _get_fx_context_for_pad(which_track, pad_index)
        perf_pad_control.refresh_runtime_label(
            mode,
            Hot_Cue_Add_Mode_By_Track[which_track],
            jump_beats,
            key_shift_semis,
            fx_context["fx_type"],
            fx_context["variant_index"]
        )
        return

    var fallback_text: String = "Samp %d" % (pad_index + 1)
    var label_3d: Label3D = pad_control.get_node_or_null("Label3D") as Label3D
    if label_3d != null and label_3d.text != fallback_text:
        label_3d.text = fallback_text


func _get_fx_context_for_pad(which_track: int, pad_index: int) -> Dictionary:
    var selected_set: int = Selected_FX_Set_By_Track[which_track]
    var fx_list: Array[BUS_MANAGER.E_BEAT_FX_TYPE] = FX_SET_1_TYPES if selected_set == 1 else FX_SET_2_TYPES
    if pad_index < 0 or pad_index >= fx_list.size():
        return {"fx_type": -1, "variant_index": 0}

    var fx_type: BUS_MANAGER.E_BEAT_FX_TYPE = fx_list[pad_index]

    var duplicate_indices: Array[int] = []
    for fx_idx: int in range(fx_list.size()):
        if fx_list[fx_idx] == fx_type:
            duplicate_indices.append(fx_idx)

    var variant_index: int = 0
    if duplicate_indices.size() > 1:
        variant_index = duplicate_indices.find(pad_index) + 1
    return {"fx_type": int(fx_type), "variant_index": variant_index}


func _on_performance_pad_pressed(which_track: int, pad_index: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    pad_index = clampi(pad_index, 0, PERFORMANCE_PAD_COUNT - 1)
    var selected_mode: int = Performance_Pad_Mode_By_Track[which_track]
    if selected_mode == E_Performance_Pad_Mode.FX_SET_1 or selected_mode == E_Performance_Pad_Mode.FX_SET_2:
        _performance_pad_handle_fx_hold(which_track, pad_index, true)


func _on_performance_pad_released(which_track: int, pad_index: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    pad_index = clampi(pad_index, 0, PERFORMANCE_PAD_COUNT - 1)
    var hold_state: Array = _performance_pad_fx_hold_active_by_track[which_track]
    if pad_index >= 0 and pad_index < hold_state.size() and bool(hold_state[pad_index]):
        _performance_pad_handle_fx_hold(which_track, pad_index, false)

func _beat_len_stream_sec(which_track: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var base_bpm: float = LibreBox.Get_Track_BPM(which_track)
    if base_bpm <= 0.0:
        return 0.0
    return 60.0 / base_bpm


func _stream_len_sec(which_track: int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return 0.0
    return float(AudioPlayerList[which_track].stream.get_length())


func _get_loop_quantized_point_sec(which_track: int, use_beat_start: bool, use_beat_end: bool) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var pos: float = Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
    if not Loop_Point_Snapping_Enabled[which_track]:
        return pos

    var beat_len: float = _beat_len_stream_sec(which_track)
    if beat_len <= 0.0:
        return pos

    var beat_index: int = int(floor(pos / beat_len))
    if use_beat_end:
        return (beat_index + 1) * beat_len
    if use_beat_start:
        return beat_index * beat_len
    return pos


func _set_loop_points_sec(which_track: int, start_sec: float, end_sec: float) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var stream_len: float = _stream_len_sec(which_track)
    if stream_len <= 0.0:
        Loop_Enabled[which_track] = false
        Loop_Start_Sec[which_track] = 0.0
        Loop_End_Sec[which_track] = 0.0
        return

    start_sec = clampf(start_sec, 0.0, maxf(0.0, stream_len - 0.001))
    end_sec = clampf(end_sec, 0.0, maxf(0.0, stream_len - 0.001))

    var beat_len: float = _beat_len_stream_sec(which_track)
    var min_len_sec: float = 0.01
    if beat_len > 0.0:
        min_len_sec = maxf(0.01, beat_len * LOOP_MIN_BEATS)

    if end_sec < start_sec + min_len_sec:
        end_sec = clampf(start_sec + min_len_sec, 0.0, maxf(0.0, stream_len - 0.001))

    Loop_Start_Sec[which_track] = start_sec
    Loop_End_Sec[which_track] = end_sec
    Loop_Enabled[which_track] = true
    Loop_Start_Armed[which_track] = true
    Loop_End_Armed[which_track] = true


func _loop_seek_on_main(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    
    if not Loop_Enabled[which_track]:
        return
        
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        Loop_Enabled[which_track] = false
        return
    
    if not AudioPlayerList[which_track].playing:
        return

    var now_ms: int = Time.get_ticks_msec()
    if now_ms - _loop_last_seek_ms[which_track] < LOOP_SEEK_COOLDOWN_MS:
        return
        
    _loop_last_seek_ms[which_track] = now_ms

    if AudioPlayerList[which_track].has_stream_playback():
        #AudioPlayerList[which_track].seek(Loop_Start_Sec[which_track])
        AudioPlayerList[which_track].call_deferred("seek", Loop_Start_Sec[which_track] )
    else:
        AudioPlayerList[which_track].play(Loop_Start_Sec[which_track])


func _loop_thread_main(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)

    while _loop_thread_run[which_track] or not Use_Multi_threaded_looping:
        if (Loop_Enabled[which_track] or not Use_Multi_threaded_looping) and AudioPlayerList[which_track] != null and AudioPlayerList[which_track].stream != null:
            if AudioPlayerList[which_track].playing:
                if (Track_1_playback_pos if which_track == 0 else Track_2_playback_pos) >= Loop_End_Sec[which_track]:
                    call_deferred("_loop_seek_on_main", which_track)
                    #_loop_seek_on_main(which_track)
                        
        OS.delay_msec(6)
                


func Loop_Set_Start_Point(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var start_sec: float = _get_loop_quantized_point_sec(which_track, true, false)
    Loop_Start_Sec[which_track] = start_sec
    Loop_Start_Armed[which_track] = true
    # Do NOT enable loop until end point is armed too.
    if Loop_End_Armed[which_track]:
        _set_loop_points_sec(which_track, Loop_Start_Sec[which_track], Loop_End_Sec[which_track])


func Loop_Set_End_Point(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var end_sec: float = _get_loop_quantized_point_sec(which_track, false, true)
    Loop_End_Sec[which_track] = end_sec
    Loop_End_Armed[which_track] = true
    # Do NOT enable loop until start point is armed too.
    if Loop_Start_Armed[which_track]:
        _set_loop_points_sec(which_track, Loop_Start_Sec[which_track], Loop_End_Sec[which_track])


func Loop_Make_4_Beat_Toggle(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    # Pressing again should *exit* the loop and keep playing normally.
    if Loop_Enabled[which_track]:
        Loop_Enabled[which_track] = false
        return

    var beat_len: float = _beat_len_stream_sec(which_track)
    var start_sec: float = _get_loop_quantized_point_sec(which_track, true, false) if Loop_Point_Snapping_Enabled[which_track] else Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
    var end_sec: float = start_sec + (4.0 * beat_len if beat_len > 0.0 else 2.0)
    _set_loop_points_sec(which_track, start_sec, end_sec)


func Loop_Shorten(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if not Loop_Enabled[which_track]:
        return
    var beat_len: float = _beat_len_stream_sec(which_track)
    if beat_len <= 0.0:
        return
    var cur_len_sec: float = maxf(0.0, Loop_End_Sec[which_track] - Loop_Start_Sec[which_track])
    var cur_beats: float = cur_len_sec / beat_len
    var new_beats: float = maxf(LOOP_MIN_BEATS, cur_beats * 0.5)
    var new_end: float = Loop_Start_Sec[which_track] + new_beats * beat_len
    _set_loop_points_sec(which_track, Loop_Start_Sec[which_track], new_end)


func Loop_Extend(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if not Loop_Enabled[which_track]:
        return
    var beat_len: float = _beat_len_stream_sec(which_track)
    if beat_len <= 0.0:
        return
    var cur_len_sec: float = maxf(0.0, Loop_End_Sec[which_track] - Loop_Start_Sec[which_track])
    var cur_beats: float = cur_len_sec / beat_len
    var new_beats: float = minf(LOOP_MAX_BEATS, cur_beats * 2.0)
    var new_end: float = Loop_Start_Sec[which_track] + new_beats * beat_len
    _set_loop_points_sec(which_track, Loop_Start_Sec[which_track], new_end)


func LoadTrackIntoMemory(which_track : int, which_song : Song):
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    print("Spawned Player for Track ", which_track)
    Clear_All_Hot_Cues(which_track)
    Regular_Cue_Sec_By_Track[which_track] = 0.0
    _regular_cue_is_set_by_track[which_track] = false
    _regular_cue_hold_active_by_track[which_track] = false
    _regular_cue_hold_was_playing_by_track[which_track] = false
    BUS_MANAGER.Clear_Pitch_Shift_Semitone_Override(which_track)
    Key_Shift_Semitones_By_Track[which_track] = 0
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
    _setup_performance_pad_defaults()
    _setup_performance_pad_nodes_and_signals()
    AudioPlayerList[0].stream_paused = true
    AudioPlayerList[1].stream_paused = true
    AudioPlayerList[2].stream_paused = true
    AudioPlayerList[3].stream_paused = true
     
    _on_reset_area_area_entered(null)
    _setup_jogwheel_targets()
    _configure_knob_popup_labels()
    all_ready.emit()
    #CreateInteractableControl(btn_PausePlay_ref, E_CONTROLTYPE.BUTTON)
    if Use_Multi_threaded_looping:
        _start_loop_threads()
    if Use_Multi_Threaded_Jog_Warp:
        _start_jog_seek_threads()


func _configure_knob_popup_labels() -> void:
    Core_FX_Knobs_TRIM_L.knob_label_key = "KEY_KNOB_TRIM_LEFT"
    Core_FX_Knobs_TRIM_L.knob_memory_key = "trim_left"
    Core_FX_Knobs_TRIM_L.value_display_mode = Knob_Control.E_Knob_Value_Display_Mode.DECIBEL
    Core_FX_Knobs_TRIM_L.decibel_linear_min = 0.001
    Core_FX_Knobs_TRIM_L.decibel_linear_max = 2.0
    Core_FX_Knobs_TRIM_L.decibel_decimal_places = 1

    Core_FX_Knobs_TRIM_R.knob_label_key = "KEY_KNOB_TRIM_RIGHT"
    Core_FX_Knobs_TRIM_R.knob_memory_key = "trim_right"
    Core_FX_Knobs_TRIM_R.value_display_mode = Knob_Control.E_Knob_Value_Display_Mode.DECIBEL
    Core_FX_Knobs_TRIM_R.decibel_linear_min = 0.001
    Core_FX_Knobs_TRIM_R.decibel_linear_max = 2.0
    Core_FX_Knobs_TRIM_R.decibel_decimal_places = 1

    Beat_FX_Knob.knob_label_key = "KEY_KNOB_BEAT_FX_AMOUNT"
    Beat_FX_Knob.knob_memory_key = "beat_fx_amount"
    Beat_FX_Knob.value_display_mode = Knob_Control.E_Knob_Value_Display_Mode.NORMALIZED
    Beat_FX_Knob.normalized_decimal_places = 2
    

func _exit_tree() -> void:
    _stop_loop_threads()
    _stop_jog_seek_threads()


func _start_loop_threads() -> void:
    for i in range(0, 2):
        if _loop_threads[i] != null:
            continue
        _loop_thread_run[i] = true
        _loop_threads[i] = Thread.new()
        _loop_threads[i].start(_loop_thread_main.bind(i), Thread.PRIORITY_HIGH)


func _start_jog_seek_threads() -> void:
    for track_index: int in range(0, 2):
        if _jog_seek_threads[track_index] != null:
            continue
        _jog_seek_thread_run[track_index] = true
        _jog_seek_threads[track_index] = Thread.new()
        _jog_seek_threads[track_index].start(_jog_seek_thread_main.bind(track_index), Thread.PRIORITY_HIGH)


func _stop_jog_seek_threads() -> void:
    for track_index: int in range(0, _jog_seek_threads.size()):
        if _jog_seek_threads[track_index] == null:
            continue
        _jog_seek_thread_run[track_index] = false
        _jog_seek_threads[track_index].wait_to_finish()
        _jog_seek_threads[track_index] = null


func _jog_seek_thread_main(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    while _jog_seek_thread_run[which_track]:
        var pending_seek_seconds: float = _jog_pending_seek_seconds[which_track]
        if pending_seek_seconds >= 0.0:
            _jog_pending_seek_seconds[which_track] = -1.0
            call_deferred("_apply_track_seek", which_track, pending_seek_seconds)
        OS.delay_msec(2)


func _setup_jogwheel_targets() -> void:
    Left_Jogwheel_Mesh = find_child("Left Spin", true, false) as MeshInstance3D
    Right_Jogwheel_Mesh = find_child("Right Spin", true, false) as MeshInstance3D

    if Left_Jogwheel_Mesh != null:
        Left_Jogwheel_Node.global_position = Left_Jogwheel_Mesh.global_position
    if Right_Jogwheel_Mesh != null:
        Right_Jogwheel_Node.global_position = Right_Jogwheel_Mesh.global_position

    if Left_Jogwheel_Collision_Shape.shape is CylinderShape3D:
        var left_cylinder_shape: CylinderShape3D = Left_Jogwheel_Collision_Shape.shape as CylinderShape3D
        left_cylinder_shape.radius = Jogwheel_Grab_Radius_Meters
    if Right_Jogwheel_Collision_Shape.shape is CylinderShape3D:
        var right_cylinder_shape: CylinderShape3D = Right_Jogwheel_Collision_Shape.shape as CylinderShape3D
        right_cylinder_shape.radius = Jogwheel_Grab_Radius_Meters
    _all_player_fingers.clear()
    _collect_player_fingers(get_tree().current_scene)


func _collect_player_fingers(root_node: Node) -> void:
    if root_node == null:
        return
    if root_node is Player_Finger:
        _all_player_fingers.append(root_node as Player_Finger)
    var child_nodes: Array[Node] = root_node.get_children()
    for child_node: Node in child_nodes:
        _collect_player_fingers(child_node)


func _is_pose_allowed_for_jogwheel(which_finger: Player_Finger) -> bool:
    if which_finger == null:
        return false
    if which_finger.is_right_hand:
        return Player_Finger.CURRENT_RIGHT_HAND_POSE == Player_Finger.E_POSES.FIST or Player_Finger.CURRENT_RIGHT_HAND_POSE == Player_Finger.E_POSES.INDEX_THUMB_PINCH
    return Player_Finger.CURRENT_LEFT_HAND_POSE == Player_Finger.E_POSES.FIST or Player_Finger.CURRENT_LEFT_HAND_POSE == Player_Finger.E_POSES.INDEX_THUMB_PINCH


func _is_finger_allowed_for_track(which_track: int, which_finger: Player_Finger) -> bool:
    if which_finger == null:
        return false
    if not Restrict_Jogwheel_To_Matching_Hand:
        return true
    if which_track == 0:
        return not which_finger.is_right_hand
    return which_finger.is_right_hand


func _get_jogwheel_mesh_for_track(which_track: int) -> MeshInstance3D:
    if which_track == 0:
        return Left_Jogwheel_Mesh
    return Right_Jogwheel_Mesh


func _get_jogwheel_finger_for_track(which_track: int) -> Player_Finger:
    if which_track == 0:
        return Left_Jogwheel_Finger
    return Right_Jogwheel_Finger


func _set_jogwheel_finger_for_track(which_track: int, which_finger: Player_Finger) -> void:
    if which_track == 0:
        Left_Jogwheel_Finger = which_finger
        return
    Right_Jogwheel_Finger = which_finger


func _clear_jog_angle_tracking(which_track: int) -> void:
    _jog_last_angle_radians[which_track] = 0.0
    _jog_has_last_angle[which_track] = false


func _get_jogwheel_anchor_for_track(which_track: int) -> Node3D:
    if which_track == 0:
        return Left_Jogwheel_Node
    return Right_Jogwheel_Node


func _get_jogwheel_touch_angle_radians(which_track: int, which_finger: Player_Finger) -> float:
    var jog_anchor: Node3D = _get_jogwheel_anchor_for_track(which_track)
    if jog_anchor == null or which_finger == null:
        return 0.0
    var local_finger_position: Vector3 = jog_anchor.to_local(which_finger.global_position)
    return atan2(local_finger_position.x, local_finger_position.z)


func _apply_track_seek(which_track: int, seek_seconds: float) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return
        
    if _jog_touch_active[which_track]:
        if Jogwheel_Enable_Audible_Scratching:
            # Explicit play-at-position each jog sample gives audible scratch and prevents drift
            #AudioPlayerList[which_track].play(seek_seconds)
            if AudioPlayerList[which_track].stream_paused:
                AudioPlayerList[which_track].play(seek_seconds)
            else:
                AudioPlayerList[which_track].stream_paused = false
                AudioPlayerList[which_track].seek(seek_seconds)
            
        elif AudioPlayerList[which_track].has_stream_playback():
            AudioPlayerList[which_track].seek(seek_seconds)
            AudioPlayerList[which_track].stream_paused = true
            
        else:
            AudioPlayerList[which_track].play(seek_seconds)
            
        return
    if AudioPlayerList[which_track].has_stream_playback():
        AudioPlayerList[which_track].seek(seek_seconds)
    else:
        AudioPlayerList[which_track].play(seek_seconds)


func _warp_track_from_jogwheel(which_track: int, rotation_radians: float) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if absf(rotation_radians) <= 0.001:
        return
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return

    var stream_length_seconds: float = Track_1_playback_length if which_track == 0 else Track_2_playback_length
    var current_position_seconds: float = Track_1_playback_pos if which_track == 0 else Track_2_playback_pos
    
    if _jog_touch_active[which_track] and _jog_has_virtual_position[which_track]:
        current_position_seconds = _jog_virtual_position_seconds[which_track]
        
    var stream_delta_seconds: float = (-rotation_radians / TAU) * Jogwheel_Audio_Warp_Seconds_Per_Full_Rotation
    var unclamped_position_seconds: float = current_position_seconds + stream_delta_seconds
    var new_position_seconds: float = maxf(0.0, unclamped_position_seconds)
    
    if stream_length_seconds > 0.0:
        new_position_seconds = clampf(new_position_seconds, 0.0, maxf(0.0, stream_length_seconds - 0.001))
        
    if _jog_touch_active[which_track]:
        _jog_virtual_position_seconds[which_track] = new_position_seconds
        _jog_has_virtual_position[which_track] = true

    if _jog_touch_active[which_track]:
        _apply_track_seek(which_track, new_position_seconds)
        
    elif Use_Multi_Threaded_Jog_Warp:
        _jog_pending_seek_seconds[which_track] = new_position_seconds
        
    else:
        _apply_track_seek(which_track, new_position_seconds)


func _rotate_jogwheel_mesh_visual(which_track: int, rotation_radians: float) -> void:
    var target_mesh: MeshInstance3D = _get_jogwheel_mesh_for_track(which_track)
    if target_mesh == null:
        return
    target_mesh.rotate_y(-rotation_radians)


func _get_jogwheel_activation_for_track(which_track: int) -> Area3D:
    if which_track == 0:
        return Left_Jogwheel_Activation
    return Right_Jogwheel_Activation


func _release_jogwheel_finger_if_out_of_snap_range(which_track: int) -> void:
    if not Use_Snap_Style_Jogwheel_Grab:
        return
    var active_finger: Player_Finger = _get_jogwheel_finger_for_track(which_track)
    var target_mesh: MeshInstance3D = _get_jogwheel_mesh_for_track(which_track)
    if active_finger == null or target_mesh == null:
        return
    var distance_from_wheel_center: float = active_finger.global_position.distance_to(target_mesh.global_position)
    var release_distance: float = Jogwheel_Grab_Radius_Meters * 2.5
    if distance_from_wheel_center > release_distance:
        _set_jogwheel_finger_for_track(which_track, null)
        _clear_jog_angle_tracking(which_track)


func _try_acquire_jogwheel_finger_from_overlap(which_track: int) -> void:
    if _get_jogwheel_finger_for_track(which_track) != null:
        return

    if Use_Snap_Style_Jogwheel_Grab:
        var target_mesh: MeshInstance3D = _get_jogwheel_mesh_for_track(which_track)
        if target_mesh == null:
            return
        var snap_distance: float = Jogwheel_Grab_Radius_Meters * 1.6
        var best_distance: float = INF
        var best_finger: Player_Finger = null
        for candidate_finger: Player_Finger in _all_player_fingers:
            if candidate_finger == null or not is_instance_valid(candidate_finger):
                continue
            if not _is_finger_allowed_for_track(which_track, candidate_finger):
                continue
            if not _is_pose_allowed_for_jogwheel(candidate_finger):
                continue
            var candidate_distance: float = candidate_finger.global_position.distance_to(target_mesh.global_position)
            if candidate_distance <= snap_distance and candidate_distance < best_distance:
                best_distance = candidate_distance
                best_finger = candidate_finger
        if best_finger != null:
            _set_jogwheel_finger_for_track(which_track, best_finger)
            _clear_jog_angle_tracking(which_track)
        return

    var activation_area: Area3D = _get_jogwheel_activation_for_track(which_track)
    if activation_area == null:
        return

    var overlapping_areas: Array[Area3D] = activation_area.get_overlapping_areas()
    for overlapping_area: Area3D in overlapping_areas:
        if not (overlapping_area is Player_Finger):
            continue
        var candidate_finger_from_overlap: Player_Finger = overlapping_area as Player_Finger
        if not _is_finger_allowed_for_track(which_track, candidate_finger_from_overlap):
            continue
        if not _is_pose_allowed_for_jogwheel(candidate_finger_from_overlap):
            continue
        _set_jogwheel_finger_for_track(which_track, candidate_finger_from_overlap)
        _clear_jog_angle_tracking(which_track)
        return


func _resume_track_after_jog_touch(which_track: int) -> void:
    if AudioPlayerList[which_track] == null or AudioPlayerList[which_track].stream == null:
        return

    var resume_position_seconds: float = Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
    if _jog_has_virtual_position[which_track]:
        resume_position_seconds = _jog_virtual_position_seconds[which_track]

    if _jog_resume_after_touch[which_track]:
        AudioPlayerList[which_track].seek(resume_position_seconds)
        AudioPlayerList[which_track].stream_paused = false
    else:
        _apply_track_seek(which_track, resume_position_seconds)
        if AudioPlayerList[which_track].playing:
            AudioPlayerList[which_track].stream_paused = true


func _update_jogwheel_track(which_track: int, delta: float) -> void:
    _try_acquire_jogwheel_finger_from_overlap(which_track)
    var active_finger: Player_Finger = _get_jogwheel_finger_for_track(which_track)
    var target_mesh: MeshInstance3D = _get_jogwheel_mesh_for_track(which_track)
    if target_mesh == null:
        return

    if active_finger != null:
        if not is_instance_valid(active_finger) or not _is_pose_allowed_for_jogwheel(active_finger):
            _set_jogwheel_finger_for_track(which_track, null)
            _clear_jog_angle_tracking(which_track)
            active_finger = null
        else:
            _release_jogwheel_finger_if_out_of_snap_range(which_track)
            active_finger = _get_jogwheel_finger_for_track(which_track)

    if active_finger != null:
        if not _jog_touch_active[which_track]:
            _jog_touch_active[which_track] = true
            _jog_resume_after_touch[which_track] = AudioPlayerList[which_track] != null and AudioPlayerList[which_track].playing and not AudioPlayerList[which_track].stream_paused
            _jog_virtual_position_seconds[which_track] = Utility.Return_Valid(AudioPlayerList[which_track].get_playback_position(), 0.0)
            _jog_has_virtual_position[which_track] = true

        var current_angle_radians: float = _get_jogwheel_touch_angle_radians(which_track, active_finger)
        if not _jog_has_last_angle[which_track]:
            _jog_last_angle_radians[which_track] = current_angle_radians
            _jog_has_last_angle[which_track] = true
            if AudioPlayerList[which_track] != null and AudioPlayerList[which_track].playing:
                AudioPlayerList[which_track].stream_paused = true
            return

        var delta_angle_radians: float = wrapf(current_angle_radians - _jog_last_angle_radians[which_track], -PI, PI)
        _jog_last_angle_radians[which_track] = current_angle_radians

        if absf(delta_angle_radians) <= 0.0001:
            # Keep hard-holding current sample position while hand is touching.
            if _jog_has_virtual_position[which_track]:
                _apply_track_seek(which_track, _jog_virtual_position_seconds[which_track])
            return

        # clockwise spin should move audio forward
        delta_angle_radians *= -1.0

        _rotate_jogwheel_mesh_visual(which_track, delta_angle_radians)
        _warp_track_from_jogwheel(which_track, delta_angle_radians)
        return
    elif _jog_touch_active[which_track]:
        _resume_track_after_jog_touch(which_track)
        _jog_touch_active[which_track] = false
        _jog_resume_after_touch[which_track] = false
        _jog_has_virtual_position[which_track] = false
        _clear_jog_angle_tracking(which_track)

    if AudioPlayerList[which_track] != null and AudioPlayerList[which_track].stream != null and AudioPlayerList[which_track].playing and not AudioPlayerList[which_track].stream_paused:
        var track_speed_multiplier: float = maxf(0.0, AudioPlayerList[which_track].pitch_scale)
        var auto_spin_radians: float = TAU * Jogwheel_Auto_Spin_Rotations_Per_Second_At_Normal_Speed * track_speed_multiplier * delta
        _rotate_jogwheel_mesh_visual(which_track, auto_spin_radians)


func _on_left_jog_activation_area_entered(area: Area3D) -> void:
    if not (area is Player_Finger):
        return
    var target_finger: Player_Finger = area as Player_Finger
    if not _is_finger_allowed_for_track(0, target_finger):
        return
    if not _is_pose_allowed_for_jogwheel(target_finger):
        return
    Left_Jogwheel_Finger = target_finger
    _clear_jog_angle_tracking(0)


func _on_left_jog_activation_area_exited(area: Area3D) -> void:
    if Use_Snap_Style_Jogwheel_Grab:
        return
    if area == Left_Jogwheel_Finger:
        Left_Jogwheel_Finger = null
        _clear_jog_angle_tracking(0)


func _on_right_jog_activation_area_entered(area: Area3D) -> void:
    if not (area is Player_Finger):
        return
    var target_finger: Player_Finger = area as Player_Finger
    if not _is_finger_allowed_for_track(1, target_finger):
        return
    if not _is_pose_allowed_for_jogwheel(target_finger):
        return
    Right_Jogwheel_Finger = target_finger
    _clear_jog_angle_tracking(1)


func _on_right_jog_activation_area_exited(area: Area3D) -> void:
    if Use_Snap_Style_Jogwheel_Grab:
        return
    if area == Right_Jogwheel_Finger:
        Right_Jogwheel_Finger = null
        _clear_jog_angle_tracking(1)


func _stop_loop_threads() -> void:
    for i in range(0, _loop_threads.size()):
        if _loop_threads[i] == null:
            continue
        _loop_thread_run[i] = false
        _loop_threads[i].wait_to_finish()
        _loop_threads[i] = null


func _on_left_play_on_activated() -> void:
    Play_Pause(0)


func _on_right_play_on_activated() -> void:
    Play_Pause(1)


func _on_left_cue_on_pressed() -> void:
    _on_cue_pressed(0)


func _on_right_cue_on_pressed() -> void:
    _on_cue_pressed(1)


func _on_left_cue_on_released() -> void:
    _on_cue_released(0)


func _on_right_cue_on_released() -> void:
    _on_cue_released(1)


func _on_cue_pressed(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var target_player: AudioStreamPlayer = AudioPlayerList[which_track]
    if target_player == null or target_player.stream == null:
        return

    const CUE_REARM_TOLERANCE_SECONDS: float = 0.02
    var current_position_seconds: float = Utility.Return_Valid(target_player.get_playback_position(), 0.0)
    var was_paused_before_press: bool = (not target_player.playing) or target_player.stream_paused
    var should_rearm_cue_while_paused: bool = false
    if was_paused_before_press:
        if not _regular_cue_is_set_by_track[which_track]:
            should_rearm_cue_while_paused = true
        else:
            should_rearm_cue_while_paused = absf(current_position_seconds - Regular_Cue_Sec_By_Track[which_track]) > CUE_REARM_TOLERANCE_SECONDS

    if should_rearm_cue_while_paused:
        Regular_Cue_Sec_By_Track[which_track] = current_position_seconds
        _regular_cue_is_set_by_track[which_track] = true
        _regular_cue_hold_active_by_track[which_track] = false
        _regular_cue_hold_was_playing_by_track[which_track] = false
        return

    if not _regular_cue_is_set_by_track[which_track]:
        Regular_Cue_Sec_By_Track[which_track] = 0.0
        _regular_cue_is_set_by_track[which_track] = true

    var cue_position_seconds: float = clampf(Regular_Cue_Sec_By_Track[which_track], 0.0, float(target_player.stream.get_length()))
    _apply_track_seek(which_track, cue_position_seconds)

    _regular_cue_hold_active_by_track[which_track] = true
    _regular_cue_hold_was_playing_by_track[which_track] = not was_paused_before_press

    if target_player.playing:
        target_player.stream_paused = false
    else:
        target_player.play(cue_position_seconds)


func _on_cue_released(which_track: int) -> void:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    if not _regular_cue_hold_active_by_track[which_track]:
        return

    var target_player: AudioStreamPlayer = AudioPlayerList[which_track]
    if target_player == null or target_player.stream == null:
        _regular_cue_hold_active_by_track[which_track] = false
        _regular_cue_hold_was_playing_by_track[which_track] = false
        return

    if not _regular_cue_is_set_by_track[which_track]:
        _regular_cue_hold_active_by_track[which_track] = false
        _regular_cue_hold_was_playing_by_track[which_track] = false
        return

    var cue_position_seconds: float = clampf(Regular_Cue_Sec_By_Track[which_track], 0.0, float(target_player.stream.get_length()))
    _apply_track_seek(which_track, cue_position_seconds)
    target_player.stream_paused = true
    _regular_cue_hold_active_by_track[which_track] = false
    _regular_cue_hold_was_playing_by_track[which_track] = false


        


## Updates channel output levels using crossfader and channel faders.
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



## Updates trim, EQ, and colour FX bus effect parameters for both decks.
## Slot layout: trim=0, EQ=1, low-pass=2, high-pass=3.
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
                
        


## Updates per-deck tempo/pitch from tempo sliders and sync state.
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
 
var i : int = 0
func _process(delta: float) -> void:
    if i % 3 == 0:
        Track_1_playback_pos = AudioPlayerList.get(0).get_playback_position()   
        Track_2_playback_pos = AudioPlayerList.get(1).get_playback_position()   
        
        Track_1_playback_length = AudioPlayerList.get(0).stream.get_length() if AudioPlayerList.get(0).stream else -1.0   
        Track_2_playback_length = AudioPlayerList.get(1).stream.get_length() if AudioPlayerList.get(1).stream else -1.0
    i += 1
    
func _physics_process(delta: float) -> void:
    if not Use_Multi_threaded_looping:
        _loop_thread_main(0)
        _loop_thread_main(1)
    
    Update_Channel_Tempo_Adjusts()
    Update_Channel_DBs() # crossfades and stuff
    Update_Channel_Trim_EQ_CFX() # trim, EQ hi/mid/low, CFX per track
    # Beat FX "power": 0 = inaudible, 1 = full effect
    BUS_MANAGER.Apply_Beat_FX_Level(0, Beat_FX_Knob.Value)
    BUS_MANAGER.Apply_Beat_FX_Level(1, Beat_FX_Knob.Value)
    _update_jogwheel_track(0, delta)
    _update_jogwheel_track(1, delta)
    _update_performance_pad_feedback(delta)

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
    Left_Jogwheel_Finger = null
    Right_Jogwheel_Finger = null
    _clear_jog_angle_tracking(0)
    _clear_jog_angle_tracking(1)
    _jog_touch_active[0] = false
    _jog_touch_active[1] = false
    _jog_resume_after_touch[0] = false
    _jog_resume_after_touch[1] = false
    _jog_has_virtual_position[0] = false
    _jog_has_virtual_position[1] = false
    _clear_held_fx_for_track(0)
    _clear_held_fx_for_track(1)
    Performance_Pad_Mode_By_Track[0] = E_Performance_Pad_Mode.HOT_CUE
    Performance_Pad_Mode_By_Track[1] = E_Performance_Pad_Mode.HOT_CUE
    Hot_Cue_Add_Mode_By_Track[0] = true
    Hot_Cue_Add_Mode_By_Track[1] = true
    Regular_Cue_Sec_By_Track[0] = 0.0
    Regular_Cue_Sec_By_Track[1] = 0.0
    _regular_cue_is_set_by_track[0] = false
    _regular_cue_is_set_by_track[1] = false
    _regular_cue_hold_active_by_track[0] = false
    _regular_cue_hold_active_by_track[1] = false
    _regular_cue_hold_was_playing_by_track[0] = false
    _regular_cue_hold_was_playing_by_track[1] = false
    Selected_FX_Set_By_Track[0] = 1
    Selected_FX_Set_By_Track[1] = 1
    Key_Shift_Semitones_By_Track[0] = 0
    Key_Shift_Semitones_By_Track[1] = 0
    BUS_MANAGER.Clear_Pitch_Shift_Semitone_Override(0)
    BUS_MANAGER.Clear_Pitch_Shift_Semitone_Override(1)

    for child in $Controls.get_children():
        if child is Base_Control:
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


func _on_left_loop_start_on_activated() -> void:
    Loop_Set_Start_Point(0)


func _on_left_loop_end_on_activated() -> void:
    Loop_Set_End_Point(0)


func _on_left_make_4_beat_loop_on_activated() -> void:
    Loop_Make_4_Beat_Toggle(0)


func _on_left_shorten_loop_on_activated() -> void:
    Loop_Shorten(0)


func _on_left_extend_loop_on_activated() -> void:
    Loop_Extend(0)


func _on_right_loop_start_on_activated() -> void:
    Loop_Set_Start_Point(1)


func _on_right_loop_end_on_activated() -> void:
    Loop_Set_End_Point(1)


func _on_right_make_4_beat_loop_on_activated() -> void:
    Loop_Make_4_Beat_Toggle(1)


func _on_right_shorten_loop_on_activated() -> void:
    Loop_Shorten(1)


func _on_right_extend_loop_on_activated() -> void:
    Loop_Extend(1)



## Cached temporaries for beat-phase sync to reduce allocations in a hot path.
# TODO: Move `_seek_track_phase_to_match` off the main thread if we can preserve behaviour and reduce hitching.
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
## Aligns moved track beat phase to reference track.
## This adjusts beat phase only, not absolute song position.
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
