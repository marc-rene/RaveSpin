extends "res://Scripts/Highlight_Mesh.gd"
class_name Slider_Control

var active = false
var hand_ref : Area3D
var starting_pos : Vector3
@export var Value = 0.5

@onready var min_point_node : Node3D = $"Highlight/Min point"
@onready var max_point_node : Node3D = $"Highlight/Max point"

# we want it to auto-hide after the user lets go
@export var auto_hide : bool = false
signal request_close
var _time_since_interaction : float = 0.0

func UpdateAlpha(new_value: float):
    print("Alpha: %.3f" % new_value)
    var max_pos = max_point_node.position.z
    var min_pos = min_point_node.position.z
    $Highlight/Activation.position.z = remap(new_value, 0, 1, min_pos, max_pos)
    #reset_highlight()
    
    
func Set_MinMax_offset(new_offset : float = 0.02):
    min_point_node.position.z = new_offset * -1.0
    max_point_node.position.z = new_offset
    
    
func _on_activation_area_entered(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        active = true
        hand_ref = area
        starting_pos = Target_Mesh.position
        HighLight(E_ActivationStates.Pressed)
        if fully_exited:
            HighLight(E_ActivationStates.Exited)
        elif active == false:
            HighLight(E_ActivationStates.Hoovered)
        else:
            pass
    

func _on_activation_area_exited(area: Area3D) -> void:
    # We only want to stop tracking the hand here.
    # Let the base highlight logic decide whether we are
    # still hovered or fully exited.
    active = false
    hand_ref = null
    if fully_exited:
        HighLight(E_ActivationStates.Exited)
    else:
        HighLight(E_ActivationStates.Hoovered)

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
        $Highlight/Activation.position = to_local(hand_pos)
        $Highlight/Activation.position.x = 0
        $Highlight/Activation.position.y = -0.025
        # Clamp immediately so a hand leaving quickly (e.g. out the side) never
        # overwrites our position with a mid-track z — that was causing snap to 0.5.
        $Highlight/Activation.position.z = clampf($Highlight/Activation.position.z, min_pos, max_pos)
    Target_Mesh.global_position = $Highlight/Activation.global_position
    var alpha = remap($Highlight/Activation.position.z, min_pos, max_pos, 0, 1)
    #print("New_ALPHA is ", alpha)
    Value = clampf(alpha, 0, 1)
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

func _on_NEW_Highlight_Entered(area: Area3D):
    if (Utility.is_all_ready()):
        HighLight(E_ActivationStates.Hoovered)
        fully_exited = false

func _on_NEW_Highlight_Exited(area: Area3D):
    HighLight(E_ActivationStates.Exited)
    fully_exited = true
