extends Control
class_name LibreBox_HUB

## Main LibreBox hub UI controller.
## Syncs deck cards, waveform materials, beat pulses, and cue/loop markers.
@export var Track_1 : Song
@export var Track_2 : Song


const WAVEFORM_WINDOW_WIDTH = 1650 # TODO figure out how to compute this runtime
const WAVEFORM_WINDOW_HEIGHT = 240 


## Waveform generation ratio used by project waveform assets.
const PIXELS_PER_MINUTE = 1024 # THIS WAS DECIDED BY Assets/tools/generate_waveforms.py



@onready var Track_1_waveformVis : TextureRect = %"Track 1 Waveform preview"
@onready var Track_2_waveformVis : TextureRect = %"Track 2 Waveform preview"

const M_HORIZONTAL_PAN : ShaderMaterial = preload("res://Art/Materials/UI/M_Horizontal_Pan.tres")

const BEAT_PULSE_DURATION : float = 0.2
const LINE_COLOR_WHITE : Color = Color(1.0, 1.0, 1.0, 1.0)
const LINE_COLOR_BEAT : Color = Color(1.0, 0.2, 0.2, 1.0)

#@onready var _waveform_mat_1: ShaderMaterial = %"Track 1 Waveform preview".material
#@onready var _waveform_mat_2: ShaderMaterial = %"Track 2 Waveform preview".material
@onready var _waveform_mat_1: ShaderMaterial
@onready var _waveform_mat_2: ShaderMaterial

var _rhythm_1: RhythmNotifier
var _rhythm_2: RhythmNotifier



## Refreshes one side of the hub (track card + waveform texture + notifier BPM).
func Refresh(Set_Track_1 : bool) -> bool:
    var success = true
    if Set_Track_1:
        $"VBoxContainer/Track 1 Container/Track 1 Card".Set_New_Song(Track_1)
        if Track_1:
            if Track_1.Audio_File_Waveform == null:
                Track_1.Attempt_Find_waveform_from_audio_file_path()
        if Track_1 and Track_1.Audio_File_Waveform:
            if not Track_1_waveformVis:
                success = false
            else:
                Track_1_waveformVis.texture = Track_1.Audio_File_Waveform
        else:
            if not Track_1_waveformVis:
                success = false
            else:
                Track_1_waveformVis.texture = null
        if _rhythm_1:
            _rhythm_1.bpm = Track_1.Track_BPM if Track_1 else 120.0
    else:
        $"VBoxContainer/Track 2 Container/Track 2 Card".Set_New_Song(Track_2)
        if Track_2:
            if Track_2.Audio_File_Waveform == null:
                Track_2.Attempt_Find_waveform_from_audio_file_path()
        if Track_2 and Track_2.Audio_File_Waveform:
            if not Track_2_waveformVis:
                success = false
            else:
                Track_2_waveformVis.texture = Track_2.Audio_File_Waveform
        else:
            if not Track_2_waveformVis:
                success = false
            else:
                Track_2_waveformVis.texture = null
        if _rhythm_2:
            _rhythm_2.bpm = Track_2.Track_BPM if Track_2 else 120.0
    return success
    
    
    
## Initialises shader material instances and rhythm notifier nodes.
func _ready() -> void:
    # gotta do this horribleness because "local to scene" did nothing for some reason
    _waveform_mat_1 = M_HORIZONTAL_PAN.duplicate()
    Track_1_waveformVis.material = _waveform_mat_1
    _configure_hot_cue_shader_colours(_waveform_mat_1)
    
    _waveform_mat_2 = M_HORIZONTAL_PAN.duplicate()
    Track_2_waveformVis.material = _waveform_mat_2
    _configure_hot_cue_shader_colours(_waveform_mat_2)
    

    $"VBoxContainer/Track 1 Container/Track 1 Card".Song_Resource = Track_1
    $"VBoxContainer/Track 2 Container/Track 2 Card".Song_Resource = Track_2
    Refresh(true)
    Refresh(false)

    _setup_rhythm_notifiers()


## Applies configured pad colours to waveform hot-cue marker shader parameters.
func _configure_hot_cue_shader_colours(mat: ShaderMaterial) -> void:
    if mat == null:
        return
    for cue_index: int in range(DJ_Controller.PERFORMANCE_PAD_COUNT):
        var cue_idx: int = cue_index + 1
        var cue_color: Color = DJ_Controller.Get_Performance_Pad_Color(cue_index)
        mat.set_shader_parameter("hot_cue_%d_color" % cue_idx, cue_color)
    mat.set_shader_parameter("cue_visible", 0.0)

## Creates rhythm notifiers bound to left/right playback players.
func _setup_rhythm_notifiers() -> void:
    await LibreBox.Get_Instance_await()
    _rhythm_1 = RhythmNotifier.new()
    _rhythm_1.name = "RhythmNotifier_Track1"
    _rhythm_1.audio_stream_player = LibreBox.Get_Track_Playback_Player(0)
    _rhythm_1.bpm = Track_1.Track_BPM if Track_1 else 120.0
    add_child(_rhythm_1)
    _rhythm_1.beat.connect(_on_track_1_beat)

    _rhythm_2 = RhythmNotifier.new()
    _rhythm_2.name = "RhythmNotifier_Track2"
    _rhythm_2.audio_stream_player = LibreBox.Get_Track_Playback_Player(1)
    _rhythm_2.bpm = Track_2.Track_BPM if Track_2 else 120.0
    add_child(_rhythm_2)
    _rhythm_2.beat.connect(_on_track_2_beat)

