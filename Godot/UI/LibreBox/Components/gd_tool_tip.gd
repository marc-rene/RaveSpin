extends PanelContainer

## In-world tooltip manager for deck controls.
## Opens on hover, follows camera orientation, and can be disabled for a session.
@export var hover_delay_seconds: float = 1.2
@export var unhover_close_delay_seconds: float = 10.0
@export var hover_y_offset_meters: float = 0.27
@export var close_y_position_meters: float = -2.0
@export var open_tween_seconds: float = 0.5
@export var move_tween_seconds: float = 1.3
@export var close_tween_seconds: float = 0.5
@export var bop_distance_meters: float = 0.008
@export var bop_cycle_seconds: float = 3
@export var camera_slerp_speed: float = 2.0

## Session-wide toggle for tooltip visibility.
static var session_tooltips_enabled: bool = true

var _tooltip_viewport_node: Node3D = null
var _camera_node: Camera3D = null

var _current_hovered_control: Base_Control = null
var _active_control: Base_Control = null
var _hover_ticket: int = 0
var _idle_close_ticket: int = 0
var _is_open: bool = false
var _is_closing: bool = false

var _motion_global_position: Vector3 = Vector3.ZERO
var _bop_offset_meters: float = 0.0

var _motion_tween: Tween = null
var _scale_tween: Tween = null
var _bop_tween: Tween = null

@onready var current_tip_label: Label = $"MarginContainer/VBoxContainer/BoxContainer/Current Tip Label"
@onready var actual_help_text_label: Label = $"MarginContainer/VBoxContainer/Actual Help Text"
@onready var disable_tooltips_button: Button = $"MarginContainer/VBoxContainer/BoxContainer/DISABLE TOOLTIPS btn"
@onready var ok_close_button: Button = $"MarginContainer/VBoxContainer/BoxContainer2/OK_Close Btn"


## Binds tooltip buttons, finds target nodes, and connects all controls.
func _ready() -> void:
    disable_tooltips_button.pressed.connect(_on_disable_tooltips_pressed)
    ok_close_button.pressed.connect(_on_ok_close_pressed)
    _refresh_localised_ui()

    _tooltip_viewport_node = _find_tooltip_viewport_node()
    _camera_node = _find_xr_camera()
    _connect_all_controls()

    if _tooltip_viewport_node != null:
        _motion_global_position = _tooltip_viewport_node.global_position
        _motion_global_position.y = close_y_position_meters
        _tooltip_viewport_node.global_position = _motion_global_position
        _tooltip_viewport_node.scale = Vector3(0.01, 0.01, 0.01)
        _tooltip_viewport_node.visible = false


func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        if Utility.all_is_ready:
            _refresh_localised_ui()
            if _active_control != null:
                _apply_tooltip_text_for_control(_active_control)


## Keeps tooltip anchored and facing camera while open.
func _process(delta: float) -> void:
    if _tooltip_viewport_node == null:
        return

    _tooltip_viewport_node.global_position = _motion_global_position + Vector3(0.0, _bop_offset_meters, 0.0)
    if _is_open:
        _slerp_tooltip_towards_camera(delta)


## Finds every `Base_Control` in the current scene and wires hover callbacks.
func _connect_all_controls() -> void:
    var current_scene: Node = get_tree().current_scene
    if current_scene == null:
        return

    var pending_nodes: Array[Node] = [current_scene]
    while pending_nodes.size() > 0:
        var current_node: Node = pending_nodes.pop_back()
        var current_control: Base_Control = current_node as Base_Control
        if current_control != null:
            _normalise_control_metadata(current_control)
            var hovered_callable: Callable = Callable(self, "_on_control_hovered").bind(current_control)
            var unhovered_callable: Callable = Callable(self, "_on_control_unhovered").bind(current_control)
            if not current_control.is_connected("on_hovered", hovered_callable):
                current_control.connect("on_hovered", hovered_callable)
            if not current_control.is_connected("on_unhovered", unhovered_callable):
                current_control.connect("on_unhovered", unhovered_callable)

        var child_nodes: Array[Node] = current_node.get_children()
        for child_node: Node in child_nodes:
            pending_nodes.append(child_node)


