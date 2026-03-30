extends PanelContainer

@export_range(0,1,1) var Which_track_are_we_targetting : int

@onready var _jump_hot_cue_btn: Button = $"MarginContainer/GridContainer/VBoxContainer/Jump to Hot Cue Mode"
@onready var _hot_cue_mode_btn: CheckButton = $"MarginContainer/GridContainer/VBoxContainer/Hot Cue Mode BTN"

@onready var _jump_fx_set_1_btn: Button = $"MarginContainer/GridContainer/VBoxContainer2/Jump to FX-Set 1"
@onready var _jump_fx_set_2_btn: Button = $"MarginContainer/GridContainer/VBoxContainer2/Jump to FX-Set 2"

@onready var _jump_beat_jump_btn: Button = $"MarginContainer/GridContainer/VBoxContainer3/Jump to Beat Jump Mode"
#@onready var _beat_jump_toggle_btn: CheckButton = $"MarginContainer/GridContainer/VBoxContainer3/Beat Jump Mode Toggle BTN"

@onready var _jump_sampler_btn: Button = $"MarginContainer/GridContainer/VBoxContainer4/Jump to Sampler Mode"
@onready var _key_shift_mode_btn: CheckButton = $"MarginContainer/GridContainer/VBoxContainer4/Key Shift Mode"

var _ticks: int = 0
var _syncing_ui: bool = false


func _ready() -> void:
    Which_track_are_we_targetting = _guess_track_from_viewport_owner(Which_track_are_we_targetting)
    if DJ_Controller.Get_Instance() == null:
        await DJ_Controller.Get_Instance_await()

    _jump_hot_cue_btn.toggled.connect(_on_jump_hot_cue_toggled)
    _hot_cue_mode_btn.toggled.connect(_on_hot_cue_mode_toggled)
    _jump_fx_set_1_btn.toggled.connect(_on_jump_fx_set_1_toggled)
    _jump_fx_set_2_btn.toggled.connect(_on_jump_fx_set_2_toggled)
    _jump_beat_jump_btn.toggled.connect(_on_beat_jump_toggle_toggled)
    
    _jump_sampler_btn.toggled.connect(_on_jump_sampler_toggled)
    _key_shift_mode_btn.toggled.connect(_on_key_shift_mode_toggled)

    _apply_localized_text()
    _sync_ui_from_controller()


func _process(_delta: float) -> void:
    _ticks += 1
    if _ticks % 5 == 0:
        _sync_ui_from_controller()


func _guess_track_from_viewport_owner(fallback_track: int) -> int:
    var fallback: int = Utility.Clamp_to_Valid_TrackID(fallback_track)
    var vp: Viewport = get_viewport()
    if vp == null:
        return fallback
    var owner_3d: Node = vp.get_parent()
    if owner_3d == null:
        return fallback
    var nm: String = String(owner_3d.name).to_lower()
    # Names here are typically "Performance Pad Manager Left/Right",
    # so starts_with("left"/"right") is not reliable.
    if nm.contains("left"):
        return 0
    if nm.contains("right"):
        return 1
    return fallback


func _apply_localized_text() -> void:
    _jump_hot_cue_btn.text = tr("KEY_ACTIVATE_HOT_CUE_MODE")
    _jump_fx_set_1_btn.text = tr("KEY_USE_FX_SET_1")
    _jump_fx_set_2_btn.text = tr("KEY_USE_FX_SET_2")
    _jump_beat_jump_btn.text = tr("KEY_ACTIVATE_BEAT_JUMP_MODE")
    #_beat_jump_toggle_btn.text = tr("KEY_BEAT_JUMP_MODE")
    _jump_sampler_btn.text = tr("KEY_ACTIVATE_SAMPLER_MODE")
    _key_shift_mode_btn.text = tr("KEY_KEY_SHIFT_MODE")
    _refresh_hot_cue_toggle_label()


func _refresh_hot_cue_toggle_label() -> void:
    var add_mode: bool = DJ_Controller.Get_Hot_Cue_Add_Mode(Which_track_are_we_targetting)
    _hot_cue_mode_btn.text = tr("KEY_PAD_ADD_CUE_POINT") if add_mode else tr("KEY_PAD_DELETE_CUE_POINT")


func _sync_ui_from_controller() -> void:
    _syncing_ui = true
    var mode: int = DJ_Controller.Get_Performance_Pad_Mode(Which_track_are_we_targetting)
    var add_mode: bool = DJ_Controller.Get_Hot_Cue_Add_Mode(Which_track_are_we_targetting)

    _jump_hot_cue_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.HOT_CUE)
    _hot_cue_mode_btn.visible = (mode == DJ_Controller.E_Performance_Pad_Mode.HOT_CUE)
    
    _jump_fx_set_1_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.FX_SET_1)
    _jump_fx_set_2_btn.visible = (mode in [DJ_Controller.E_Performance_Pad_Mode.FX_SET_1, DJ_Controller.E_Performance_Pad_Mode.FX_SET_2])
    _jump_fx_set_2_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.FX_SET_2)
    
    _jump_beat_jump_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.BEAT_JUMP)
    
    _jump_sampler_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.SAMPLER)
    _key_shift_mode_btn.button_pressed = (mode == DJ_Controller.E_Performance_Pad_Mode.KEY_SHIFT)

    _hot_cue_mode_btn.button_pressed = add_mode

    _hot_cue_mode_btn.disabled = mode != DJ_Controller.E_Performance_Pad_Mode.HOT_CUE
    

    _refresh_hot_cue_toggle_label()
    _syncing_ui = false


func _on_jump_hot_cue_toggled(enabled: bool) -> void:
    if _syncing_ui or not enabled:
        return
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, DJ_Controller.E_Performance_Pad_Mode.HOT_CUE)
    _sync_ui_from_controller()


func _on_hot_cue_mode_toggled(enabled: bool) -> void:
    if _syncing_ui:
        return
    DJ_Controller.Set_Hot_Cue_Add_Mode(Which_track_are_we_targetting, enabled)
    _refresh_hot_cue_toggle_label()


func _on_jump_fx_set_1_toggled(enabled: bool) -> void:
    if _syncing_ui or not enabled:
        return
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, DJ_Controller.E_Performance_Pad_Mode.FX_SET_1)
    _sync_ui_from_controller()


func _on_jump_fx_set_2_toggled(enabled: bool) -> void:
    if _syncing_ui or not enabled:
        return
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, DJ_Controller.E_Performance_Pad_Mode.FX_SET_2)
    _sync_ui_from_controller()




func _on_beat_jump_toggle_toggled(enabled: bool) -> void:
    if _syncing_ui or not enabled:
        return
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, DJ_Controller.E_Performance_Pad_Mode.BEAT_JUMP)
    _sync_ui_from_controller()


func _on_jump_sampler_toggled(enabled: bool) -> void:
    if _syncing_ui or not enabled:
        return
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, DJ_Controller.E_Performance_Pad_Mode.SAMPLER)
    _sync_ui_from_controller()


func _on_key_shift_mode_toggled(enabled: bool) -> void:
    if _syncing_ui:
        return
    var new_mode: int = DJ_Controller.E_Performance_Pad_Mode.KEY_SHIFT if enabled else DJ_Controller.E_Performance_Pad_Mode.HOT_CUE
    DJ_Controller.Set_Performance_Pad_Mode(Which_track_are_we_targetting, new_mode)
    _sync_ui_from_controller()


func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        if Utility.all_is_ready:
            _apply_localized_text()
