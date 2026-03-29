extends "res://Scripts/Highlight_Mesh.gd"
class_name Knob_Control

# 0..1 normalised knob value
@export var Value: float = 0.5
@export var slider_spawn_tween_seconds: float = 0.12
@export var slider_despawn_tween_seconds: float = 0.10
@export var slider_far_distance_meters: float = 0.25
@export var slider_far_timeout_seconds: float = 5.0

var active = false
# Local-space min and max rotations for the knob
@export var min_quat: Quaternion = Quaternion()
@export var max_quat: Quaternion = Quaternion()

@onready var hand_ref: Area3D 
@onready var activation_area: Node3D   = $Highlight/Activation
@onready var slider_global_spawn_node : Node3D = $"Slider Spawn Point"
@onready var slider_global_spawn_node_col_box : BoxShape3D = $"Slider Spawn Point/CollisionShape3D".shape


func UpdateAlpha(new_alpha : float):
    Value = new_alpha

# Shared popup slider support
const SLIDER_SCENE : Resource = preload("res://GLOBAL/CTRL_Slider.tscn")
static var current_slider_L: Slider_Control = null
static var current_slider_R: Slider_Control = null
static var current_knob_L : Knob_Control = null
static var current_knob_R : Knob_Control = null
static var slider_closing_L: bool = false
static var slider_closing_R: bool = false
static var popup_slider_pool_initialized: bool = false
var _left_slider_far_timer_seconds: float = 0.0
var _right_slider_far_timer_seconds: float = 0.0
var _left_index_finger_ref: Player_Finger = null
var _right_index_finger_ref: Player_Finger = null


func _ready() -> void:
    super._ready()
    enable_press_feedback_tween = false
    # If you didn’t set these in the editor, default them to the current rotation
    if min_quat == Quaternion():
        min_quat = activation_area.quaternion.normalized()
    else:
        min_quat = min_quat.normalized()

    if max_quat == Quaternion():
        max_quat = activation_area.quaternion.normalized()
    else:
        max_quat = max_quat.normalized()
    await get_tree().create_timer(4).timeout # TODO: Jank fix for node race condition
    _ensure_popup_slider_pool_initialized()