func _pulse_line(mat: ShaderMaterial) -> void:
    mat.set_shader_parameter("line_color", LINE_COLOR_BEAT)
    var tween : Tween = create_tween()
    tween.tween_method(
        func(c: Color) -> void: mat.set_shader_parameter("line_color", c),
        LINE_COLOR_BEAT,
        LINE_COLOR_WHITE,
        BEAT_PULSE_DURATION
    )

func _on_track_1_beat(_current_beat: int) -> void:
    _pulse_line(_waveform_mat_1)

func _on_track_2_beat(_current_beat: int) -> void:
    _pulse_line(_waveform_mat_2)


## Updates waveform playhead and cue/loop marker shader values each frame.
func _process(_delta: float) -> void:
    var a1: float = LibreBox.Get_Track_Playback_Alpha(0)
    var a2: float = LibreBox.Get_Track_Playback_Alpha(1)
    _waveform_mat_1.set_shader_parameter("alpha", a1)
    _waveform_mat_2.set_shader_parameter("alpha", a2)

    _update_loop_markers(0, _waveform_mat_1)
    _update_loop_markers(1, _waveform_mat_2)
    _update_hot_cue_markers(0, _waveform_mat_1)
    _update_hot_cue_markers(1, _waveform_mat_2)
    _update_regular_cue_marker(0, _waveform_mat_1)
    _update_regular_cue_marker(1, _waveform_mat_2)


func _update_loop_markers(which_track: int, mat: ShaderMaterial) -> void:
    if mat == null:
        return
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var player: AudioStreamPlayer = DJ_Controller.Get_Track_Playback_Player(which_track)
    if player == null or player.stream == null:
        mat.set_shader_parameter("loop_start_visible", 0.0)
        mat.set_shader_parameter("loop_end_visible", 0.0)
        return

    var len_sec: float = float(player.stream.get_length())
    if len_sec <= 0.001:
        mat.set_shader_parameter("loop_start_visible", 0.0)
        mat.set_shader_parameter("loop_end_visible", 0.0)
        return

    var start_visible: bool = DJ_Controller.Is_Loop_Start_Armed(which_track) or DJ_Controller.Is_Loop_Enabled(which_track)
    var end_visible: bool = DJ_Controller.Is_Loop_End_Armed(which_track) or DJ_Controller.Is_Loop_Enabled(which_track)

    if start_visible:
        var start_alpha: float = clampf(DJ_Controller.Get_Loop_Start_Sec(which_track) / len_sec, 0.0, 1.0)
        mat.set_shader_parameter("loop_start_alpha", start_alpha)
        mat.set_shader_parameter("loop_start_visible", 1.0)
    else:
        mat.set_shader_parameter("loop_start_visible", 0.0)

    if end_visible:
        var end_alpha: float = clampf(DJ_Controller.Get_Loop_End_Sec(which_track) / len_sec, 0.0, 1.0)
        mat.set_shader_parameter("loop_end_alpha", end_alpha)
        mat.set_shader_parameter("loop_end_visible", 1.0)
    else:
        mat.set_shader_parameter("loop_end_visible", 0.0)


func _update_hot_cue_markers(which_track: int, mat: ShaderMaterial) -> void:
    if mat == null:
        return

    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var player: AudioStreamPlayer = DJ_Controller.Get_Track_Playback_Player(which_track)
    if player == null or player.stream == null:
        for cue_idx: int in range(1, DJ_Controller.PERFORMANCE_PAD_COUNT + 1):
            mat.set_shader_parameter("hot_cue_%d_visible" % cue_idx, 0.0)
        return

    var stream_len_sec: float = float(player.stream.get_length())
    if stream_len_sec <= 0.001:
        for cue_idx: int in range(1, DJ_Controller.PERFORMANCE_PAD_COUNT + 1):
            mat.set_shader_parameter("hot_cue_%d_visible" % cue_idx, 0.0)
        return

    for cue_index: int in range(DJ_Controller.PERFORMANCE_PAD_COUNT):
        var cue_sec: float = DJ_Controller.Get_Hot_Cue_Sec(which_track, cue_index)
        var cue_shader_idx: int = cue_index + 1
        if cue_sec < 0.0:
            mat.set_shader_parameter("hot_cue_%d_visible" % cue_shader_idx, 0.0)
            continue

        var cue_alpha: float = clampf(cue_sec / stream_len_sec, 0.0, 1.0)
        mat.set_shader_parameter("hot_cue_%d_alpha" % cue_shader_idx, cue_alpha)
        mat.set_shader_parameter("hot_cue_%d_visible" % cue_shader_idx, 1.0)


func _update_regular_cue_marker(which_track: int, mat: ShaderMaterial) -> void:
    if mat == null:
        return

    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    var player: AudioStreamPlayer = DJ_Controller.Get_Track_Playback_Player(which_track)
    if player == null or player.stream == null:
        mat.set_shader_parameter("cue_visible", 0.0)
        return

    if not DJ_Controller.Has_Regular_Cue(which_track):
        mat.set_shader_parameter("cue_visible", 0.0)
        return

    var stream_len_sec: float = float(player.stream.get_length())
    if stream_len_sec <= 0.001:
        mat.set_shader_parameter("cue_visible", 0.0)
        return

    var cue_sec: float = DJ_Controller.Get_Regular_Cue_Sec(which_track)
    var cue_alpha: float = clampf(cue_sec / stream_len_sec, 0.0, 1.0)
    mat.set_shader_parameter("cue_alpha", cue_alpha)
    mat.set_shader_parameter("cue_visible", 1.0)
