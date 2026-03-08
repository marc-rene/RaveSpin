extends Button
class_name FX_Button_Select

@export var Related_FX : AudioEffect
@onready var is_enabled : bool = not $".".disabled


## Set the FX on Channel 1 and/or 2 to enabled...
func _on_Select():
    
    # whatever FX is there in slot ,,,, replace it
    if BUS_MANAGER.ONE_FX_AT_A_TIME:
        pass
    
    # nevermind we can use Bus manager add FX
    else:
        pass
        

func _ready():
    pressed.connect(_on_Select)
