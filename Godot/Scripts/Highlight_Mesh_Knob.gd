extends "res://Scripts/Highlight_Mesh.gd"

# 0..1 normalised knob value
@export var Value: float = 0.0
var active = false
# Local-space min and max rotations for the knob
@export var min_quat: Quaternion = Quaternion()
@export var max_quat: Quaternion = Quaternion()

@onready var hand_ref: Area3D 
@onready var activation: Node3D   = $Highlight/Activation

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
    if area.name == "Hand":
        active = true
        HighLight(E_ActivationStates.Pressed)
    


func _on_activation_area_exited(area: Area3D) -> void:
    if (area.name == "Hand"):
        #print("Slider Activated")
        active = true
        hand_ref = area
    else:
        if(fully_exited):
            HighLight(E_ActivationStates.Exited)
        else:
            HighLight(E_ActivationStates.Hoovered)


func _process(_delta: float) -> void:
    if not active:
        return

    # 1) Hand rotation in the knob parent’s local space
    var parent_basis: Basis = activation.get_parent().global_transform.basis
    if (hand_ref == null):
        return
    var hand_basis: Basis   = hand_ref.global_transform.basis

    var hand_local_basis: Basis = parent_basis.inverse() * hand_basis
    var hand_local_quat: Quaternion = hand_local_basis.get_rotation_quaternion().normalized()

    # 2) Compute alpha (0..1) from min_quat → max_quat using quaternions
    var t: float = alpha_from_quat(hand_local_quat, min_quat, max_quat)
    t = clamp(t, 0.0, 1.0)
    Value = t

    # 3) Constrain knob rotation to the slerped value between min and max
    var knob_quat: Quaternion = min_quat.slerp(max_quat, t).normalized()
    activation.quaternion = knob_quat

    # 4) Keep the visual mesh in sync (if you’re using a separate mesh)
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

func _on_highlight_area_entered(area: Area3D) -> void:
    #HighLight(E_ActivationStates.Hoovered)
    fully_exited = false
    


func _on_highlight_area_exited(area: Area3D) -> void:
    #HighLight(E_ActivationStates.Exited)
    fully_exited = true
