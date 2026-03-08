extends PanelContainer


func update_fx_policy():
    var can_do_track_1 = not $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.disabled
    var can_do_track_2 = not $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.disabled
    
    print("Setting Track 1:2 fx policy to " + str(can_do_track_1) + ":" + str(can_do_track_2))
    BUS_MANAGER.Set_Track_1_can_take_FX(can_do_track_1)
    BUS_MANAGER.Set_Track_2_can_take_FX(can_do_track_2)
    

func _ready():
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.pressed.connect(update_fx_policy)
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.pressed.connect(update_fx_policy)
    
