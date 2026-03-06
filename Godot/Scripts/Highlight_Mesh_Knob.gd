extends "res://Scripts/Highlight_Mesh.gd"
class_name Knob_Control

# 0..1 normalised knob value
@export var Value: float = 0.0
var active = false
# Local-space min and max rotations for the knob
@export var min_quat: Quaternion = Quaternion()
@export var max_quat: Quaternion = Quaternion()

@onready var hand_ref: Area3D 
@onready var activation_area: Node3D   = $Highlight/Activation
@onready var slider_global_spawn_node : Node3D = $"Slider Spawn Point"
@onready var slider_global_spawn_node_col_box : BoxShape3D = $"Slider Spawn Point/CollisionShape3D".shape


func UpdateAlpha(new_alpha : float):
    Value = new_alpha

# Shared popup slider support
const SLIDER_SCENE : Resource = preload("res://GLOBAL/CTRL_Slider.tscn")
static var current_slider_L: Slider_Control = null
static var current_slider_R: Slider_Control = null
static var current_knob_L : Knob_Control = null
static var current_knob_R : Knob_Control = null


func _ready() -> void:
    # If you didn’t set these in the editor, default them to the current rotation
    if min_quat == Quaternion():
        min_quat = activation_area.quaternion.normalized()
    else:
        min_quat = min_quat.normalized()

    if max_quat == Quaternion():
        max_quat = activation_area.quaternion.normalized()
    else:
        max_quat = max_quat.normalized()


func _on_activation_area_entered(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        if area is Player_Finger:
            var target_finger : Player_Finger = area as Player_Finger
            active = true
            hand_ref = area
            HighLight(E_ActivationStates.Pressed)
            _show_popup_slider(target_finger.is_right_hand)
    


func _on_activation_area_exited(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        #print("Slider Deactivated")
        if area is Player_Finger:
            #print("SUCCESS THIS WORKS")
            active = false
            if(fully_exited):
                HighLight(E_ActivationStates.Exited)
            else:
                HighLight(E_ActivationStates.Hoovered)
            #if area.get_script().is_right_hand:
                


func _process(_delta: float) -> void:
    # If a popup slider is currently controlling this knob,
    # drive our value from the slider instead of hand rotation.
    if current_knob_L == self and current_slider_L != null:
        Value = clampf(current_slider_L.Value, 0.0, 1.0)
        $"Slider Spawn Point/Label3D".text = str("%.2f" % Value)
        # knob rot between min and max
        var knob_quat: Quaternion = min_quat.slerp(max_quat, Value).normalized()
        
        activation_area.quaternion = knob_quat
        
        if Target_Mesh:
            Target_Mesh.global_transform.basis = activation_area.global_transform.basis
        return

    elif current_knob_R == self and current_slider_R != null:
        Value = clampf(current_slider_R.Value, 0.0, 1.0)
        $"Slider Spawn Point/Label3D".text = str("%.2f" % Value)
        # knob rot between min and max
        var knob_quat: Quaternion = min_quat.slerp(max_quat, Value).normalized()
        
        activation_area.quaternion = knob_quat
        
        if Target_Mesh:
            Target_Mesh.global_transform.basis = activation_area.global_transform.basis
        return
    else:
        $"Slider Spawn Point/Label3D".text = ""
        
    if not active:
        return

    # hand rotation to knob local space
    var parent_basis: Basis = activation_area.get_parent().global_transform.basis
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
    activation_area.quaternion = knob_quat2

    if Target_Mesh:
        Target_Mesh.global_transform.basis = activation_area.global_transform.basis


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


func _show_popup_slider(use_right_slider : bool) -> void:
    # THERE CAN BE ONLY ONE!
    if use_right_slider and (current_slider_R == null or not is_instance_valid(current_slider_R)):
        current_slider_R = SLIDER_SCENE.instantiate()
        # Put the slider under the root so no local -> global tomfoolery
        current_slider_R.Target_Mesh = Target_Mesh
        get_tree().current_scene.add_child(current_slider_R)
        current_slider_R.request_close.connect(_on_popup_slider_request_close)

    elif (use_right_slider == false) and (current_slider_L == null or not is_instance_valid(current_slider_L)):
        current_slider_L = SLIDER_SCENE.instantiate()
        # Put the slider under the root so no local -> global tomfoolery
        current_slider_L.Target_Mesh = Target_Mesh
        get_tree().current_scene.add_child(current_slider_L)
        current_slider_L.request_close.connect(_on_popup_slider_request_close)
    
    if use_right_slider:
        current_knob_R = self
        current_slider_R.global_transform = slider_global_spawn_node.global_transform
        current_slider_R.UpdateAlpha(Value)
    else:
        current_knob_L = self
        current_slider_L.global_transform = slider_global_spawn_node.global_transform
        current_slider_L.UpdateAlpha(Value)
   



func _on_popup_slider_request_close(use_right_slider : bool) -> void:
    if use_right_slider and current_knob_R != self:
        return
    elif (use_right_slider == false) and current_knob_L != self:
        return
        
    if use_right_slider and current_slider_R != null and is_instance_valid(current_slider_R):
        current_slider_R.queue_free()
    elif (use_right_slider == false) and current_slider_L != null and is_instance_valid(current_slider_L):
        current_slider_L.queue_free()
    
    if use_right_slider:
        current_slider_R = null
        current_knob_R = null
    else:
        current_slider_L = null
        current_knob_L = null
