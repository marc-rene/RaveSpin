extends Control
class_name LibreBox_HUB

@export var Track_1 : Song
@export var Track_2 : Song


const WAVEFORM_WINDOW_WIDTH = 1650 # TODO figure out how to compute this runtime
const WAVEFORM_WINDOW_HEIGHT = 240 


# For our waveforms, how many pixels (x-axis) make up a single minute of playtime for a wav/mp3 file?
const PIXELS_PER_MINUTE = 1024 # THIS WAS DECIDED BY Assets/tools/generate_waveforms.py



@onready var Track_1_waveformVis : TextureRect = %"Track 1 Waveform preview"
@onready var Track_2_waveformVis : TextureRect = %"Track 2 Waveform preview"

const M_HORIZONTAL_PAN : ShaderMaterial = preload("res://Art/Materials/UI/M_Horizontal_Pan.tres")

const BEAT_PULSE_DURATION : float = 0.2
const LINE_COLOR_WHITE : Color = Color(1.0, 1.0, 1.0, 1.0)
const LINE_COLOR_BEAT : Color = Color(1.0, 0.2, 0.2, 1.0)

@onready var _waveform_mat_1: ShaderMaterial
@onready var _waveform_mat_2: ShaderMaterial

var _rhythm_1: RhythmNotifier
var _rhythm_2: RhythmNotifier



func Refresh(Set_Track_1 : bool) -> void:
    if Set_Track_1:
        $"VBoxContainer/Track 1 Container/Track 1 Card".Set_New_Song(Track_1)
        Track_1_waveformVis.texture = Track_1.Audio_File_Waveform
        if _rhythm_1 and Track_1:
            _rhythm_1.bpm = Track_1.Track_BPM
    else:
        $"VBoxContainer/Track 2 Container/Track 2 Card".Set_New_Song(Track_2)
        Track_2_waveformVis.texture = Track_2.Audio_File_Waveform
        if _rhythm_2 and Track_2:
            _rhythm_2.bpm = Track_2.Track_BPM
    
    
    
func _ready() -> void:
    _waveform_mat_1 = M_HORIZONTAL_PAN.duplicate()
    Track_1_waveformVis.material = _waveform_mat_1

    _waveform_mat_2 = M_HORIZONTAL_PAN.duplicate()
    Track_2_waveformVis.material = _waveform_mat_2

    $"VBoxContainer/Track 1 Container/Track 1 Card".Song_Resource = Track_1
    $"VBoxContainer/Track 2 Container/Track 2 Card".Song_Resource = Track_2
    Refresh(true)
    Refresh(false)

    _setup_rhythm_notifiers()

func _setup_rhythm_notifiers() -> void:
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


func _process(_delta: float) -> void:
    _waveform_mat_1.set_shader_parameter("alpha", LibreBox.Get_Track_Playback_Alpha(0))
    _waveform_mat_2.set_shader_parameter("alpha", LibreBox.Get_Track_Playback_Alpha(1))
