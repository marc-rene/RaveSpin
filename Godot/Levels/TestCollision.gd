extends Area3D

    
func _ready() -> void:
    $"../MeshInstance3D2".set_scale(Vector3(0.01,0.01,0.01))
    

func _on_area_entered(area: Area3D) -> void:
    print("FUCK FUCK FUCK FUCK Times 10000")
    $"../MeshInstance3D2".set_scale(Vector3(.8,.8,.8))


    pass # Replace with function body.