func _refresh_localised_ui() -> void:
    disable_tooltips_button.text = tr("KEY_TOOLTIP_DISABLE_BUTTON")
    actual_help_text_label.text = tr("KEY_TOOLTIP_IDLE_BODY")


func _on_control_hovered(control: Base_Control) -> void:
    if not session_tooltips_enabled:
        return
    _current_hovered_control = control
    _hover_ticket += 1
    _idle_close_ticket += 1
    var ticket_for_hover: int = _hover_ticket
    _show_tooltip_after_hover_delay(ticket_for_hover)


func _on_control_unhovered(control: Base_Control) -> void:
    if _current_hovered_control == control:
        _current_hovered_control = null
        _hover_ticket += 1
        _idle_close_ticket += 1
        var close_ticket_for_idle: int = _idle_close_ticket
        _close_tooltip_after_unhover_delay(close_ticket_for_idle)


func _show_tooltip_after_hover_delay(ticket_for_hover: int) -> void:
    await get_tree().create_timer(hover_delay_seconds).timeout
    if not session_tooltips_enabled:
        return
    if ticket_for_hover != _hover_ticket:
        return
    if _current_hovered_control == null:
        return
    _open_or_move_tooltip_for_control(_current_hovered_control)


## Opens or repositions tooltip for currently hovered control.
func _open_or_move_tooltip_for_control(control: Base_Control) -> void:
    if _tooltip_viewport_node == null:
        return

    _active_control = control
    _apply_tooltip_text_for_control(control)
    var target_global_position: Vector3 = _get_tooltip_target_position_for_control(control)

    _kill_close_tween()
    _kill_motion_tween()
    _kill_scale_tween()
    _is_closing = false

    if not _is_open:
        _is_open = true
        _tooltip_viewport_node.visible = true
        _tooltip_viewport_node.scale = Vector3(0.01, 0.01, 0.01)
        _scale_tween = create_tween()
        _scale_tween.set_ease(Tween.EASE_IN)
        _scale_tween.set_trans(Tween.TRANS_CUBIC)
        _scale_tween.tween_property(_tooltip_viewport_node, "scale", Vector3(1.0, 1.0, 1.0), open_tween_seconds)
    else:
        if _tooltip_viewport_node.scale != Vector3(1.0, 1.0, 1.0):
            _scale_tween = create_tween()
            _scale_tween.set_ease(Tween.EASE_IN)
            _scale_tween.set_trans(Tween.TRANS_CUBIC)
            _scale_tween.tween_property(_tooltip_viewport_node, "scale", Vector3(1.0, 1.0, 1.0), move_tween_seconds)

    _motion_tween = create_tween()
    # Thanks https://www.reddit.com/r/godot/comments/14gt180/all_possible_tweening_transition_types_and_easing/#lightbox
    _motion_tween.set_ease(Tween.EASE_IN_OUT)
    _motion_tween.set_trans(Tween.TRANS_BACK)
    _motion_tween.tween_property(self, "_motion_global_position", target_global_position, move_tween_seconds)
    _start_bop_tween()


## Writes title/description text for the hovered control.
func _apply_tooltip_text_for_control(control: Base_Control) -> void:
    var display_name: String = control.Control_Display_Name
    if display_name.strip_edges().is_empty():
        display_name = String(control.name).replace("_", " ")

    var description_text: String = control.Control_Description
    if description_text.strip_edges().is_empty():
        description_text = _get_default_description_for_control(control)

    current_tip_label.text = tr(display_name)
    actual_help_text_label.text = tr(description_text)


func _get_tooltip_target_position_for_control(control: Base_Control) -> Vector3:
    var anchor_position: Vector3 = control.global_position
    if control.Target_Mesh != null:
        anchor_position = control.Target_Mesh.global_position
    var target_position: Vector3 = anchor_position + Vector3(0.0, hover_y_offset_meters, 0.0)
    if target_position.y < anchor_position.y + hover_y_offset_meters:
        target_position.y = anchor_position.y + hover_y_offset_meters
    return target_position


func _start_bop_tween() -> void:
    _kill_bop_tween()
    _bop_offset_meters = 0.0
    _bop_tween = create_tween()
    _bop_tween.set_loops()
    _bop_tween.tween_property(self, "_bop_offset_meters", bop_distance_meters, bop_cycle_seconds * 0.5)
    _bop_tween.tween_property(self, "_bop_offset_meters", 0.0, bop_cycle_seconds * 0.5)