func _on_activation_area_entered(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        if area is Player_Finger:
            var target_finger : Player_Finger = area as Player_Finger
            if not _can_activate_from_area(target_finger):
                HighLight(E_ActivationStates.InvalidPose)
                return
            active = true
            hand_ref = area
            HighLight(E_ActivationStates.Pressed)
            _show_popup_slider(target_finger.is_right_hand)
    


func _on_activation_area_exited(area: Area3D) -> void:
    if (Utility.is_all_ready()):
        #print("Slider Deactivated")
        if area is Player_Finger:
            #print("SUCCESS THIS WORKS")
            active = false
            if(fully_exited):
                HighLight(E_ActivationStates.Exited)
            else:
                HighLight(E_ActivationStates.Hoovered)
            #if area.get_script().is_right_hand:
                


func _process(delta: float) -> void:
    # If a popup slider is currently controlling this knob,
    # drive our value from the slider instead of hand rotation.
    if current_knob_L == self and current_slider_L != null:
        Value = clampf(current_slider_L.Value, 0.0, 1.0)
        $"Slider Spawn Point/Label3D".text = str("%.2f" % Value)
        # knob rot between min and max
        var knob_quat: Quaternion = min_quat.slerp(max_quat, Value).normalized()
        
        activation_area.quaternion = knob_quat
        
        if Target_Mesh:
            Target_Mesh.global_transform.basis = activation_area.global_transform.basis
        _update_popup_slider_distance_timeout(false, delta)
        _update_popup_slider_distance_timeout(true, delta)
        return

    elif current_knob_R == self and current_slider_R != null:
        Value = clampf(current_slider_R.Value, 0.0, 1.0)
        $"Slider Spawn Point/Label3D".text = str("%.2f" % Value)
        # knob rot between min and max
        var knob_quat: Quaternion = min_quat.slerp(max_quat, Value).normalized()
        
        activation_area.quaternion = knob_quat
        
        if Target_Mesh:
            Target_Mesh.global_transform.basis = activation_area.global_transform.basis
        _update_popup_slider_distance_timeout(false, delta)
        _update_popup_slider_distance_timeout(true, delta)
        return
    else:
        $"Slider Spawn Point/Label3D".text = ""
        
    if not active:
        return

    # hand rotation to knob local space
    var parent_basis: Basis = activation_area.get_parent().global_transform.basis
    if (hand_ref == null):
        return
    var hand_basis: Basis = hand_ref.global_transform.basis

    var hand_local_basis : Basis = parent_basis.inverse() * hand_basis
    var hand_local_quat : Quaternion = hand_local_basis.get_rotation_quaternion().normalized()

    # whats the alpha between min and max quat??
    var t: float = alpha_from_quat(hand_local_quat, min_quat, max_quat)
    t = clamp(t, 0.0, 1.0)
    #Value = t
    
    # do NOT go beyopnd min max
    var knob_quat2: Quaternion = min_quat.slerp(max_quat, t).normalized()
    activation_area.quaternion = knob_quat2

    if Target_Mesh:
        Target_Mesh.global_transform.basis = activation_area.global_transform.basis
    _update_popup_slider_distance_timeout(false, delta)
    _update_popup_slider_distance_timeout(true, delta)


func alpha_from_quat(q: Quaternion, q_min: Quaternion, q_max: Quaternion) -> float:
    # Relative rotations from min
    var total: Quaternion   = (q_min.inverse() * q_max).normalized()
    var current: Quaternion = (q_min.inverse() * q).normalized()

    # For unit quaternions, angle = 2 * acos(w)
    var total_angle: float = 2.0 * acos(clamp(total.w, -1.0, 1.0))
    if abs(total_angle) < 0.0001:
        return 0.0  # avoid division by zero if min == max

    var current_angle: float = 2.0 * acos(clamp(current.w, -1.0, 1.0))
    var t: float = current_angle / total_angle

    return clamp(t, 0.0, 1.0)


func _show_popup_slider(use_right_slider : bool) -> void:
    await _close_current_slider_if_other_knob(use_right_slider)
    _ensure_popup_slider_pool_initialized()

    if use_right_slider:
        current_knob_R = self
        current_slider_R.global_transform = slider_global_spawn_node.global_transform
        current_slider_R.Target_Mesh = null
        current_slider_R.Set_Slider_Mode(Slider_Control.E_Slider_Mode.KNOB_POPUP)

        _set_popup_slider_active(current_slider_R, true)
        await _animate_slider_spawn(current_slider_R)
        current_slider_R.UpdateAlpha(Value)
        _right_slider_far_timer_seconds = 0.0
    else:
        current_knob_L = self
        current_slider_L.global_transform = slider_global_spawn_node.global_transform
        current_slider_L.Target_Mesh = null
        current_slider_L.Set_Slider_Mode(Slider_Control.E_Slider_Mode.KNOB_POPUP)

        _set_popup_slider_active(current_slider_L, true)
        await _animate_slider_spawn(current_slider_L)
        current_slider_L.UpdateAlpha(Value)
        _left_slider_far_timer_seconds = 0.0
   



func _on_popup_slider_request_close(use_right_slider : bool) -> void:
    await _request_close_popup_slider(use_right_slider)


func _request_close_popup_slider(use_right_slider: bool) -> void:
    if use_right_slider:
        if slider_closing_R:
            return
        slider_closing_R = true
    else:
        if slider_closing_L:
            return
        slider_closing_L = true

    if use_right_slider and current_knob_R != self:
        slider_closing_R = false
        return
    elif (use_right_slider == false) and current_knob_L != self:
        slider_closing_L = false
        return

    if use_right_slider and current_slider_R != null and is_instance_valid(current_slider_R):
        await _animate_slider_despawn(current_slider_R)
        _set_popup_slider_active(current_slider_R, false)
    elif (use_right_slider == false) and current_slider_L != null and is_instance_valid(current_slider_L):
        await _animate_slider_despawn(current_slider_L)
        _set_popup_slider_active(current_slider_L, false)

    if use_right_slider:
        current_knob_R = null
        _right_slider_far_timer_seconds = 0.0
        slider_closing_R = false
    else:
        current_knob_L = null
        _left_slider_far_timer_seconds = 0.0
        slider_closing_L = false


func _close_current_slider_if_other_knob(use_right_slider: bool) -> void:
    if use_right_slider:
        if current_slider_R != null and is_instance_valid(current_slider_R) and current_knob_R != null and current_knob_R != self:
            await current_knob_R._request_close_popup_slider(true)
    else:
        if current_slider_L != null and is_instance_valid(current_slider_L) and current_knob_L != null and current_knob_L != self:
            await current_knob_L._request_close_popup_slider(false)


func _animate_slider_spawn(target_slider: Slider_Control) -> void:
    if target_slider == null:
        return
    var target_scale: Vector3 = Vector3.ONE
    target_slider.scale = Vector3(0.03, 0.03, 0.03)
    var spawn_tween: Tween = target_slider.create_tween()
    spawn_tween.tween_property(target_slider, "scale", target_scale, slider_spawn_tween_seconds)
    await spawn_tween.finished


func _set_popup_slider_active(target_slider: Slider_Control, is_enabled: bool) -> void:
    if target_slider == null:
        return
    target_slider.visible = is_enabled
    target_slider.set_process(is_enabled)

    target_slider.set_deferred("monitoring", is_enabled)
    target_slider.set_deferred("monitorable", is_enabled)
    
    if is_enabled:
        target_slider.Reset_Runtime_State()
    var highlight_area: Area3D = target_slider.get_node_or_null("Highlight") as Area3D
    if highlight_area != null:
        highlight_area.set_deferred("monitoring", is_enabled)
        highlight_area.set_deferred("monitorable", is_enabled)
    var activation_area: Area3D = target_slider.get_node_or_null("Highlight/Activation") as Area3D
    if activation_area != null:
        activation_area.set_deferred("monitoring", is_enabled)
        activation_area.set_deferred("monitorable", is_enabled)
    if not is_enabled:
        target_slider.scale = Vector3(2,2,2)
        target_slider.Reset_Runtime_State()


func _ensure_popup_slider_pool_initialized() -> void:
    if popup_slider_pool_initialized:
        return
    if get_tree() == null or get_tree().current_scene == null:
        return

    if current_slider_L == null or not is_instance_valid(current_slider_L):
        current_slider_L = SLIDER_SCENE.instantiate()
        current_slider_L.request_close.connect(_on_popup_slider_request_close.bind(false))
        current_slider_L.Set_Slider_Mode(Slider_Control.E_Slider_Mode.KNOB_POPUP)
        current_slider_L.Target_Mesh = null
        get_tree().current_scene.add_child(current_slider_L)
        _set_popup_slider_active(current_slider_L, false)

    if current_slider_R == null or not is_instance_valid(current_slider_R):
        current_slider_R = SLIDER_SCENE.instantiate()
        current_slider_R.request_close.connect(_on_popup_slider_request_close.bind(true))
        current_slider_R.Set_Slider_Mode(Slider_Control.E_Slider_Mode.KNOB_POPUP)
        current_slider_R.Target_Mesh = null
        get_tree().current_scene.add_child(current_slider_R)
        _set_popup_slider_active(current_slider_R, false)

    popup_slider_pool_initialized = true


func _animate_slider_despawn(target_slider: Slider_Control) -> void:
    if target_slider == null:
        return
    var despawn_tween: Tween = target_slider.create_tween()
    despawn_tween.tween_property(target_slider, "scale", Vector3(0.03, 0.03, 0.03), slider_despawn_tween_seconds)
    await despawn_tween.finished


func _update_popup_slider_distance_timeout(use_right_slider: bool, delta: float) -> void:
    var active_slider: Slider_Control = null
    var active_knob: Knob_Control = null
    if use_right_slider:
        active_slider = current_slider_R
        active_knob = current_knob_R
    else:
        active_slider = current_slider_L
        active_knob = current_knob_L

    if active_slider == null or not is_instance_valid(active_slider) or active_knob != self:
        if use_right_slider:
            _right_slider_far_timer_seconds = 0.0
        else:
            _left_slider_far_timer_seconds = 0.0
        return

    var index_finger: Player_Finger = _get_index_finger_for_side(use_right_slider)
    if index_finger == null or not is_instance_valid(index_finger):
        return

    var distance_to_knob_meters: float = slider_global_spawn_node.global_position.distance_to(index_finger.global_position)
    if distance_to_knob_meters > slider_far_distance_meters:
        if use_right_slider:
            _right_slider_far_timer_seconds += delta
            if _right_slider_far_timer_seconds >= slider_far_timeout_seconds:
                _right_slider_far_timer_seconds = 0.0
                _on_popup_slider_request_close(true)
        else:
            _left_slider_far_timer_seconds += delta
            if _left_slider_far_timer_seconds >= slider_far_timeout_seconds:
                _left_slider_far_timer_seconds = 0.0
                _on_popup_slider_request_close(false)
    else:
        if use_right_slider:
            _right_slider_far_timer_seconds = 0.0
        else:
            _left_slider_far_timer_seconds = 0.0


func _get_index_finger_for_side(use_right_slider: bool) -> Player_Finger:
    if use_right_slider:
        if _right_index_finger_ref == null or not is_instance_valid(_right_index_finger_ref):
            _right_index_finger_ref = get_tree().current_scene.find_child("Right_Index_Finger", true, false) as Player_Finger
        return _right_index_finger_ref

    if _left_index_finger_ref == null or not is_instance_valid(_left_index_finger_ref):
        _left_index_finger_ref = get_tree().current_scene.find_child("Left_IndexFinger", true, false) as Player_Finger
    return _left_index_finger_ref
