extends Control
class_name LibreBox_TrackSelection

@onready var Tracks_Holder : Container = $"VBoxContainer/ScrollContainer/Song Cards Container"


const track_card = preload("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn")

#@export_range(0,4,1) var Which_Track_Responcible_For : int 

signal track_selected(Song_Resource : Song)


func Refresh():
    for kid in Tracks_Holder.get_children():
        kid.free()
    
    for track_path in ResourceLoader.list_directory(Song.ROOT_MUSIC_DIR):
        #print("Trying to make a new card with " + (Song.ROOT_MUSIC_DIR+track_path))
        var new_track : Track_Card = track_card.instantiate()
        Tracks_Holder.add_child(new_track)
        new_track.Song_Resource = load(Song.ROOT_MUSIC_DIR+track_path)
        if new_track.Refresh_Details():
            new_track.Card_Clicked.connect(New_Track_Selected)
            print("Card for " + new_track.Song_Resource.Song_Title + " created and hooked up successfully")
    
func New_Track_Selected(New_Song : Song):
    #print("NEW TRACK SELECTED CALLED WITH SONG: " + New_Song.Song_Title + " for track #" + str(Which_Track_Responcible_For))
    track_selected.emit(New_Song)
    

func _ready():
    #print("Track Selection Made for Track #" + str(Which_Track_Responcible_For))
    Refresh()    
