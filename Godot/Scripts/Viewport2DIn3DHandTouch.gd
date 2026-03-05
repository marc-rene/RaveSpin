extends Node
class_name Viewport2DIn3DHandTouch

# add physical hand/finger interact for XRToolsViewport2DIn3D

@export_flags_3d_physics var hand_collision_mask: int = 1

# Minimum seconds between clicks 
@export var click_cooldown_seconds: float = 0.25

var _viewport: SubViewport
var _screen_body: Node  # StaticBody3D with viewport_2d_in_3d_body.gd (has global_to_viewport)
var _touch_area: Area3D
var _cooldown_by_area: Dictionary = {}  # area -> cooldown end time


func _ready() -> void:
    var parent = get_parent()
    if not parent is XRToolsViewport2DIn3D:
        push_error("Viewport2DIn3DHandTouch gotta have a XRToolsViewport2DIn3D daddy... failure")
        set_process(false)
        return

    var viewport_2d_to_3d: XRToolsViewport2DIn3D = parent
    _viewport = viewport_2d_to_3d.get_node_or_null("Viewport") as SubViewport
    _screen_body = viewport_2d_to_3d.get_node_or_null("StaticBody3D")
    if not _viewport or not _screen_body:
        push_error("Viewport2DIn3DHandTouch couldn't find Viewport or StaticBody3D... failure.")
        set_process(false)
        return

    # ctrl shift a check
    if not _screen_body.has_method("global_to_viewport"):
        push_error("Viewport2DIn3DHandTouch found a StaticBody3D but it has no global_to_viewport... use CTRL+SHIFT+A because godot xr init is weird")
        set_process(false)
        return

    _setup_touch_area(viewport_2d_to_3d)


func _setup_touch_area(viewport_2d_to_3d: XRToolsViewport2DIn3D) -> void:
    _touch_area = Area3D.new()
    _touch_area.name = "HandTouchArea"
    _touch_area.collision_layer = 0
    _touch_area.collision_mask = hand_collision_mask
    _touch_area.monitorable = false
    _touch_area.monitoring = true

    var shape : BoxShape3D = BoxShape3D.new()
    var screen_size : Vector2 = viewport_2d_to_3d.screen_size
    shape.size = Vector3(screen_size.x, screen_size.y, 0.02)

    var col : CollisionShape3D = CollisionShape3D.new()
    col.name = "CollisionShape3D"
    
    # thanks GPT
    col.transform = Transform3D(
        Vector3(1.0, 0.0, 0.0), 
        Vector3(0.0, 1.0, 0.0), 
        Vector3(0.0, 0.0, 1.0), 
        Vector3(0.0, 0.0, -0.01))
        
    col.shape = shape

    # must call_defered other godot will fail saying it's too bsuy to add children
    _touch_area.add_child.call_deferred(col)
    viewport_2d_to_3d.add_child.call_deferred(_touch_area)

    _touch_area.area_entered.connect(_on_touch_area_entered)
    _touch_area.area_exited.connect(_on_touch_area_exited)


func _on_touch_area_entered(area: Area3D) -> void:
    if not area is Player_Finger:
        return
    if not is_instance_valid(_viewport) or not _screen_body.has_method("global_to_viewport"):
        return

    var now : float = Time.get_ticks_msec() / 1000.0
    if _cooldown_by_area.get(area, 0.0) > now:
        return
    _cooldown_by_area[area] = now + click_cooldown_seconds

    var global_at : Vector3 = area.global_position
    var at_2d: Vector2 = _screen_body.global_to_viewport(global_at)
    _simulate_click(at_2d)


func _on_touch_area_exited(_area: Area3D) -> void:
    pass


func _simulate_click(at: Vector2) -> void:
    # clamp to just the viewport 
    var viewport_size : Vector2 = _viewport.size
    at.x = clampf(at.x, 0, viewport_size.x)
    at.y = clampf(at.y, 0, viewport_size.y)

    var down : InputEventMouseButton = InputEventMouseButton.new()
    down.button_index = MOUSE_BUTTON_LEFT
    down.pressed = true
    down.position = at
    down.global_position = at
    down.button_mask = MOUSE_BUTTON_MASK_LEFT
    _viewport.push_input(down)

    var up : InputEventMouseButton= InputEventMouseButton.new()
    up.button_index = MOUSE_BUTTON_LEFT
    up.pressed = false
    up.position = at
    up.global_position = at
    up.button_mask = 0
    _viewport.push_input(up)
