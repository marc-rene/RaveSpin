extends Node3D
class_name Base_Control

## Base class for physical deck controls.
## Handles hover/press visual state and pose-gated activation from Player_Finger areas.
# TODO: refactor and fix this awful crap mess
# highlight.gd is doing hightlight AND activation?????

@export var Target_Mesh : MeshInstance3D
@export var Replace_Mesh : MeshInstance3D
@export var press_tween_distance_meters: float = 0.003
@export var press_tween_duration_seconds: float = 0.06
@export var enable_press_feedback_tween: bool = true

# What's the name of this control? like "Left Track Play Button"
@export var Control_Display_Name : String

#what does this thing do?
@export var Control_Description : String

signal on_hovered
signal on_unhovered
signal on_activated
signal on_pressed
signal on_released
signal on_flashing_start
signal on_flashing_end

var fully_exited : bool = true
const highlight_mat : StandardMaterial3D = preload("res://Art/Materials/M_Item_Hovered.tres") 
const activated_mat : StandardMaterial3D = preload("res://Art/Materials/M_Item_Activated.tres")
var invalid_pose_mat: StandardMaterial3D = null
var flashing : bool = false
var _press_tween: Tween = null
var _target_mesh_rest_position: Vector3 = Vector3.ZERO
var _target_mesh_has_rest_position: bool = false

enum E_ActivationStates {
    Exited,
    Hoovered,
    Pressed,
    InvalidPose,
    Flashing
}
    
    
#func Start_Flashing():
    #flashing = true
#
#
#func Stop_Flashing():
    #flashing = false
    


func _ready() -> void:  
    if (Replace_Mesh != null):
        Replace_Mesh = Target_Mesh
    if Target_Mesh != null:
        _target_mesh_rest_position = Target_Mesh.position
        _target_mesh_has_rest_position = true
    invalid_pose_mat = StandardMaterial3D.new()
    invalid_pose_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    invalid_pose_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    invalid_pose_mat.albedo_color = Color(0.95, 0.20, 0.24, 0.75)
    
    
## Restores the control to the default visual state.
func reset_highlight():
    HighLight(E_ActivationStates.Exited)
    return true
    
## Applies visual state and emits matching interaction signals.
func HighLight(p_state = E_ActivationStates.Hoovered):
    if (Utility.all_is_ready):
        match p_state:
            E_ActivationStates.Exited:
                if Target_Mesh != null:
                    Target_Mesh.material_overlay = null
                on_unhovered.emit()
            E_ActivationStates.Hoovered:
                if Target_Mesh != null:
                    Target_Mesh.material_overlay = highlight_mat
                on_hovered.emit()
            E_ActivationStates.Pressed:
                if Target_Mesh != null:
                    Target_Mesh.material_overlay = activated_mat
                    if enable_press_feedback_tween:
                        _play_press_feedback_tween()
                on_activated.emit()
            E_ActivationStates.InvalidPose:
                if Target_Mesh != null:
                    Target_Mesh.material_overlay = invalid_pose_mat
            


func _on_BASE_highlight_area_entered(area: Area3D) -> void:
    if (Utility.all_is_ready):
        if _can_activate_from_area(area):
            HighLight(E_ActivationStates.Hoovered)
        else:
            HighLight(E_ActivationStates.InvalidPose)
        fully_exited = false
    


func _on_BASE_highlight_area_exited(area: Area3D) -> void:
    HighLight(E_ActivationStates.Exited)
    fully_exited = true
    



func _on_BASE_activation_area_entered(area: Area3D) -> void:
    if (LibreBox.LibreBox_instance != null):
        if _can_activate_from_area(area):
            on_pressed.emit()
            HighLight(E_ActivationStates.Pressed)
        else:
            HighLight(E_ActivationStates.InvalidPose)
    


func _on_BASE_activation_area_exited(area: Area3D) -> void:
    on_released.emit()
    if (fully_exited):
        HighLight(E_ActivationStates.Exited)
    else:
        if (LibreBox.LibreBox_instance != null):
            if _can_activate_from_area(area):
                HighLight(E_ActivationStates.Hoovered)
            else:
                HighLight(E_ActivationStates.InvalidPose)


## Validates if an overlapping area is allowed to activate this control.
func _can_activate_from_area(area: Area3D) -> bool:
    if area == null:
        return false
    if not (area is Player_Finger):
        return true

    var source_finger: Player_Finger = area as Player_Finger
    if source_finger.is_right_hand:
        return Player_Finger.CURRENT_RIGHT_HAND_POSE != Player_Finger.E_POSES.FIST
    return Player_Finger.CURRENT_LEFT_HAND_POSE != Player_Finger.E_POSES.FIST


func _play_press_feedback_tween() -> void:
    if Target_Mesh == null:
        return
    if not _target_mesh_has_rest_position:
        _target_mesh_rest_position = Target_Mesh.position
        _target_mesh_has_rest_position = true
    if _press_tween != null and _press_tween.is_valid():
        _press_tween.kill()
    Target_Mesh.position = _target_mesh_rest_position
    var press_offset_vector: Vector3 = -Target_Mesh.transform.basis.y.normalized() * press_tween_distance_meters
    var pressed_position: Vector3 = _target_mesh_rest_position + press_offset_vector
    _press_tween = create_tween()
    _press_tween.tween_property(Target_Mesh, "position", pressed_position, press_tween_duration_seconds)
    _press_tween.tween_property(Target_Mesh, "position", _target_mesh_rest_position, press_tween_duration_seconds)
