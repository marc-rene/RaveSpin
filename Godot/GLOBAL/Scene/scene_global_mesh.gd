extends Node3D

const WIREFRAME_MATERIAL: Material = preload("res://Art/Materials/M_Hand_Transy.tres")

@onready var static_body: StaticBody3D = $StaticBody3D

var mesh_instance: MeshInstance3D


func setup_scene(entity: OpenXRFbSpatialEntity) -> void:
    var collision_shape = entity.create_collision_shape()
    if collision_shape:
        static_body.add_child(collision_shape)
