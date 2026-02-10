extends Control
class_name LibreBox_TrackSelection

@export var Tracks_Holder : Container

const track_card = preload("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn")


func Refresh():
    for kid in Tracks_Holder.get_children():
        kid.free()
    
    for track_path in ResourceLoader.list_directory(Song.ROOT_MUSIC_DIR):
        print("Trying to make a new card with " + (Song.ROOT_MUSIC_DIR+track_path))
        var new_track : Track_Card = track_card.instantiate()
        Tracks_Holder.add_child(new_track)
        new_track.Song_Resource = load(Song.ROOT_MUSIC_DIR+track_path)
        new_track.Refresh_Details()
    

func _ready():
    Refresh()    
