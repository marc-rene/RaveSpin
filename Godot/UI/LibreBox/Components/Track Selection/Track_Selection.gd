extends Control
class_name LibreBox_TrackSelection

@onready var Tracks_Holder : Container = $"VBoxContainer/ScrollContainer/Song Cards Container"
@export_range(1, 4, 1, "prefer_slider") var Target_Track_Slot : int

const track_card = preload("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn")

@export_range(1,2,1) var Which_Track_Responcible_For : int 

signal track_selected(Which_track : int, Song_Resource : Song)


func Refresh():
    for kid in Tracks_Holder.get_children():
        kid.free()
    
    for track_path in ResourceLoader.list_directory(Song.ROOT_MUSIC_DIR):
        #print("Trying to make a new card with " + (Song.ROOT_MUSIC_DIR+track_path))
        var new_track : Track_Card = track_card.instantiate()
        Tracks_Holder.add_child(new_track)
        new_track.Song_Resource = load(Song.ROOT_MUSIC_DIR+track_path)
        if new_track.Refresh_Details():
            new_track.Card_Clicked.connect(New_Track_Selected.bind(new_track.Song_Resource))
            print("Card for " + new_track.Song_Resource.Song_Title + " created and hooked up successfully")
    
func New_Track_Selected(New_Song : Song):
    track_selected.emit(Which_Track_Responcible_For, New_Song)
    

func _ready():
    Refresh()    
