extends Control

@export var Tracks_Holder : Container

func Refresh():
    for kid in Tracks_Holder.get_children():
        kid.free()
        
    for track_id in AudioTrack.All_Track_UIDs:
        var new_track = load("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn").instantiate()
        new_track.Track_UID = track_id
        Tracks_Holder.add_child(load("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn").instantiate())
    

func _ready():
    Refresh()    
