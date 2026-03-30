extends "res://Scripts/Highlight_Mesh.gd"
class_name Slider_Control

enum E_Slider_Mode
{
    NORMAL = 2,
    KNOB_POPUP = 5
}

var update_label_val:bool = false

var active = false
var hand_ref : Area3D
var starting_pos : Vector3
@export var Value : float# = 0.5
@export var snap_to_middle_tolerance = 0.05
@export var slider_mode: E_Slider_Mode = E_Slider_Mode.KNOB_POPUP
@export var popup_rail_radius_meters: float = 0.005
@export var popup_handle_radius_meters: float = 0.01
@export var popup_handle_height_meters: float = 0.01
@export var popup_transparent_material: Material = preload("res://Art/Materials/M_Hand_Transy.tres")

@onready var min_point_node : Node3D = $"Highlight/Min point"
@onready var max_point_node : Node3D = $"Highlight/Max point"
@onready var activation_node: Node3D = $Highlight/Activation
@onready var activation_collision_shape: CollisionShape3D = $"Highlight/Activation/CollisionShape3D"

# we want it to auto-hide after the user lets go
@export var auto_hide : bool = false
signal request_close
var _time_since_interaction : float = 0.0
var _popup_visual_root: Node3D = null
var _popup_rail_mesh_instance: MeshInstance3D = null
var _popup_handle_mesh_instance: MeshInstance3D = null
@export var popup_drag_start_deadzone_meters: float = 0.012
var _popup_entry_anchor_local_z: float = 0.0
var _popup_has_entry_anchor: bool = false
var _popup_drag_is_armed: bool = false

func _ready() -> void:
    super._ready()
    enable_press_feedback_tween = false
    _setup_popup_visual_nodes()
    _apply_slider_mode_visual_state()


func UpdateAlpha(new_value: float):
    #print("Alpha: %.3f" % new_value)
    var max_pos = max_point_node.position.z
    var min_pos = min_point_node.position.z
    $Highlight/Activation.position.z = remap(new_value, 0, 1, min_pos, max_pos)
    _refresh_popup_visual_geometry()
    #reset_highlight()
    
    
func Set_MinMax_offset(new_offset : float = 0.02):
    min_point_node.position.z = new_offset * -1.0
    max_point_node.position.z = new_offset
    _refresh_popup_visual_geometry()


func Set_Slider_Mode(new_mode: E_Slider_Mode) -> void:
    slider_mode = new_mode
    _apply_slider_mode_visual_state()


func Reset_Runtime_State() -> void:
    active = false
    hand_ref = null
    fully_exited = true
    _popup_has_entry_anchor = false
    _popup_drag_is_armed = false
    HighLight(E_ActivationStates.Exited)
    
    
func _on_activation_area_entered(area: Area3D) -> void:
    if not Utility.is_all_ready():
        return
    if not (area is Player_Finger):
        return

    var source_finger: Player_Finger = area as Player_Finger
    if not _can_activate_from_area(source_finger):
        HighLight(E_ActivationStates.InvalidPose)
        return

    source_finger.notify_entered_slider()
    if slider_mode == E_Slider_Mode.KNOB_POPUP:
        var local_finger_position: Vector3 = to_local(source_finger.global_position)
        _popup_entry_anchor_local_z = local_finger_position.z
        _popup_has_entry_anchor = true
        _popup_drag_is_armed = false
    else:
        update_label_val = true
        
    active = true
    hand_ref = source_finger
    if Target_Mesh != null:
        starting_pos = Target_Mesh.position
    HighLight(E_ActivationStates.Pressed)
    if fully_exited:
        HighLight(E_ActivationStates.Exited)
    elif active == false:
        HighLight(E_ActivationStates.Hoovered)
    else:
        pass
    

