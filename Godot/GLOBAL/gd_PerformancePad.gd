extends Base_Control
class_name Performance_Pad_Control

signal on_pad_pressed
signal on_pad_released

@export var AudioStreamSample: AudioStream
# 0 for Track 0 (left), 1 for Track 1 (right)
@export_range(0, 1, 1) var which_track_we_targetting: int = 0

## 0 == Pad A, 1 == Pad B ... 7 == Pad H
@export_range(0, 7, 1) var PAD_INDEX: int = 0

@onready var sampler_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var label_3d: Label3D = $Label3D

const MODE_HOT_CUE: int = 0
const MODE_SAMPLER: int = 1
const MODE_FX_SET_1: int = 2
const MODE_FX_SET_2: int = 3
const MODE_BEAT_JUMP: int = 4
const MODE_KEY_SHIFT: int = 5

func _ready() -> void:
    super._ready()
    if sampler_player != null and AudioStreamSample != null:
        sampler_player.stream = AudioStreamSample


func _on_BASE_activation_area_entered(area: Area3D) -> void:
    super._on_BASE_activation_area_entered(area)
    if Utility.is_all_ready() and _can_activate_from_area(area):
        on_pad_pressed.emit()


func _on_BASE_activation_area_exited(area: Area3D) -> void:
    super._on_BASE_activation_area_exited(area)
    if Utility.is_all_ready():
        on_pad_released.emit()
        sampler_player.bus = BUS_MANAGER.BUS_NAMES[BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_ONE_INPUT] if which_track_we_targetting == 0 else BUS_MANAGER.BUS_NAMES[BUS_MANAGER.E_AUDIO_BUSSES.CHANNEL_TWO_INPUT]
        


func set_pad_label(new_text: String) -> void:
    if label_3d != null:
        label_3d.text = new_text


func get_sampler_player() -> AudioStreamPlayer:
    if not sampler_player:
        sampler_player = $AudioStreamPlayer
    if sampler_player:
        if sampler_player.stream == null and AudioStreamSample != null:
            sampler_player.stream = AudioStreamSample
    return sampler_player


func refresh_runtime_label(
    active_mode: int,
    hot_cue_add_mode: bool,
    beat_jump_beats: float,
    key_shift_semitones: int,
    fx_type: int = -1,
    fx_variant_index: int = 0
) -> void:
    var new_label: String = ""
    match active_mode:
        MODE_HOT_CUE:
            var cue_letter: String = char(65 + clampi(PAD_INDEX, 0, 7))
            new_label = ("Cue " if hot_cue_add_mode else "Del ") + cue_letter
        MODE_SAMPLER:
            new_label = "Samp %d" % (PAD_INDEX + 1)
        MODE_FX_SET_1, MODE_FX_SET_2:
            new_label = _fx_label(fx_type, fx_variant_index)
        MODE_BEAT_JUMP:
            new_label = str("%+.0f" % beat_jump_beats) + "Bt"
        MODE_KEY_SHIFT:
            new_label = str("%+d" % key_shift_semitones) + "st"
        _:
            new_label = ""
    set_pad_label(new_label)


func _fx_label(fx_type: int, fx_variant_index: int) -> String:
    var base: String = _short_fx_label(fx_type)
    if fx_variant_index <= 0:
        return base
    var tags: Array[String] = ["Lite", "Med", "Hard", "Xtra"]
    var tag: String = tags[min(fx_variant_index - 1, tags.size() - 1)]
    return tag + "\n" + base


func _short_fx_label(fx_type: int) -> String:
    match fx_type:
        BUS_MANAGER.E_BEAT_FX_TYPE.DELAY: return "Delay"
        BUS_MANAGER.E_BEAT_FX_TYPE.ECHO: return "Echo"
        BUS_MANAGER.E_BEAT_FX_TYPE.REVERB: return "Reverb"
        BUS_MANAGER.E_BEAT_FX_TYPE.TRANS: return "Trans"
        BUS_MANAGER.E_BEAT_FX_TYPE.FLANGER: return "Flangr"
        BUS_MANAGER.E_BEAT_FX_TYPE.PHASER: return "Phaser"
        BUS_MANAGER.E_BEAT_FX_TYPE.PITCH: return "Pitch"
        BUS_MANAGER.E_BEAT_FX_TYPE.CRUSH: return "Crush"
        BUS_MANAGER.E_BEAT_FX_TYPE.COMPRESSOR: return "Comp"
        BUS_MANAGER.E_BEAT_FX_TYPE.LIMITER: return "Limit"
        BUS_MANAGER.E_BEAT_FX_TYPE.BAND_PASS: return "BandPs"
        BUS_MANAGER.E_BEAT_FX_TYPE.PANNER: return "Panner"
        BUS_MANAGER.E_BEAT_FX_TYPE.STEREO_ENHANCE: return "Stereo"
        BUS_MANAGER.E_BEAT_FX_TYPE.DISTORTION: return "Distort"
        _:
            return "FX"
