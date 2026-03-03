extends XRCamera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.



@export var distance_in_front = 0

@export var spawn_in_front:Node3D 

func recenter():
    # var y = spawn_in_front.global_position.y
    # print("Head pos" + str(global_position))
    var projected = global_basis.z
    projected.y = 0
    projected = projected.normalized()
    var in_front = global_position + (projected * distance_in_front)
    # in_front.y = y
    
    
    spawn_in_front.global_position = in_front
    # boid.global_position = in_front
    var y_rotation = global_basis.get_euler().y
    spawn_in_front.global_basis = Basis(Vector3.UP, y_rotation).scaled(spawn_in_front.scale)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
