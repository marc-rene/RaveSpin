extends CheckButton
class_name FX_Button_Select

@export var FX_Type : BUS_MANAGER.E_BEAT_FX_TYPE

const Inactive_Colour_Mod : Color = Color8(100, 100, 140)
const Active_Colour_Mod : Color = Color8(255, 255, 255)

func _ready() -> void:
    pressed.connect(_on_pressed)
    refresh_state()


func _on_pressed() -> void:

    if _any_track_can_take_fx():
        if BUS_MANAGER.Can_Track_1_Take_FX() and not BUS_MANAGER.is_beat_fx_active(FX_Type, 0):
            BUS_MANAGER.add_beat_fx(FX_Type, 0)
        elif not BUS_MANAGER.Can_Track_1_Take_FX() and BUS_MANAGER.is_beat_fx_active(FX_Type, 0):
            BUS_MANAGER.remove_beat_fx(FX_Type, 0)
            
        if BUS_MANAGER.Can_Track_2_Take_FX() and not BUS_MANAGER.is_beat_fx_active(FX_Type, 1):
            BUS_MANAGER.add_beat_fx(FX_Type, 1)
        elif not BUS_MANAGER.Can_Track_2_Take_FX() and BUS_MANAGER.is_beat_fx_active(FX_Type, 1):
            BUS_MANAGER.remove_beat_fx(FX_Type, 1)
    else:
        BUS_MANAGER.remove_beat_fx(FX_Type, 0)
        BUS_MANAGER.remove_beat_fx(FX_Type, 1)
            
    refresh_state()


func refresh_state() -> void:
    #print("FX type: " + str(FX_Type) + " is active on 1?: " + str(BUS_MANAGER.is_beat_fx_active(FX_Type, 0)) + " and 2?" + str(BUS_MANAGER.is_beat_fx_active(FX_Type, 1)) )
    # TODO: refactor this into a sep function because this is silly
    if _any_track_can_take_fx() and _is_fx_active_on_any_track():
        button_pressed = true
        if BUS_MANAGER.Can_Track_1_Take_FX() and not BUS_MANAGER.is_beat_fx_active(FX_Type, 0):
            BUS_MANAGER.add_beat_fx(FX_Type, 0)
        elif not BUS_MANAGER.Can_Track_1_Take_FX() and BUS_MANAGER.is_beat_fx_active(FX_Type, 0):
            BUS_MANAGER.remove_beat_fx(FX_Type, 0)
            
        if BUS_MANAGER.Can_Track_2_Take_FX() and not BUS_MANAGER.is_beat_fx_active(FX_Type, 1):
            BUS_MANAGER.add_beat_fx(FX_Type, 1)
        elif not BUS_MANAGER.Can_Track_2_Take_FX() and BUS_MANAGER.is_beat_fx_active(FX_Type, 1):
            BUS_MANAGER.remove_beat_fx(FX_Type, 1)
    else:
        button_pressed = false
    
    
    self_modulate = Active_Colour_Mod if _any_track_can_take_fx() else Inactive_Colour_Mod
    
    if not _any_track_can_take_fx():
        BUS_MANAGER.remove_beat_fx(FX_Type, 0)
        BUS_MANAGER.remove_beat_fx(FX_Type, 1)
        #button_pressed = false
        


func _any_track_can_take_fx() -> bool:
    return BUS_MANAGER.Can_Track_1_Take_FX() or BUS_MANAGER.Can_Track_2_Take_FX()


func _is_fx_active_on_any_track() -> bool:
    if BUS_MANAGER.is_beat_fx_active(FX_Type, 0):
        return true
    if BUS_MANAGER.is_beat_fx_active(FX_Type, 1):
        return true
    return false
