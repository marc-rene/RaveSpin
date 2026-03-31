extends PanelContainer
class_name DB_Meter


@export var Use_Microphone_Input: bool = false
@export var Microphone_NA_Threshold: float = 0.1

@export var Min_DB: float = -48.0
@export var Max_DB: float = 6.0
@export var Warning_DB: float = 0.1
@export var Title : String = "KEY_DB_LABEL"

@onready var L_Meter_Fill_ref: ColorRect = $"MarginContainer/VBoxContainer/HBoxContainer/L Meter Fill"
@onready var R_Meter_Fill_ref: ColorRect = $"MarginContainer/VBoxContainer/HBoxContainer/R Meter Fill"
@onready var DB_Label_ref: Label = $"MarginContainer/VBoxContainer/DB Label"
@onready var Title_Label_ref: Label = $MarginContainer/VBoxContainer/Label

@export var bus_name: StringName
var L_meter_mat: ShaderMaterial
var R_meter_mat: ShaderMaterial
var _recording_node: Node = null


func _ready() -> void:
    

    L_meter_mat = L_Meter_Fill_ref.material.duplicate()
    R_meter_mat = R_Meter_Fill_ref.material.duplicate()
    
    L_Meter_Fill_ref.material = L_meter_mat
    R_Meter_Fill_ref.material = R_meter_mat
    
    Title_Label_ref.text = tr(Title) # Title is a KEY_* from scene (e.g. KEY_DB_METER_1)
    
    var warning_alpha : float = remap(Warning_DB, Min_DB, Max_DB, 0.0, 1.0)
    L_meter_mat.set_shader_parameter("warning_alpha", warning_alpha)
    R_meter_mat.set_shader_parameter("warning_alpha", warning_alpha)

    update_metre(Min_DB, Min_DB)
    


var peak_db_l: float
var peak_db_r: float
var bus_index : int
func _process(_delta: float) -> void:
    bus_index = AudioServer.get_bus_index(bus_name)
    
    if Use_Microphone_Input:
        if _is_mic_level_too_low():
            _show_na()
            return

        var mic_db: float = _get_mic_monitor_db()
        if is_inf(mic_db) or mic_db <= Min_DB:
            _show_na()
            return

        update_metre(mic_db, mic_db)
        return

    if bus_index < 0:
        return

    peak_db_l = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
    peak_db_r = AudioServer.get_bus_peak_volume_right_db(bus_index, 0)

    # TODO: update the shader so it can do 2 halves... left and right
    update_metre(peak_db_l, peak_db_r)
   



func update_metre(L_peak_db: float, R_peak_db: float) -> void:
    
    if L_peak_db == null or is_inf(L_peak_db) or L_peak_db <= Min_DB:
        L_peak_db = Min_DB
    if R_peak_db == null or is_inf(R_peak_db) or R_peak_db <= Min_DB:
        R_peak_db = Min_DB
    if L_peak_db == Min_DB and R_peak_db == Min_DB:
        DB_Label_ref.text = "-INF dB"

    L_peak_db = clampf(L_peak_db, Min_DB, Max_DB)
    R_peak_db = clampf(R_peak_db, Min_DB, Max_DB)

    L_meter_mat.set_shader_parameter("alpha", remap(L_peak_db, Min_DB, Max_DB, 0.0, 1.0))
    R_meter_mat.set_shader_parameter("alpha", remap(R_peak_db, Min_DB, Max_DB, 0.0, 1.0))

    if L_peak_db > Min_DB or R_peak_db > Min_DB:
        DB_Label_ref.text = "%.1f dB" % maxf(L_peak_db, R_peak_db)


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
    L_meter_mat.set_shader_parameter("alpha", 0.0)
    R_meter_mat.set_shader_parameter("alpha", 0.0)



func _get_mic_monitor_db() -> float:
    if _recording_node == null or not is_instance_valid(_recording_node):
        var recording_nodes: Array[Node] = get_tree().get_nodes_in_group("librebox_recording")
        _recording_node = recording_nodes[0] if not recording_nodes.is_empty() else null

    if _recording_node != null and _recording_node.has_method("get_mic_monitor_db"):
        return float(_recording_node.call("get_mic_monitor_db"))

    return Min_DB
