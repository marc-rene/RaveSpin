extends CheckButton


func on_click():
    BUS_MANAGER.Toggle_Allow_Multiple_FX_at_same_time()
    button_pressed = BUS_MANAGER.Allow_Multiple_FX_at_same_time()

func _ready():
    button_pressed = BUS_MANAGER.Allow_Multiple_FX_at_same_time()
    pressed.connect(on_click)
    
