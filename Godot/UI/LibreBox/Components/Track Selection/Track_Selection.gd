extends Control
class_name LibreBox_TrackSelection

## Track library selection panel for one deck.
## Builds track cards, handles hover scrolling, and routes selection/removal actions.
@onready var Tracks_Holder: Container = $"VBoxContainer/ScrollContainer/Song Cards Container"
@onready var root_node: Control = $"."
@onready var Scroll_Container: ScrollContainer = $"VBoxContainer/ScrollContainer"
@onready var Scroll_Up_Node: Control = $"VBoxContainer/Scroll Up"
@onready var Scroll_Down_Node: Control = $"VBoxContainer/Scroll Down"
@onready var Add_Track_BTN : Button = $"VBoxContainer/ADD ZE TRACK"
@export var Add_Track_UI_node: XRToolsViewport2DIn3D

const track_card = preload("res://UI/LibreBox/Components/Track Card/LibreBox_TrackCard_Horizontal_UI.tscn")

@export_range(50.0, 500.0, 10.0) var hover_scroll_speed: float = 200.0

enum E_SCROLL_DIRECTION {
    NONE,
    UP,
    DOWN,
}

var Current_Scroll_Direction: E_SCROLL_DIRECTION = E_SCROLL_DIRECTION.NONE

@export var Delete_Confirm_Viewport: XRToolsViewport2DIn3D
var _pending_delete_metadata_path: String = ""

signal track_selected(Song_Resource: Song)


## Scrolls list while hover zones are active.
func _process(delta: float) -> void:
    if Current_Scroll_Direction == E_SCROLL_DIRECTION.NONE:
        return
    var hov_direction: float = -1.0 if Current_Scroll_Direction == E_SCROLL_DIRECTION.UP else 1.0
    var max_scroll: int = max(0, Scroll_Container.get_v_scroll_bar().max_value)
    var next_hov_scroll: float = Scroll_Container.scroll_vertical + (hov_direction * hover_scroll_speed * delta)
    Scroll_Container.scroll_vertical = clampi(roundi(next_hov_scroll), 0, roundi(max_scroll))


func _on_scroll_up_hovered() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.UP


func _on_scroll_down_hovered() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.DOWN


func _on_scroll_hover_ended() -> void:
    Current_Scroll_Direction = E_SCROLL_DIRECTION.NONE


## Rebuilds the card list from all song metadata resources.
func Refresh() -> void:
    for kid in Tracks_Holder.get_children():
        kid.free()

    var song_paths: PackedStringArray = Song.Get_All_Song_Paths()
    for path_index: int in range(song_paths.size()):
        var full_path: String = song_paths[path_index]
        var new_track: Track_Card = track_card.instantiate() as Track_Card
        Tracks_Holder.add_child(new_track)
        new_track.Song_Resource = load(full_path) as Song
        if new_track.Refresh_Details():
            new_track.Card_Clicked.connect(New_Track_Selected)
            new_track.Remove_Requested.connect(_on_track_card_remove_requested)
            print("Card for " + str(new_track.Song_Resource.Song_Title) + " created and hooked up successfully")


## Emits selected track for parent manager to load.
func New_Track_Selected(New_Song: Song) -> void:
    track_selected.emit(New_Song)


## Opens Add Track viewport panel.
func show_add_track() -> void:
    if Add_Track_UI_node == null:
        Add_Track_UI_node = get_node("/root/Arena/LibreboxScene/Add Song") as XRToolsViewport2DIn3D
    if Add_Track_UI_node.position.y > 1 or Add_Track_UI_node.enabled == false:
        Add_Track_UI_node.position.y = -0.16
        Add_Track_UI_node.call_deferred("set_enabled", true)


## Opens delete confirmation dialog for selected song.
func _on_track_card_remove_requested(target_song: Song) -> void:
    if target_song == null:
        return
    var metadata_path: String = target_song.resource_path
    if metadata_path.is_empty():
        push_warning("Track remove: song has no resource path.")
        return
    _pending_delete_metadata_path = metadata_path
    if Delete_Confirm_Viewport == null:
        var viewport_candidate: Node = get_node("/root/Arena/LibreboxScene/Track Delete Confirm")
        if viewport_candidate is XRToolsViewport2DIn3D:
            Delete_Confirm_Viewport = viewport_candidate as XRToolsViewport2DIn3D
    if Delete_Confirm_Viewport == null:
        push_warning("Track Delete Confirm viewport not found (expected under LibreboxScene in Arena).")
        return
    var ui_root: Node = Delete_Confirm_Viewport.get_scene_instance()
    if ui_root == null:
        push_warning("Track delete confirm UI is not loaded yet; try again in a moment.")
        return
    if not (ui_root is TrackDeleteConfirmUI):
        push_warning("Track delete confirm root must use TrackDeleteConfirmUI script.")
        return
    var confirm_ui: TrackDeleteConfirmUI = ui_root as TrackDeleteConfirmUI
    
    if not confirm_ui.delete_confirmed.is_connected(_on_delete_confirmed):
        confirm_ui.delete_confirmed.connect(_on_delete_confirmed)
    if not confirm_ui.delete_cancelled.is_connected(_on_delete_cancelled):
        confirm_ui.delete_cancelled.connect(_on_delete_cancelled)
        
    var title_safe: String = String(target_song.Song_Title)
    
    confirm_ui.set_message_text(tr("KEY_REMOVE_LIBRARY_CONFIRM") + ": " + title_safe)
    
    Delete_Confirm_Viewport.call_deferred("set_enabled", true)
    Delete_Confirm_Viewport.position.y = 0


## Confirms deletion, removes song files, and refreshes both deck lists.
func _on_delete_confirmed() -> void:
    var path_to_delete: String = _pending_delete_metadata_path
    _hide_delete_confirm_dialog()
    _pending_delete_metadata_path = ""
    if path_to_delete.is_empty():
        return
    var outcome: Dictionary = Song.try_delete_song_at_metadata_path(path_to_delete)
    if not bool(outcome.get("ok", false)):
        push_warning(String(outcome.get("message", "Could not remove track.")))
        return
    LibreBox.apply_song_deleted_from_library(path_to_delete)
    LibreBox.refresh_both_track_selection_lists()


func _on_delete_cancelled() -> void:
    _pending_delete_metadata_path = ""
    _hide_delete_confirm_dialog()


func _hide_delete_confirm_dialog() -> void:
    if Delete_Confirm_Viewport != null:
        Delete_Confirm_Viewport.call_deferred("set_enabled", false)
        Delete_Confirm_Viewport.position.y = 2


## Initialises scroll handlers and card list.
func _ready() -> void:
    root_node.mouse_exited.connect(_on_scroll_hover_ended)
    Scroll_Up_Node.mouse_entered.connect(_on_scroll_up_hovered)
    Scroll_Up_Node.mouse_exited.connect(_on_scroll_hover_ended)
    Scroll_Down_Node.mouse_entered.connect(_on_scroll_down_hovered)
    Scroll_Down_Node.mouse_exited.connect(_on_scroll_hover_ended)
    Add_Track_BTN.pressed.connect(show_add_track)
    Refresh()
