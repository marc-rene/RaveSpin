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

func Update_Controller_and_Hub(Which_Track: int, New_Song: Song):
    print("MAIN MANAGER CALLED TO CHANGE TRACK #" + str(Which_Track) + " TO SONG: " + New_Song.Song_Title)       
    DJ_Controller.Get_Instance().LoadTrackIntoMemory(Which_Track, New_Song)
    match Which_Track:
        0:
            HUB_Menu_ref.Track_1 = New_Song
            HUB_Menu_ref.Refresh(true)
        1:
            HUB_Menu_ref.Track_2 = New_Song
            HUB_Menu_ref.Refresh(false)

func On_Song_Change_Track_1(New_Song: Song):
    Update_Controller_and_Hub(0, New_Song)

func On_Song_Change_Track_2(New_Song: Song):
    Update_Controller_and_Hub(1, New_Song)



func Refresh():
    HUB_Menu_ref.Refresh(true)
    HUB_Menu_ref.Refresh(false)
    
func _ready() -> void:
    HUB_Menu_ref.Track_1 = Track_1
    HUB_Menu_ref.Track_2 = Track_2
    Track_1_Selection_ref.track_selected.connect(On_Song_Change_Track_1)
    Track_2_Selection_ref.track_selected.connect(On_Song_Change_Track_2)
    LibreBox_instance = self
    Refresh()
    await get_node("/root/Arena/DDJ-FLX4").ready
    
    DJ_Controller.Get_Instance().LoadTrackIntoMemory(0, Track_1)
    DJ_Controller.Get_Instance().LoadTrackIntoMemory(1, Track_2)
