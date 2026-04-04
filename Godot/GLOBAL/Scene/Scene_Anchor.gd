extends StaticBody3D

## Scene understanding anchor wrapper.
## Attaches generated collision/mesh from OpenXR spatial entities.
@onready var label: Label3D = $Label3D

## Builds runtime geometry for a detected spatial entity.
func setup_scene(entity: OpenXRFbSpatialEntity) -> void:
    var semantic_labels: PackedStringArray = entity.get_semantic_labels()

    var collision_shape = entity.create_collision_shape()
    if collision_shape:
        add_child(collision_shape)

    var mesh_instance = entity.create_mesh_instance()
    if mesh_instance:
        add_child(mesh_instance)