func _slerp_tooltip_towards_camera(delta: float) -> void:
    if _camera_node == null:
        _camera_node = _find_xr_camera()
    if _camera_node == null:
        return

    var to_camera: Vector3 = _camera_node.global_position - _tooltip_viewport_node.global_position
    if to_camera.length_squared() <= 0.000001:
        return

    var to_camera_direction: Vector3 = to_camera.normalized()
    var up_axis: Vector3 = Vector3.UP
    if absf(to_camera_direction.dot(up_axis)) > 0.98:
        up_axis = Vector3.RIGHT

    # Godot look_at uses -Z as forward, so we invert direction
    # to make +Z face the camera.
    var look_basis: Basis = Basis().looking_at(-to_camera_direction, up_axis)
    var current_transform: Transform3D = _tooltip_viewport_node.global_transform
    _tooltip_viewport_node.global_transform = Transform3D(look_basis, current_transform.origin)


func _on_disable_tooltips_pressed() -> void:
    session_tooltips_enabled = false
    _request_close_tooltip()


func _on_ok_close_pressed() -> void:
    _request_close_tooltip()


func _close_tooltip_after_unhover_delay(close_ticket_for_idle: int) -> void:
    await get_tree().create_timer(unhover_close_delay_seconds).timeout
    if close_ticket_for_idle != _idle_close_ticket:
        return
    if _current_hovered_control != null:
        return
    if not _is_open:
        return
    _request_close_tooltip()


func _request_close_tooltip() -> void:
    if _tooltip_viewport_node == null:
        return

    _is_open = false
    _is_closing = true
    _active_control = null
    _current_hovered_control = null
    _hover_ticket += 1
    _idle_close_ticket += 1

    _kill_bop_tween()
    _kill_motion_tween()
    _kill_scale_tween()
    _bop_offset_meters = 0.0

    var close_target_position: Vector3 = _motion_global_position
    close_target_position.y = close_y_position_meters

    _motion_tween = create_tween()
    _motion_tween.set_ease(Tween.EASE_IN_OUT)
    _motion_tween.set_trans(Tween.TRANS_BACK)
    _motion_tween.tween_property(self, "_motion_global_position", close_target_position, close_tween_seconds)

    _scale_tween = create_tween()
    _scale_tween.set_ease(Tween.EASE_IN)
    _scale_tween.set_trans(Tween.TRANS_CUBIC)
    _scale_tween.tween_property(_tooltip_viewport_node, "scale", Vector3(0.001, 0.001, 0.001), close_tween_seconds)
    _scale_tween.finished.connect(_on_close_scale_tween_finished)


func _on_close_scale_tween_finished() -> void:
    if _tooltip_viewport_node == null:
        return
    if _is_closing:
        _tooltip_viewport_node.visible = false
        _is_closing = false


func _kill_motion_tween() -> void:
    if _motion_tween != null and _motion_tween.is_valid():
        _motion_tween.kill()
    _motion_tween = null


func _kill_scale_tween() -> void:
    if _scale_tween != null and _scale_tween.is_valid():
        _scale_tween.kill()
    _scale_tween = null


func _kill_close_tween() -> void:
    if _is_closing:
        _is_closing = false


func _kill_bop_tween() -> void:
    if _bop_tween != null and _bop_tween.is_valid():
        _bop_tween.kill()
    _bop_tween = null


func _find_tooltip_viewport_node() -> Node3D:
    var current_scene: Node = get_tree().current_scene
    if current_scene == null:
        return null
    var tooltip_node: Node = current_scene.get_node_or_null("LibreboxScene/ToolTip")
    if tooltip_node is Node3D:
        return tooltip_node as Node3D
    var any_tooltip_node: Node = current_scene.find_child("ToolTip", true, false)
    if any_tooltip_node is Node3D:
        return any_tooltip_node as Node3D
    return null


func _find_xr_camera() -> Camera3D:
    var current_scene: Node = get_tree().current_scene
    if current_scene == null:
        return null
    var camera_by_path: Node = current_scene.get_node_or_null("Player/XRCamera3D")
    if camera_by_path is Camera3D:
        return camera_by_path as Camera3D
    var any_camera_node: Node = current_scene.find_child("XRCamera3D", true, false)
    if any_camera_node is Camera3D:
        return any_camera_node as Camera3D
    return null


