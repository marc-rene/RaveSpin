extends Control
class_name LibreBox_TrackSelection

@onready var Tracks_Holder : Container = $"VBoxContainer/ScrollContainer/Song Cards Container"
@onready var root_node : Control = $"."
@onready var Scroll_Container : ScrollContainer = $"VBoxContainer/ScrollContainer"
@onready var Scroll_Up_Node : Control = $"VBoxContainer/Scroll Up"
@onready var Scroll_Down_Node : Control = $"VBoxContainer/Scroll Down"
@onready var Add_Track_UI_node : XRToolsViewport2DIn3D = $"../../../Add Song"

const track_card = preload("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn")
@export_range(50.0, 500.0, 10.0) var hover_scroll_speed : float = 200.0 #100 is lowkey painfully slow

enum E_SCROLL_DIRECTION
{
    NONE,
    UP,
    DOWN
}

var Current_Scroll_Direction : E_SCROLL_DIRECTION = E_SCROLL_DIRECTION.NONE

signal track_selected(Song_Resource : Song)

func _process(delta: float) -> void:
    if Current_Scroll_Direction == E_SCROLL_DIRECTION.NONE:
        return
    var hov_direction : float = -1.0 if Current_Scroll_Direction == E_SCROLL_DIRECTION.UP else 1.0
    var max_scroll : int = max(0, Scroll_Container.get_v_scroll_bar().max_value)
    var next_hov_scroll : float = Scroll_Container.scroll_vertical + (hov_direction * hover_scroll_speed * delta)
    Scroll_Container.scroll_vertical = clampi(roundi(next_hov_scroll), 0, roundi(max_scroll))


func _on_scroll_up_hovered() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.UP


func _on_scroll_down_hovered() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.DOWN


func _on_scroll_hover_ended() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.NONE
        
        
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
    
    
func show_add_track():
    if Add_Track_UI_node.position.y > 1 or Add_Track_UI_node.enabled == false:
        Add_Track_UI_node.position.y = -0.16 # TODO: Make this adjustable or something
        Add_Track_UI_node.set_enabled(true)
        

func _ready():
    root_node.mouse_exited.connect(_on_scroll_hover_ended)
    #up
    Scroll_Up_Node.mouse_entered.connect(_on_scroll_up_hovered)
    Scroll_Up_Node.mouse_exited.connect(_on_scroll_hover_ended)
    #down
    Scroll_Down_Node.mouse_entered.connect(_on_scroll_down_hovered)
    Scroll_Down_Node.mouse_exited.connect(_on_scroll_hover_ended)
    
    $"VBoxContainer/HBoxContainer/ADD ZE TRACK".pressed.connect(show_add_track)
    #print("Track Selection Made for Track #" + str(Which_Track_Responcible_For))
    Refresh()    
