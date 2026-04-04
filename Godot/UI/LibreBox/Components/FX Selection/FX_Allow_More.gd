extends CheckButton

## Toggle for allowing multiple Beat FX at once.
## Writes directly to `BUS_MANAGER` FX stacking policy.

## Flips FX stacking policy and syncs button state.
func on_click():
    BUS_MANAGER.Toggle_Allow_Multiple_FX_at_same_time()
    button_pressed = BUS_MANAGER.Allow_Multiple_FX_at_same_time()

## Initialises button state from current BUS_MANAGER policy.
func _ready():
    button_pressed = BUS_MANAGER.Allow_Multiple_FX_at_same_time()
    pressed.connect(on_click)
    