func _normalise_control_metadata(control: Base_Control) -> void:
    if control.Control_Display_Name.strip_edges().is_empty():
        control.Control_Display_Name = String(control.name).replace("_", " ")
    if control.Control_Description.strip_edges().is_empty():
        control.Control_Description = _get_default_description_for_control(control)


func _get_default_description_for_control(control: Base_Control) -> String:
    var control_name: String = String(control.name)

    if control_name.begins_with("Left Pad "):
        return "Performance pad for deck one. Trigger cues, sampler sounds, beat jumps, key shift, or hold FX depending on your selected pad mode."
    if control_name.begins_with("Right Pad "):
        return "Performance pad for deck two. Trigger cues, sampler sounds, beat jumps, key shift, or hold FX depending on your selected pad mode."

    match control_name:
        "Left_Play":
            return "Starts or pauses deck one so you can launch or stop the track on beat."
        "Right_Play":
            return "Starts or pauses deck two so you can launch or stop the track on beat."
        "Left_CUE":
            return "Jumps deck one to its cue position so you can rehearse timing and punch in cleanly."
        "Right_CUE":
            return "Jumps deck two to its cue position so you can rehearse timing and punch in cleanly."
        "L Channel Fader":
            return "Controls the output level of deck one into the main mix."
        "R Channel Fader":
            return "Controls the output level of deck two into the main mix."
        "Crossfade":
            return "Blends between deck one and deck two. Centre gives both decks space in the mix."
        "L Tempo Adjust":
            return "Nudges deck one tempo up or down for beatmatching."
        "R Tempo Adjust":
            return "Nudges deck two tempo up or down for beatmatching."
        "Left Trim":
            return "Sets deck one input gain before EQ and effects. Keep this balanced to avoid clipping."
        "Right Trim":
            return "Sets deck two input gain before EQ and effects. Keep this balanced to avoid clipping."
        "Left High Gain":
            return "Adjusts deck one high frequencies for brighter hats and top-end sparkle."
        "Right High Gain":
            return "Adjusts deck two high frequencies for brighter hats and top-end sparkle."
        "Left Medium Gain":
            return "Adjusts deck one mid frequencies where vocals and synth leads usually sit."
        "Right Medium Gain":
            return "Adjusts deck two mid frequencies where vocals and synth leads usually sit."
        "Left Low Gain":
            return "Adjusts deck one low frequencies for punchy kick and bass control."
        "Right Low Gain":
            return "Adjusts deck two low frequencies for punchy kick and bass control."
        "Left Colour FX":
            return "Controls deck one Sound Colour FX. Move one side for low-pass feel and the other for high-pass energy shaping."
        "Right Colour FX":
            return "Controls deck two Sound Colour FX. Move one side for low-pass feel and the other for high-pass energy shaping."
        "Left_BeatSync":
            return "Synchronises deck one tempo and beat phase to the opposite deck."
        "Right_BeatSync":
            return "Synchronises deck two tempo and beat phase to the opposite deck."
        "Left_LoopStart":
            return "Sets the loop start point on deck one."
        "Right_LoopStart":
            return "Sets the loop start point on deck two."
        "Left_LoopEND":
            return "Sets the loop end point on deck one."
        "Right_LoopEND":
            return "Sets the loop end point on deck two."
        "Left_Make4BeatLoop":
            return "Creates or toggles a four beat loop on deck one."
        "Right_Make4BeatLoop":
            return "Creates or toggles a four beat loop on deck two."
        "Left_ShortenLoop":
            return "Halves the active loop length on deck one for tighter rhythmic cuts."
        "Right_ShortenLoop":
            return "Halves the active loop length on deck two for tighter rhythmic cuts."
        "Left_ExtendLoop":
            return "Doubles the active loop length on deck one for broader phrase work."
        "Right_ExtendLoop":
            return "Doubles the active loop length on deck two for broader phrase work."
        "Beat FX":
            return "Sets how intense the active Beat FX feels in the mix."
        "Master Volume":
            return "Adjusts the overall master output level."
        "Mic Level":
            return "Adjusts microphone level so your voice sits cleanly over the music."
        _:
            return "Use this control to shape your blend and keep the groove locked."
