extends Control
class_name LibreBox_HUB

@export var Track_1 : Song

@export var Track_2 : Song



func Refresh(Set_Track_1 : bool):
    if Set_Track_1:
        $"VBoxContainer/Track 1 Container/Track 1 Card".Set_New_Song(Track_1)
    else:
        $"VBoxContainer/Track 2 Container/Track 2 Card".Set_New_Song(Track_2)
    
func _ready():
    $"VBoxContainer/Track 1 Container/Track 1 Card".Song_Resource = Track_1
    $"VBoxContainer/Track 2 Container/Track 2 Card".Song_Resource = Track_2
    Refresh(true)
    Refresh(false)
