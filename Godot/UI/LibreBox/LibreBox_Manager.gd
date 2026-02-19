extends Node
class_name LibreBox

@export var Track_1 : Song
@export var Track_2 : Song

@export var Track_3 : Song
@export var Track_4 : Song


@onready var HUB_Menu_ref : LibreBox_HUB = $HUB.get_scene_instance()
@onready var Track_1_Selection_ref : LibreBox_TrackSelection = $"Track 1 Selection".get_scene_instance()
@onready var Track_2_Selection_ref : LibreBox_TrackSelection = $"Track 2 Selection".get_scene_instance()

static var LibreBox_instance : LibreBox


func On_Song_Change(Which_Track: int, New_Song: Song):
    Which_Track = clamp(Which_Track, 1, 2)
    #if DJ_Controller.Get_Instance().Use_2_Track_Bus_Layout:
        #Which_Track = clamp(Which_Track, 1, 2)
    #else:
        #Which_Track = clamp(Which_Track, 1, 4)
        
    DJ_Controller.Get_Instance().LoadTrackIntoMemory(Which_Track, New_Song)
    match Which_Track:
        1:
            HUB_Menu_ref.Track_1 = New_Song
            HUB_Menu_ref.Refresh(true)
        2:
            HUB_Menu_ref.Track_2 = New_Song
            HUB_Menu_ref.Refresh(false)



func Refresh():
    HUB_Menu_ref.Refresh(true)
    HUB_Menu_ref.Refresh(false)
    
func _ready() -> void:
    HUB_Menu_ref.Track_1 = Track_1
    HUB_Menu_ref.Track_2 = Track_2
    
    Track_1_Selection_ref.track_selected.connect(On_Song_Change)
    Track_2_Selection_ref.track_selected.connect(On_Song_Change)
    LibreBox_instance = self
    Refresh()
