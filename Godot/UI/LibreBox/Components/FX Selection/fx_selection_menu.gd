extends PanelContainer

const FX_CONTAINERS_PATH := "MarginContainer/VBoxContainer/FX Containers"
const TRACK_1_CONTAINER := "VBoxContainer_L"
const TRACK_2_CONTAINER := "VBoxContainer_R"

## Map button node names (as in scene) to BUS_MANAGER.E_BEAT_FX_TYPE.
static var _name_to_fx: Dictionary = {
    "Delay btn": BUS_MANAGER.E_BEAT_FX_TYPE.DELAY,
    "Echo btn": BUS_MANAGER.E_BEAT_FX_TYPE.ECHO,
    "Reverb btn": BUS_MANAGER.E_BEAT_FX_TYPE.REVERB,
    "Trans btn": BUS_MANAGER.E_BEAT_FX_TYPE.TRANS,
    "Flanger btn": BUS_MANAGER.E_BEAT_FX_TYPE.FLANGER,
    "Phaser btn": BUS_MANAGER.E_BEAT_FX_TYPE.PHASER,
    "Pitch btn": BUS_MANAGER.E_BEAT_FX_TYPE.PITCH,
    "Crush btn": BUS_MANAGER.E_BEAT_FX_TYPE.CRUSH,
    "Compressor btn": BUS_MANAGER.E_BEAT_FX_TYPE.COMPRESSOR,
    "Limiter btn": BUS_MANAGER.E_BEAT_FX_TYPE.LIMITER,
    "BandPass btn": BUS_MANAGER.E_BEAT_FX_TYPE.BAND_PASS,
    "Panner btn": BUS_MANAGER.E_BEAT_FX_TYPE.PANNER,
    "StereoEnhance btn": BUS_MANAGER.E_BEAT_FX_TYPE.STEREO_ENHANCE,
    "Distortion btn": BUS_MANAGER.E_BEAT_FX_TYPE.DISTORTION,
}


func _ready() -> void:
    _setup_fx_buttons()
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.pressed.connect(_on_track_fx_toggled)
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.pressed.connect(_on_track_fx_toggled)
    # Sync toggle buttons with current policy
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.button_pressed = BUS_MANAGER.Can_Track_1_Take_FX()
    $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.button_pressed = BUS_MANAGER.Can_Track_2_Take_FX()
    _update_track_fx_policy()
    _refresh_all_fx_buttons()


func _setup_fx_buttons() -> void:
    var root = get_node(FX_CONTAINERS_PATH)
    for child in root.get_node(TRACK_1_CONTAINER).get_children():
        _assign_fx_button(child)
    for child in root.get_node(TRACK_2_CONTAINER).get_children():
        _assign_fx_button(child)


func _assign_fx_button(node: Node) -> void:
    if not node is FX_Button_Select:
        return
    var btn: FX_Button_Select = node
    if btn.name in _name_to_fx:
        btn.fx_type = _name_to_fx[btn.name]


func _on_track_fx_toggled() -> void:
    _update_track_fx_policy()
    _refresh_all_fx_buttons()


func _update_track_fx_policy() -> void:
    var can_track_1 : bool = $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_1_fx_btn.button_pressed
    var can_track_2 : bool = $MarginContainer/VBoxContainer/HBoxContainer/Enable_Track_2_fx_btn.button_pressed
    BUS_MANAGER.Set_Track_1_can_take_FX(can_track_1)
    BUS_MANAGER.Set_Track_2_can_take_FX(can_track_2)


func _refresh_all_fx_buttons() -> void:
    var root = get_node(FX_CONTAINERS_PATH)
    for child in root.get_node(TRACK_1_CONTAINER).get_children():
        if child is FX_Button_Select:
            child.refresh_state()
    for child in root.get_node(TRACK_2_CONTAINER).get_children():
        if child is FX_Button_Select:
            child.refresh_state()
