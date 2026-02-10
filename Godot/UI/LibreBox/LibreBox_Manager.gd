extends Node
class_name LibreBox

@export var Track_1 : Song
@export var Track_2 : Song
@onready var Track_3 : Song
@onready var Track_4 : Song


@onready var HUB_Menu_ref : LibreBox_HUB = $HUB.get_scene_instance()
@onready var Track_Selection_ref : LibreBox_TrackSelection = $"Track Selection".get_scene_instance()


func Refresh():
    HUB_Menu_ref.Refresh()
    
func _ready() -> void:
    HUB_Menu_ref.Track_1 = Track_1
    HUB_Menu_ref.Track_2 = Track_2
    Refresh()