func _on_activation_area_exited(area: Area3D) -> void:
    if not (area is Player_Finger):
        return
    var source_finger: Player_Finger = area as Player_Finger
    source_finger.notify_exited_slider()
    if hand_ref != source_finger:
        return
    # We only want to stop tracking the hand here.
    # Let the base highlight logic decide whether we are
    # still hovered or fully exited.
    active = false
    hand_ref = null
    if fully_exited:
        HighLight(E_ActivationStates.Exited)
    else:
        HighLight(E_ActivationStates.Hoovered)
    
    if absf(0.5 - Value) < snap_to_middle_tolerance: #and slider_mode == E_Slider_Mode.NORMAL and Knob_Control.current_slider_L != self and Knob_Control.current_slider_R != self:
        #Value = 0.5
        #UpdateAlpha(Value)
        pass


var label_tween:Tween
func _process(delta: float) -> void:
    var max_pos = $"Highlight/Max point".position.z
    var min_pos = $"Highlight/Min point".position.z
    
    var hand_pos : Vector3
    if (hand_ref == null):
        hand_pos = Vector3.ZERO
    else:
        hand_pos = hand_ref.global_position

    if ($Highlight/Activation.position.z < min_pos):
        $Highlight/Activation.position.z = min_pos
        
    elif ($Highlight/Activation.position.z > max_pos):
        $Highlight/Activation.position.z = max_pos
        
    if (active and hand_ref != null and hand_pos != Vector3.ZERO):
        var local_hand_position: Vector3 = to_local(hand_pos)
        var should_apply_drag_position: bool = true
        if slider_mode == E_Slider_Mode.KNOB_POPUP:
            if _popup_has_entry_anchor and not _popup_drag_is_armed:
                var popup_movement_from_entry_meters: float = absf(local_hand_position.z - _popup_entry_anchor_local_z)
                if popup_movement_from_entry_meters >= popup_drag_start_deadzone_meters:
                    _popup_drag_is_armed = true
                else:
                    should_apply_drag_position = false
        if should_apply_drag_position:
            activation_node.position = local_hand_position
            activation_node.position.x = 0
            activation_node.position.y = -0.025
            # Clamp immediately so a hand leaving quickly (e.g. out the side) never
            # overwrites our position with a mid-track z — that was causing snap to 0.5.
            activation_node.position.z = clampf(activation_node.position.z, min_pos, max_pos)
        
    # THIS WILL STILL FAIL SOMEHOW
    #elif absf(0.5 - Value) < snap_to_middle_tolerance and slider_mode == E_Slider_Mode.NORMAL and Knob_Control.current_slider_L != self and Knob_Control.current_slider_R != self:
        #Value = 0.5
        #UpdateAlpha(Value)
    if not active or hand_ref == null:
        label_tween = create_tween()
        label_tween.set_ease(Tween.EASE_OUT)
        label_tween.set_trans(Tween.TRANS_BACK)
        label_tween.tween_property($Highlight/Activation/Label3D, "scale", Vector3(0.0001, 0.0001, 0.0001), 1.2)
    else:
        label_tween = create_tween()
        label_tween.set_ease(Tween.EASE_OUT)
        label_tween.set_trans(Tween.TRANS_BACK)
        label_tween.tween_property($Highlight/Activation/Label3D, "scale", Vector3(1,1,1), 0.8)
        #$Highlight/Activation/Label3D.visible = true
        
    if slider_mode == E_Slider_Mode.NORMAL and Target_Mesh != null:
        Target_Mesh.global_position = activation_node.global_position
        if update_label_val:
            $Highlight/Activation/Label3D.text = "%.2f" % Value
        
           
    _refresh_popup_visual_geometry()
    
    var should_sample_activation_value: bool = active or slider_mode == E_Slider_Mode.NORMAL
    if should_sample_activation_value:
        var alpha = remap(activation_node.position.z, min_pos, max_pos, 0, 1)
        Value = clampf(alpha, 0, 1)
    else:
        # Keep popup slider at remembered value while idle/open.
        UpdateAlpha(Value)
        #print("Moving Slider, min_pos: ", min_pos * 0.9, " max_pos: ", max_pos * 0.9, " Alpha = ", alpha)
        #$Highlight/Activation.global_position = Target_Mesh.global_position

    # auto-hide once the user lets go 
    if auto_hide:
        if active or not fully_exited:
            _time_since_interaction = 0.0
        else:
            _time_since_interaction += delta
            if _time_since_interaction > 0.5:
                request_close.emit()


