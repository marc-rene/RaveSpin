extends "res://Scripts/Highlight_Mesh.gd"
class_name Knob_Control

# 0..1 normalised knob value
@export var Value: float = 0.0
var active = false
# Local-space min and max rotations for the knob
@export var min_quat: Quaternion = Quaternion()
@export var max_quat: Quaternion = Quaternion()

@onready var hand_ref: Area3D 
@onready var activation: Node3D   = $Highlight/Activation
@onready var slider_global_spawn_node : Node3D = $"Slider Spawn Point"
@onready var slider_global_spawn_node_col_box : BoxShape3D = $"Slider Spawn Point/CollisionShape3D".shape


# Shared popup slider support
const SLIDER_SCENE : Resource = preload("res://GLOBAL/CTRL_Slider.tscn")
static var current_slider: Slider_Control = null
static var current_knob : Knob_Control = null


func _ready() -> void:
    # If you didn’t set these in the editor, default them to the current rotation
    if min_quat == Quaternion():
        min_quat = activation.quaternion.normalized()
    else:
        min_quat = min_quat.normalized()

    if max_quat == Quaternion():
        max_quat = activation.quaternion.normalized()
    else:
        max_quat = max_quat.normalized()


func _on_activation_area_entered(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        active = true
        hand_ref = area
        HighLight(E_ActivationStates.Pressed)
        _show_popup_slider()
    


func _on_activation_area_exited(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        print("Slider Deactivated")
        active = false
        
        if(fully_exited):
            HighLight(E_ActivationStates.Exited)
        else:
            HighLight(E_ActivationStates.Hoovered)


func _process(_delta: float) -> void:
    # If a popup slider is currently controlling this knob,
    # drive our value from the slider instead of hand rotation.
    if current_knob == self and current_slider != null:
        
        Value = clampf(current_slider.Value, 0.0, 1.0)
        $"Slider Spawn Point/Label3D".text = str("%.2f" % Value)
        # knob rot between min and max
        var knob_quat: Quaternion = min_quat.slerp(max_quat, Value).normalized()
        
        activation.quaternion = knob_quat
        
        if Target_Mesh:
            Target_Mesh.global_transform.basis = activation.global_transform.basis
        return

    if not active:
        return

    # hand rotation to knob local space
    var parent_basis: Basis = activation.get_parent().global_transform.basis
    if (hand_ref == null):
        return
    var hand_basis: Basis = hand_ref.global_transform.basis

    var hand_local_basis : Basis = parent_basis.inverse() * hand_basis
    var hand_local_quat : Quaternion = hand_local_basis.get_rotation_quaternion().normalized()

    # whats the alpha between min and max quat??
    var t: float = alpha_from_quat(hand_local_quat, min_quat, max_quat)
    t = clamp(t, 0.0, 1.0)
    Value = t
    
    # do NOT go beyopnd min max
    var knob_quat2: Quaternion = min_quat.slerp(max_quat, t).normalized()
    activation.quaternion = knob_quat2

    if Target_Mesh:
        Target_Mesh.global_transform.basis = activation.global_transform.basis


func alpha_from_quat(q: Quaternion, q_min: Quaternion, q_max: Quaternion) -> float:
    # Relative rotations from min
    var total: Quaternion   = (q_min.inverse() * q_max).normalized()
    var current: Quaternion = (q_min.inverse() * q).normalized()

    # For unit quaternions, angle = 2 * acos(w)
    var total_angle: float = 2.0 * acos(clamp(total.w, -1.0, 1.0))
    if abs(total_angle) < 0.0001:
        return 0.0  # avoid division by zero if min == max

    var current_angle: float = 2.0 * acos(clamp(current.w, -1.0, 1.0))
    var t: float = current_angle / total_angle

    return clamp(t, 0.0, 1.0)


func _show_popup_slider() -> void:
    # THERE CAN BE ONLY ONE!
    if current_slider == null or not is_instance_valid(current_slider):
        current_slider = SLIDER_SCENE.instantiate()
        # Put the slider under the root so no local -> global tomfoolery
        current_slider.Target_Mesh = Target_Mesh
        get_tree().current_scene.add_child(current_slider)
        current_slider.request_close.connect(_on_popup_slider_request_close)
    
    current_knob = self

    # Position the slider just above the knob in world space.
    #slider_transform.origin = global_transform.origin + (to_global($"Slider Spawn Point".position) - global_transform.origin)
    
    #current_slider.global_transform = slider_transform
    
    current_slider.global_transform = slider_global_spawn_node.global_transform
    current_slider.Set_MinMax_offset(slider_global_spawn_node_col_box.size.y)
    
    #current_slider.scale.z = 1.1 # A smidge buigger
    #current_slider.rotation.y = PI

    # Sync the slider’s start value with this knob.
    current_slider.UpdateAlpha(Value)


func _on_popup_slider_request_close() -> void:
    if current_knob != self:
        return
    if current_slider != null and is_instance_valid(current_slider):
        current_slider.queue_free()
    current_slider = null
    current_knob = null
