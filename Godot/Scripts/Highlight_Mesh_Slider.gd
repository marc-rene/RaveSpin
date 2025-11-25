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
    var max_pos = $"Highlight/Max point".position.z
    var min_pos = $"Highlight/Min point".position.z
    
    var hand_pos = $"../../Player/XR_RightHand".position
    if (active == false):
        var format_string = "Rhand pos: X: %f, Y: %f, Z: %f"
        var actual_string = format_string % [hand_pos.x, hand_pos.y, hand_pos.z]

        
    if (active):
        
        if ($Highlight/Activation.position.z <= min_pos):
            $Highlight/Activation.position.z = min_pos * 0.9
         
        elif ($Highlight/Activation.position.z >= max_pos):
            $Highlight/Activation.position.z = max_pos * 0.9
        else:
            $Highlight/Activation.position = to_local($"../../Player/XR_RightHand".position)
            $Highlight/Activation.position.y = 0.1
            $Highlight/Activation.position.x = 0
            
            Target_Mesh.global_position = $Highlight/Activation.global_position
            var alpha = ($Highlight/Activation.position.z ) + 0.5
            print("Moving Slider, min_pos: ", min_pos * 0.9, " max_pos: ", max_pos * 0.9, " Alpha = ", alpha)
        #$Highlight/Activation.global_position = Target_Mesh.global_position