func _setup_popup_visual_nodes() -> void:
    if _popup_visual_root != null and is_instance_valid(_popup_visual_root):
        return
    _popup_visual_root = Node3D.new()
    _popup_visual_root.name = "PopupVisuals"
    add_child(_popup_visual_root)

    _popup_rail_mesh_instance = MeshInstance3D.new()
    _popup_rail_mesh_instance.name = "PopupRail"
    _popup_visual_root.add_child(_popup_rail_mesh_instance)

    _popup_handle_mesh_instance = MeshInstance3D.new()
    _popup_handle_mesh_instance.name = "PopupHandle"
    _popup_visual_root.add_child(_popup_handle_mesh_instance)

    _rebuild_popup_meshes()
    _refresh_popup_visual_geometry()


func _rebuild_popup_meshes() -> void:
    if _popup_rail_mesh_instance == null or _popup_handle_mesh_instance == null:
        return
    if not max_point_node or not min_point_node:
        max_point_node = $"Highlight/Max point"
        min_point_node = $"Highlight/Min point"
    var rail_mesh: CylinderMesh = CylinderMesh.new()
    rail_mesh.top_radius = popup_rail_radius_meters
    rail_mesh.bottom_radius = popup_rail_radius_meters
    rail_mesh.height = maxf(0.0005, absf(max_point_node.position.z - min_point_node.position.z))
    _popup_rail_mesh_instance.mesh = rail_mesh

    var handle_mesh: CylinderMesh = CylinderMesh.new()
    handle_mesh.top_radius = popup_handle_radius_meters
    handle_mesh.bottom_radius = popup_handle_radius_meters
    handle_mesh.height = popup_handle_height_meters
    _popup_handle_mesh_instance.mesh = handle_mesh

    _popup_rail_mesh_instance.material_override = popup_transparent_material
    _popup_handle_mesh_instance.material_override = popup_transparent_material


func _apply_slider_mode_visual_state() -> void:
    _setup_popup_visual_nodes()
    if _popup_visual_root == null:
        return

    if slider_mode == E_Slider_Mode.KNOB_POPUP:
        _popup_visual_root.visible = true
        if activation_collision_shape != null and activation_collision_shape.shape is BoxShape3D:
            var activation_shape: BoxShape3D = activation_collision_shape.shape as BoxShape3D
            activation_shape.size = Vector3(0.02, 0.03, activation_shape.size.z)
    else:
        _popup_visual_root.visible = false
    _rebuild_popup_meshes()
    _refresh_popup_visual_geometry()


func _refresh_popup_visual_geometry() -> void:
    if _popup_visual_root == null or _popup_rail_mesh_instance == null or _popup_handle_mesh_instance == null:
        return
    if slider_mode != E_Slider_Mode.KNOB_POPUP:
        return

    var min_local: Vector3 = min_point_node.position
    var max_local: Vector3 = max_point_node.position
    var center_local: Vector3 = (min_local + max_local) * 0.5
    var rail_basis: Basis = Basis().rotated(Vector3.RIGHT, PI * 0.5)
    _popup_rail_mesh_instance.transform = Transform3D(rail_basis, center_local)

    var rail_mesh: CylinderMesh = _popup_rail_mesh_instance.mesh as CylinderMesh
    if rail_mesh != null:
        rail_mesh.height = maxf(0.0005, absf(max_local.z - min_local.z))
        
    if not _popup_handle_mesh_instance:
        _rebuild_popup_meshes()
    if not activation_node:
        activation_node = $Highlight/Activation
    if not activation_node:
        push_error("I have no idea why but Activation Node for this Knob just wont be set!?")
    else:
        _popup_handle_mesh_instance.global_transform = activation_node.global_transform

func _on_NEW_Highlight_Entered(area: Area3D):
    if (Utility.is_all_ready()):
        HighLight(E_ActivationStates.Hoovered)
        fully_exited = false

func _on_NEW_Highlight_Exited(area: Area3D):
    HighLight(E_ActivationStates.Exited)
    fully_exited = true
