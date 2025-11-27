extends "res://Scripts/Highlight_Mesh.gd"

var active = false
var hand_ref : Area3D
var starting_pos : Vector3
@export var Value = 0.5


func _on_activation_area_entered(area: Area3D) -> void:
    if (area.name == "Hand"):
        #print("Slider Activated")
        active = true
        hand_ref = area
        starting_pos = Target_Mesh.position
        HighLight(E_ActivationStates.Pressed)
    else:
        if(fully_exited):
            HighLight(E_ActivationStates.Exited)
        else:
            HighLight(E_ActivationStates.Hoovered)
    

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
    
    var hand_pos:Vector3
    if (hand_ref == null):
        hand_pos = Vector3.ZERO
    else:
        hand_pos = hand_ref.global_position

    if ($Highlight/Activation.position.z < min_pos):
        $Highlight/Activation.position.z = min_pos
        
    elif ($Highlight/Activation.position.z > max_pos):
        $Highlight/Activation.position.z = max_pos
        
    if (active):
        $Highlight/Activation.position = to_local(hand_pos)
        $Highlight/Activation.position.x = 0
        $Highlight/Activation.position.y = -0.025
    else:
        HighLight(E_ActivationStates.Exited)
    Target_Mesh.global_position = $Highlight/Activation.global_position
    var alpha = remap($Highlight/Activation.position.z, min_pos, max_pos, 0, 1)
    print("New_ALPHA is ", alpha)
    Value = clampf(alpha, 0, 1)
        #print("Moving Slider, min_pos: ", min_pos * 0.9, " max_pos: ", max_pos * 0.9, " Alpha = ", alpha)
        #$Highlight/Activation.global_position = Target_Mesh.global_position
        
