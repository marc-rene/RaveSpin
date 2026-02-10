extends Control
class_name LibreBox_HUB

@export var Track_1 : Song

@export var Track_2 : Song

func Refresh():
    $"VBoxContainer/Track 1 Container/Track 1 Card".Refresh_Details()
    $"VBoxContainer/Track 2 Container/Track 2 Card".Refresh_Details()
    
func _ready():
    $"VBoxContainer/Track 1 Container/Track 1 Card".Song_Resource = Track_1
    $"VBoxContainer/Track 2 Container/Track 2 Card".Song_Resource = Track_2
    Refresh()
