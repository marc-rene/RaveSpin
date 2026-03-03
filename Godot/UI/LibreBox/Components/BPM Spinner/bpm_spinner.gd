extends AspectRatioContainer

@onready var Spinner : Control = $"Base BPM Tip/BPM Guage bit"

const ZERO_ROT : float = 45.0

@export var Alpha : float = 0.0

var Offset_Text : String

func _process(delta: float) -> void:
    Spinner.rotation_degrees = remap(Alpha, 0, 1, 0, 359.99)
    if base_bpm > 1 and current_bpm > 1.0:
        Offset_Text = "+" if current_bpm > base_bpm else "-"
        Offset_Text += "%.2f %" % (absf( 1 - (current_bpm / base_bpm) ) * 100.0)
        $"Base BPM Tip/VBoxContainer/Offset percent var label".text = "Offset_Text"
    else:
        $"Base BPM Tip/VBoxContainer/Offset percent var label".text = "..."

var base_bpm : float = 0.0
var current_bpm : float = 0.0


func Set_Base_BPM(New_Base_BPM : float):
    base_bpm = New_Base_BPM

func Refresh_BPM(New_Current_BPM : float):
    current_bpm = New_Current_BPM
