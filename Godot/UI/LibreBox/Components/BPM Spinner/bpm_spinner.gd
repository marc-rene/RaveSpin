#@tool
extends AspectRatioContainer
class_name BPM_Spinner

## Visual BPM spinner used by active track cards
## Shows current BPM plus percentage offset from base BPM
@onready var Spinner : Control = $"Base BPM Tip/BPM Guage bit"

const ZERO_ROT : float = 45.0

@onready var Current_BPM_var_label : Label = $"Base BPM Tip/VBoxContainer/Current BPM var label"
@onready var Offset_percent_var_label : Label = $"Base BPM Tip/VBoxContainer/Offset percent var label"

const Negative_Offset_Colour : Color = Color("e94f37ff")
const Neutral_Offset_Colour : Color = Color(0.422, 0.458, 0.48, 1.0)
const Positive_Offset_Colour : Color = Color(0.267, 0.733, 0.643, 1.0)
@export var Alpha : float = 0.0
var base_bpm : float = 0.0
var current_bpm : float = 0.0

@onready var guage_bit_mat : ShaderMaterial
const M_SIMPLE_EMISSIVE : ShaderMaterial = preload("res://Art/Materials/UI/Emissive/Simple_Emmisive.tres")

var Offset_Text : String

## Initialises spinner material instance
func _ready():
    guage_bit_mat = M_SIMPLE_EMISSIVE.duplicate()
    Spinner.material = guage_bit_mat


## Refreshes spinner angle and BPM/offset labels
func _process(delta: float) -> void:
    rotate_spinny(Alpha)
    
    if base_bpm > 1 and current_bpm > 1.0:
        Offset_Text = "+" if current_bpm > base_bpm else "-"
        if absf(current_bpm - base_bpm) < 0.5:
            Offset_percent_var_label.label_settings.font_color = Neutral_Offset_Colour
        else:
            Offset_percent_var_label.label_settings.font_color = Positive_Offset_Colour if current_bpm > base_bpm else Negative_Offset_Colour
        Offset_Text += "%.2f" % float(absf( 1 - (current_bpm / base_bpm) ) * 100.0) # returns just "%.2f" if we dont recast to float... why??
        Offset_Text += "%"
        Offset_percent_var_label.text = Offset_Text
        Current_BPM_var_label.text = "%.2f" % current_bpm
    else:
        Offset_percent_var_label.text = "..."
        Current_BPM_var_label.text = "NaN"


## Rotates spinner around one full cycle using alpha (0...1)
func rotate_spinny(new_alpha: float):
    Spinner.rotation_degrees = remap(new_alpha, 0, 1, ZERO_ROT, (360.0 + ZERO_ROT))
    Alpha = fmod(Alpha, 1.0)

## Called when a beat has just occurred (alpha reached 1 and wrapped to 0)... Use for visual feedback (e.g. pulse)
func On_Beat() -> void:
    guage_bit_mat.set_shader_parameter("Force_Foreground_Colour", LibreBox_HUB.LINE_COLOR_BEAT)
    var tween : Tween = create_tween()
    tween.tween_method(
        func(c: Color) -> void: guage_bit_mat.set_shader_parameter("Force_Foreground_Colour", c),
        LibreBox_HUB.LINE_COLOR_BEAT,
        LibreBox_HUB.LINE_COLOR_WHITE,
        LibreBox_HUB.BEAT_PULSE_DURATION
    )



## Sets metadata/base BPM reference for offset 
func Set_Base_BPM(New_Base_BPM : float):
    base_bpm = New_Base_BPM

## Sets currently effective deck BPM
func Refresh_BPM(New_Current_BPM : float):
    current_bpm = New_Current_BPM
