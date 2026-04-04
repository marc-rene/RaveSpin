extends PanelContainer

## Loop management UI for one target deck.
## Shows loop status, allows clear loop, and toggles beat snapping.
## Target deck index (0 = left, 1 = right).
@export_range(0,1,1) var Which_track_are_we_targetting : int

@onready var _status_label: Label = $"MarginContainer/VBoxContainer/Status of the Loop"
@onready var _delete_help_label: Label = $"MarginContainer/VBoxContainer/Delete_Closest_Loop_HELP_LABEL"
@onready var _delete_btn: Button = $"MarginContainer/VBoxContainer/Delete_Closest_Loop_BTN"
@onready var _snap_help_label: Label = $"MarginContainer/VBoxContainer/Enable_Loop_Point_Snapping_HELP_LABEL"
@onready var _snap_btn: CheckButton = $"MarginContainer/VBoxContainer/Enable_Loop_Point_Snapping_BTN"

var _controller: DJ_Controller
var _ticks: int = 0


## Resolves deck target, wires controls, and applies initial state.
func _ready() -> void:
    # XRToolsViewport2DIn3D does not reliably apply forwarded scene properties at runtime.
    # Determine which deck we are on from the owning 3D viewport node name.
    Which_track_are_we_targetting = _guess_track_from_viewport_owner(Which_track_are_we_targetting)
    _controller = DJ_Controller.Get_Instance()
    if _controller == null:
        await DJ_Controller.Get_Instance_await()
        _controller = DJ_Controller.Get_Instance()

    _apply_localized_text()

    if _delete_btn != null:
        _delete_btn.pressed.connect(_on_delete_pressed)
    if _snap_btn != null:
        _snap_btn.toggled.connect(_on_snap_toggled)

    _refresh_snap_button_from_state()
    _refresh_status_text()


## Attempts to infer deck side from viewport owner naming.
func _guess_track_from_viewport_owner(fallback_track: int) -> int:
    var fallback: int = Utility.Clamp_to_Valid_TrackID(fallback_track)
    var vp: Viewport = get_viewport()
    if vp == null:
        return fallback
    var owner_3d: Node = vp.get_parent()
    if owner_3d == null:
        return fallback
    var nm: String = String(owner_3d.name).to_lower()
    if nm.begins_with("left"):
        return 0
    if nm.begins_with("right"):
        return 1
    return fallback

func _physics_process(_delta: float) -> void:
    pass


## Polls loop status text in viewport UI context.
func _process(_delta: float) -> void:
    # This UI runs inside a 2D viewport in 3D; `_process` is more reliable for updates here.
    _ticks += 1
    if _ticks % 6 == 0:
        _refresh_status_text()


## Applies translated label/button text.
func _apply_localized_text() -> void:
    if _status_label != null:
        _status_label.text = tr("KEY_LOOP_STATUS")
    if _delete_help_label != null:
        _delete_help_label.text = tr("KEY_CANCEL_LOOP_EXPLAIN")
    if _delete_btn != null:
        _delete_btn.text = tr("KEY_CANCEL_LOOP")
    if _snap_help_label != null:
        _snap_help_label.text = tr("KEY_ENABLE_BEAT_SNAPPING_EXPLAIN")
    if _snap_btn != null:
        _snap_btn.text = tr("KEY_ENABLE_BEAT_SNAPPING")


func _refresh_snap_button_from_state() -> void:
    if _snap_btn == null:
        return
    _snap_btn.button_pressed = DJ_Controller.Is_Loop_Point_Snapping_Enabled(Which_track_are_we_targetting)


func _on_delete_pressed() -> void:
    DJ_Controller.Clear_Loop(Which_track_are_we_targetting)
    _refresh_status_text()


func _on_snap_toggled(enabled: bool) -> void:
    DJ_Controller.Set_Loop_Point_Snapping_Enabled(Which_track_are_we_targetting, enabled)
    _refresh_status_text()


## Writes current loop status text for the target deck.
func _refresh_status_text() -> void:
    if _status_label == null:
        return

    var track: int = Utility.Clamp_to_Valid_TrackID(Which_track_are_we_targetting)
    if not DJ_Controller.Is_Loop_Enabled(track):
        if _delete_btn != null:
            _delete_btn.disabled = true
        _status_label.text = tr("KEY_LOOP_STATUS") + "\n" + tr("KEY_LOOP_STATUS_NO_LOOP")
        return
    if _delete_btn != null:
        _delete_btn.disabled = false

    var start_sec: float = DJ_Controller.Get_Loop_Start_Sec(track)
    var end_sec: float = DJ_Controller.Get_Loop_End_Sec(track)
    var len_sec: float = maxf(0.0, end_sec - start_sec)

    var base_bpm: float = LibreBox.Get_Track_BPM(track)
    var beats: float = 0.0
    if base_bpm > 0.0:
        beats = len_sec * (base_bpm / 60.0)

    var seconds_str: String = str("%0.3f" % len_sec)
    var beats_str: String = str("%0.3f" % beats)

    _status_label.text = (
        tr("KEY_LOOP_STATUS")
        + "\n"
        + tr("KEY_LOOP_STATUS_ACTIVE")
        + "\n"
        + tr("KEY_LOOP_LENGTH_SECONDS") + ": " + seconds_str
        + "\n"
        + tr("KEY_LOOP_LENGTH_BEATS") + ": " + beats_str
    )
