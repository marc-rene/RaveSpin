extends Node3D

@export var Target_Mesh : MeshInstance3D
@export var Replace_Mesh : MeshInstance3D

signal on_hovered
signal on_unhovered
signal on_activated

var fully_exited = true
@onready var highlight_mat : StandardMaterial3D
@onready var activated_mat : StandardMaterial3D

enum E_ActivationStates {
    Exited,
    Hoovered,
    Pressed
}

func Load_Mats():
    highlight_mat = load("res://Art/Materials/M_Item_Hovered.tres")
    activated_mat = load("res://Art/Materials/M_Item_Activated.tres")
    

func _on_ready():
    Load_Mats()
    
    if (Replace_Mesh != null):
        Replace_Mesh = Target_Mesh
    
    
    
func HighLight(p_state = E_ActivationStates.Hoovered):
    if (highlight_mat == null or activated_mat == null):
        Load_Mats()
    match p_state:
        E_ActivationStates.Exited:
            Target_Mesh.material_overlay = null
            on_unhovered.emit()
        E_ActivationStates.Hoovered:
            Target_Mesh.material_overlay = highlight_mat
            on_hovered.emit()
        E_ActivationStates.Pressed:
            Target_Mesh.material_overlay = activated_mat
            on_activated.emit()
            


func _on_BASE_highlight_area_entered(area: Area3D) -> void:
    HighLight(E_ActivationStates.Hoovered)
    fully_exited = false
    


func _on_BASE_highlight_area_exited(area: Area3D) -> void:
    HighLight(E_ActivationStates.Exited)
    fully_exited = true
    



func _on_BASE_activation_area_entered(area: Area3D) -> void:
    HighLight(E_ActivationStates.Pressed)
    


func _on_BASE_activation_area_exited(area: Area3D) -> void:
    if (fully_exited):
        HighLight(E_ActivationStates.Exited)
    else:
        HighLight(E_ActivationStates.Hoovered)
