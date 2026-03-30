extends PanelContainer
class_name DB_Meter

@export var Track_ID: int = 0

@export var Min_DB: float = -48.0
@export var Max_DB: float = 6.0
@export var Warning_DB: float = 0.1
@export var Title : String = "KEY_DB_LABEL"

@onready var Meter_Fill_ref: ColorRect = $"MarginContainer/VBoxContainer/Meter Fill"
@onready var DB_Label_ref: Label = $"MarginContainer/VBoxContainer/DB Label"
@onready var Title_Label_ref: Label = $MarginContainer/VBoxContainer/Label

var bus_index: int = -1
var meter_mat: ShaderMaterial


func _ready() -> void:
    # TODO: Make this an enum so it's less jank
    if Track_ID == 11:
        bus_index = AudioServer.get_bus_index("Microphone Input")
    else:
        Track_ID = Utility.Clamp_to_Valid_TrackID(Track_ID)
        bus_index = BUS_MANAGER.Get_Channel_Index_i(Track_ID)
        
    meter_mat = Meter_Fill_ref.material.duplicate()
    Meter_Fill_ref.material = meter_mat
    
    Title_Label_ref.text = tr(Title) # Title is a KEY_* from scene (e.g. KEY_DB_METER_1)
    
    var warning_alpha : float = remap(Warning_DB, Min_DB, Max_DB, 0.0, 1.0)
    meter_mat.set_shader_parameter("warning_alpha", warning_alpha)

    update_metre(Min_DB)



var peak_db_l: float
var peak_db_r: float
func _process(_delta: float) -> void:
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
