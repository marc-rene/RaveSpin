extends PanelContainer
class_name DB_Meter

@export var Track_ID: BUS_MANAGER.E_AUDIO_BUSSES
@export var Use_Microphone_Input: bool = false
@export var Microphone_NA_Threshold: float = 0.1

@export var Min_DB: float = -48.0
@export var Max_DB: float = 6.0
@export var Warning_DB: float = 0.1
@export var Title : String = "KEY_DB_LABEL"

@onready var Meter_Fill_ref: ColorRect = $"MarginContainer/VBoxContainer/Meter Fill"
@onready var DB_Label_ref: Label = $"MarginContainer/VBoxContainer/DB Label"
@onready var Title_Label_ref: Label = $MarginContainer/VBoxContainer/Label

var bus_index: int = -1
var meter_mat: ShaderMaterial
var _target_bus_name: StringName = &""
var _recording_node: Node = null


func _ready() -> void:
    _target_bus_name = StringName("Microphone Input") if Use_Microphone_Input else BUS_MANAGER.BUS_NAMES.get(Track_ID, StringName(""))
    _refresh_bus_index()

    meter_mat = Meter_Fill_ref.material.duplicate()
    Meter_Fill_ref.material = meter_mat
    
    Title_Label_ref.text = tr(Title) # Title is a KEY_* from scene (e.g. KEY_DB_METER_1)
    
    var warning_alpha : float = remap(Warning_DB, Min_DB, Max_DB, 0.0, 1.0)
    meter_mat.set_shader_parameter("warning_alpha", warning_alpha)

    update_metre(Min_DB)



var peak_db_l: float
var peak_db_r: float
func _process(_delta: float) -> void:
    if Use_Microphone_Input:
        if _is_mic_level_too_low():
            _show_na()
            return

        var mic_db: float = _get_mic_monitor_db()
        if is_inf(mic_db) or mic_db <= Min_DB:
            _show_na()
            return

        update_metre(mic_db)
        return

    _refresh_bus_index()
    if bus_index < 0:
        return

    peak_db_l = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
    peak_db_r = AudioServer.get_bus_peak_volume_right_db(bus_index, 0)

    # TODO: update the shader so it can do 2 halves... left and right
    update_metre(maxf(peak_db_l, peak_db_r))
   



func update_metre(peak_db: float) -> void:
    
    if peak_db == null or is_inf(peak_db) or peak_db <= Min_DB:
        peak_db = Min_DB
        DB_Label_ref.text = "-INF dB"

    peak_db = clampf(peak_db, Min_DB, Max_DB)

    meter_mat.set_shader_parameter("alpha", remap(peak_db, Min_DB, Max_DB, 0.0, 1.0))

    if peak_db > Min_DB:
        DB_Label_ref.text = "%.1f dB" % peak_db


func _is_mic_level_too_low() -> bool:
    var controller: DJ_Controller = DJ_Controller.Get_Instance()
    if controller == null:
        return false

    var mic_knob_node: Node = controller.get_node_or_null("Controls/Mic Level")
    if mic_knob_node == null:
        return false

    var knob_value_variant: Variant = mic_knob_node.get("Value")
    if knob_value_variant == null:
        return false

    return float(knob_value_variant) <= Microphone_NA_Threshold


func _show_na() -> void:
    DB_Label_ref.text = "N/A"
    meter_mat.set_shader_parameter("alpha", 0.0)


func _refresh_bus_index() -> void:
    if _target_bus_name == StringName(""):
        bus_index = -1
        return

    var resolved_index: int = AudioServer.get_bus_index(_target_bus_name)
    if resolved_index != bus_index:
        bus_index = resolved_index


func _get_mic_monitor_db() -> float:
    if _recording_node == null or not is_instance_valid(_recording_node):
        var recording_nodes: Array[Node] = get_tree().get_nodes_in_group("librebox_recording")
        _recording_node = recording_nodes[0] if not recording_nodes.is_empty() else null

    if _recording_node != null and _recording_node.has_method("get_mic_monitor_db"):
        return float(_recording_node.call("get_mic_monitor_db"))

    return Min_DB
