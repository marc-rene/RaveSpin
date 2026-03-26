extends PanelContainer





func _ready() -> void:
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.pressed.connect(_on_track_fx_toggled)
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.pressed.connect(_on_track_fx_toggled)
    # Sync toggle buttons with current policy
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.button_pressed = BUS_MANAGER.Can_Track_1_Take_FX()
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.button_pressed = BUS_MANAGER.Can_Track_2_Take_FX()
    _update_track_fx_policy()
    _refresh_all_fx_buttons()
    
    
    for child in $"MarginContainer/VBoxContainer/FX Containers/VBoxContainer_L".get_children():
        if child is FX_Button_Select and BUS_MANAGER.ONE_FX_AT_A_TIME:
            child.pressed.connect(_refresh_all_fx_buttons)
    
    for child in $"MarginContainer/VBoxContainer/FX Containers/VBoxContainer_R".get_children():
        if child is FX_Button_Select and BUS_MANAGER.ONE_FX_AT_A_TIME:
            child.pressed.connect(_refresh_all_fx_buttons)
            






func _on_track_fx_toggled() -> void:
    _update_track_fx_policy()
    _refresh_all_fx_buttons()


func _update_track_fx_policy() -> void:
    var can_track_1 : bool = $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.button_pressed
    var can_track_2 : bool = $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.button_pressed
    BUS_MANAGER.Set_Track_1_can_take_FX(can_track_1)
    BUS_MANAGER.Set_Track_2_can_take_FX(can_track_2)


func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        _refresh_all_fx_buttons()
        

func _refresh_all_fx_buttons() -> void:
    for child in $"MarginContainer/VBoxContainer/FX Containers/VBoxContainer_L".get_children():
        if child is FX_Button_Select:
            child.refresh_state()
        
    for child in $"MarginContainer/VBoxContainer/FX Containers/VBoxContainer_R".get_children():
        if child is FX_Button_Select:
            child.refresh_state()
