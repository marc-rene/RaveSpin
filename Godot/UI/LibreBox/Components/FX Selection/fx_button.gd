extends Button
class_name FX_Button_Select

## FX type this button applies (set by FX_Selection_Menu).
## Which track(s) it affects is determined by BUS_MANAGER.CURRENT_TRACK_FX_POLICY.
var fx_type: BUS_MANAGER.E_BEAT_FX_TYPE = BUS_MANAGER.E_BEAT_FX_TYPE.DELAY


func _ready() -> void:
    toggle_mode = true
    pressed.connect(_on_pressed)
    refresh_state()


func _on_pressed() -> void:
    if not _any_track_can_take_fx():
        return
    # Toggle this FX on every channel allowed by CURRENT_TRACK_FX_POLICY
    if _is_fx_active_on_any_allowed_track():
        if BUS_MANAGER.Can_Track_1_Take_FX():
            BUS_MANAGER.remove_beat_fx(fx_type, 0)
        if BUS_MANAGER.Can_Track_2_Take_FX():
            BUS_MANAGER.remove_beat_fx(fx_type, 1)
    else:
        if BUS_MANAGER.Can_Track_1_Take_FX():
            BUS_MANAGER.add_beat_fx(fx_type, 0)
        if BUS_MANAGER.Can_Track_2_Take_FX():
            BUS_MANAGER.add_beat_fx(fx_type, 1)
    refresh_state()


func refresh_state() -> void:
    button_pressed = _is_fx_active_on_any_allowed_track()
    disabled = not _any_track_can_take_fx()


func _any_track_can_take_fx() -> bool:
    return BUS_MANAGER.Can_Track_1_Take_FX() or BUS_MANAGER.Can_Track_2_Take_FX()


func _is_fx_active_on_any_allowed_track() -> bool:
    if BUS_MANAGER.Can_Track_1_Take_FX() and BUS_MANAGER.is_beat_fx_active(fx_type, 0):
        return true
    if BUS_MANAGER.Can_Track_2_Take_FX() and BUS_MANAGER.is_beat_fx_active(fx_type, 1):
        return true
    return false
