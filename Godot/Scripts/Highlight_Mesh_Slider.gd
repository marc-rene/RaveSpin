extends "res://Scripts/Highlight_Mesh.gd"

var active = false
var hand_ref : Area3D
var starting_pos : Vector3
@export var Value = 0.5


func _on_activation_area_entered(area: Area3D) -> void:
    if (area.name == "Hand"):
        print("Slider Activated")
        active = true
        hand_ref = area
        starting_pos = Target_Mesh.position
        
    HighLight(E_ActivationStates.Pressed)
    

func _on_activation_area_exited(area: Area3D) -> void:
    active = false
    #hand_ref = null
    if (fully_exited):
        HighLight(E_ActivationStates.Exited)
    else:
        HighLight(E_ActivationStates.Hoovered)

func _process(delta: float) -> void:
    var hand_pos = $"../../../Player/XR_RightHand".position
    if (active == false):
        var format_string = "Rhand pos: X: %f, Y: %f, Z: %f"
        var actual_string = format_string % [hand_pos.x, hand_pos.y, hand_pos.z]

        
    if (active):
        print("Moving Slider")
        Target_Mesh.position.z = hand_pos.x

        
    
