extends Node3D
class_name Base_Control

# TODO: refactor and fix this awful crap mess
# highlight.gd is doing hightlight AND activation?????

@export var Target_Mesh : MeshInstance3D
@export var Replace_Mesh : MeshInstance3D

signal on_hovered
signal on_unhovered
signal on_activated
signal on_flashing_start
signal on_flashing_end

var fully_exited : bool = true
const highlight_mat : StandardMaterial3D = preload("res://Art/Materials/M_Item_Hovered.tres") 
const activated_mat : StandardMaterial3D = preload("res://Art/Materials/M_Item_Activated.tres")
var flashing : bool = false

enum E_ActivationStates {
    Exited,
    Hoovered,
    Pressed,
    Flashing
}
    
    
#func Start_Flashing():
    #flashing = true
#
#
#func Stop_Flashing():
    #flashing = false
    


func _on_ready():  
    if (Replace_Mesh != null):
        Replace_Mesh = Target_Mesh
    
    
func reset_highlight():
    HighLight(E_ActivationStates.Exited)
    return true
    
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
                on_activated.emit()
            


func _on_BASE_highlight_area_entered(area: Area3D) -> void:
    if (Utility.all_is_ready):
        HighLight(E_ActivationStates.Hoovered)
        fully_exited = false
    


func _on_BASE_highlight_area_exited(area: Area3D) -> void:
    HighLight(E_ActivationStates.Exited)
    fully_exited = true
    



func _on_BASE_activation_area_entered(area: Area3D) -> void:
    if (LibreBox.LibreBox_instance != null):
        HighLight(E_ActivationStates.Pressed)
    


func _on_BASE_activation_area_exited(area: Area3D) -> void:
    if (fully_exited):
        HighLight(E_ActivationStates.Exited)
    else:
        if (LibreBox.LibreBox_instance != null):
            HighLight(E_ActivationStates.Hoovered)
