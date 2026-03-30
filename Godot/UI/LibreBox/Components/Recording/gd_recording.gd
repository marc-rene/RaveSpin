extends PanelContainer

const RECORDINGS_DIR: String = "user://Recordings"
const MASTER_BUS_NAME: String = "Master"
const MIC_BUS_NAME: String = "Microphone Input"
const ANDROID_MIC_PERMISSION: String = "android.permission.RECORD_AUDIO"
const MIC_NA_THRESHOLD: float = 0.1
const MIC_MONITOR_ATTENUATION: float = 0.6
const MIC_MONITOR_BUFFER_SECONDS: float = 0.25

const KEY_RECORDING_STATUS_IDLE: String = "KEY_RECORDING_STATUS"
const KEY_RECORDING_START: String = "KEY_START_RECORDING"
const KEY_RECORDING_STOP: String = "KEY_STOP_RECORDING"
const KEY_RECORDING_STARTED: String = "KEY_RECORDING_STARTED"
const KEY_RECORDING_SAVING: String = "KEY_RECORDING_SAVING"
const KEY_RECORDING_SAVED_TO: String = "KEY_RECORDING_SAVED_TO"
const KEY_RECORDING_SAVE_IN_PROGRESS: String = "KEY_RECORDING_SAVE_IN_PROGRESS"
const KEY_ENABLE_MICROPHONE: String = "KEY_ENABLE_MICROPHONE"
const KEY_RECORDING_SAVE_LOCATION: String = "KEY_RECORDING_SAVE_LOCATION"

@onready var main_container : Container = $VBoxContainer
@onready var _status_label: Label = $"VBoxContainer/Status Label"
@onready var _record_button: CheckButton = $"VBoxContainer/START recordin BTN"
@onready var _save_location_label: Label = $"VBoxContainer/Save Location/Where File is actually going Label Var"
@onready var _save_location_prefix_label: Label = $"VBoxContainer/Save Location/File Save Label"
@onready var _enable_mic_button: CheckButton = $"VBoxContainer/Enable Microphone input"

var _record_effect: AudioEffectRecord = null
var _recording_pulse_tween: Tween = null
var _save_thread: Thread = null
var _mic_monitor_player: AudioStreamPlayer = null
var _mic_monitor_playback: AudioStreamGeneratorPlayback = null
var _mic_monitor_db: float = -80.0

var _is_recording: bool = false
var _save_in_progress: bool = false
var _status_translation_key: String = ""
var _status_raw_text: String = ""


func _ready() -> void:
    add_to_group("librebox_recording")
    _record_button.toggled.connect(_on_record_button_toggled)
    _enable_mic_button.toggled.connect(_on_enable_microphone_toggled)

    _record_effect = _ensure_master_record_effect()
    var dir_error: int = _ensure_recordings_directory()
    if dir_error != OK:
        _set_status_raw("Recording init error: failed to create Recordings directory. Error code: " + str(dir_error))
    else:
        _set_status_localized(KEY_RECORDING_STATUS_IDLE)

    _refresh_localized_ui()
    _apply_microphone_enabled_state(_enable_mic_button.button_pressed)


func _process(_delta: float) -> void:
    _update_mic_monitor()
    _poll_save_thread()


func _exit_tree() -> void:
    if _record_effect != null:
        _record_effect.set_recording_active(false)
    if _save_thread != null:
        _save_thread.wait_to_finish()
        _save_thread = null


func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        if Utility.all_is_ready:
            _refresh_localized_ui()


func _refresh_localized_ui() -> void:
    _record_button.text = tr(KEY_RECORDING_STOP) if _is_recording else tr(KEY_RECORDING_START)
    _enable_mic_button.text = tr(KEY_ENABLE_MICROPHONE)
    _save_location_prefix_label.text = tr(KEY_RECORDING_SAVE_LOCATION)
    _save_location_label.text = tr(KEY_RECORDING_SAVE_LOCATION) + " : " + RECORDINGS_DIR

    if _status_raw_text.is_empty() and not _status_translation_key.is_empty():
        _status_label.text = tr(_status_translation_key)
    elif not _status_raw_text.is_empty():
        _status_label.text = _status_raw_text


func _on_record_button_toggled(pressed: bool) -> void:
    if _save_in_progress:
        _record_button.set_pressed_no_signal(false)
        _set_status_localized(KEY_RECORDING_SAVE_IN_PROGRESS)
        return

    if pressed:
        _start_recording()
    else:
        _stop_recording()


func _start_recording() -> void:
    _record_effect = _ensure_master_record_effect()
    if _record_effect == null:
        _record_button.set_pressed_no_signal(false)
        _set_status_raw("Recording start error: AudioEffectRecord was not found on Master bus.")
        _stop_recording_pulse()
        return

    _apply_microphone_enabled_state(_enable_mic_button.button_pressed)
    _record_effect.set_recording_active(true)
    _is_recording = true
    _start_recording_pulse()
    _set_status_localized(KEY_RECORDING_STARTED)
    _refresh_localized_ui()


func _stop_recording() -> void:
    _record_effect = _ensure_master_record_effect()
    if _record_effect == null:
        _set_status_raw("Recording stop error: AudioEffectRecord was not found on Master bus.")
        _is_recording = false
        _stop_recording_pulse()
        _refresh_localized_ui()
        return

    _record_effect.set_recording_active(false)
    _is_recording = false
    _stop_recording_pulse()
    _refresh_localized_ui()

    var recorded_stream: AudioStreamWAV = _record_effect.get_recording()
    if recorded_stream == null or recorded_stream.data.is_empty():
        _set_status_raw("Recording error: no audio data was captured.")
        _debug_print_user_storage()
        return

    var ensure_error: int = _ensure_recordings_directory()
    if ensure_error != OK:
        _set_status_raw("Recording save error: failed to create Recordings directory. Error code: " + str(ensure_error))
        _debug_print_user_storage()
        return

    var save_path: String = RECORDINGS_DIR + "/mix_recording_" + _make_timestamp_string() + ".wav"
    
    _start_save_thread(recorded_stream, save_path)


func _start_save_thread(recorded_stream: AudioStreamWAV, save_path: String) -> void:
    _save_in_progress = true
    _set_status_localized(KEY_RECORDING_SAVING)
    _save_thread = Thread.new()
    var start_error: int = _save_thread.start(Callable(self, "_thread_save_recording").bind(recorded_stream, save_path))
    if start_error != OK:
        _save_in_progress = false
        _save_thread = null
        _set_status_raw("Recording save error: failed to start save thread. Error code: " + str(start_error))
        _debug_print_user_storage()


func _poll_save_thread() -> void:
    if _save_thread == null:
        return
    if _save_thread.is_alive():
        return

    var result: Dictionary = _save_thread.wait_to_finish()
    _save_thread = null
    _save_in_progress = false

    var save_error: int = int(result.get("error", ERR_CANT_CREATE))
    var save_path: String = str(result.get("path", ""))

    _debug_print_user_storage()
    if save_error != OK:
        _set_status_raw("Recording save failed. Error code: " + str(save_error))
        return

    _set_status_localized(KEY_RECORDING_SAVED_TO)
    _status_label.text = tr(KEY_RECORDING_SAVED_TO) + " : " + save_path


func _thread_save_recording(recorded_stream: AudioStreamWAV, save_path: String) -> Dictionary:
    var result: Dictionary = {
        "error": OK,
        "path": save_path
    }

    var save_error: int = recorded_stream.save_to_wav(save_path)
    if save_error != OK:
        result["error"] = save_error

    return result


func _on_enable_microphone_toggled(enabled: bool) -> void:
    if enabled:
        var has_permission: bool = await _ensure_android_mic_permission()
        if not has_permission:
            _enable_mic_button.set_pressed_no_signal(false)
            _apply_microphone_enabled_state(false)
            _set_status_raw("Microphone permission denied. Enable RECORD_AUDIO in Android permissions and grant runtime permission.")
            return

    _apply_microphone_enabled_state(enabled)


func _apply_microphone_enabled_state(enabled: bool) -> void:
    var mic_bus_index: int = AudioServer.get_bus_index(MIC_BUS_NAME)
    if mic_bus_index < 0:
        _set_status_raw("Microphone bus error: '" + MIC_BUS_NAME + "' bus not found.")
        return

    if enabled:
        AudioServer.set_input_device_active(true)
        _ensure_mic_monitor_player()
        AudioServer.set_bus_mute(mic_bus_index, false)
        if _mic_monitor_player != null and not _mic_monitor_player.playing:
            _mic_monitor_player.play()
        _debug_print_android_permission_state()
    else:
        AudioServer.set_bus_mute(mic_bus_index, true)
        if _mic_monitor_player != null and _mic_monitor_player.playing:
            _mic_monitor_player.stop()
        _mic_monitor_db = -80.0


func _ensure_mic_monitor_player() -> void:
    if _mic_monitor_player != null and is_instance_valid(_mic_monitor_player):
        if _mic_monitor_playback == null:
            _mic_monitor_playback = _mic_monitor_player.get_stream_playback() as AudioStreamGeneratorPlayback
        return

    var monitor_stream: AudioStreamGenerator = AudioStreamGenerator.new()
    monitor_stream.mix_rate = max(1.0, AudioServer.get_input_mix_rate())
    monitor_stream.buffer_length = MIC_MONITOR_BUFFER_SECONDS

    _mic_monitor_player = AudioStreamPlayer.new()
    _mic_monitor_player.name = "Runtime_Mic_Monitor_Player"
    _mic_monitor_player.bus = MIC_BUS_NAME
    _mic_monitor_player.stream = monitor_stream
    add_child(_mic_monitor_player)
    _mic_monitor_player.play()
    _mic_monitor_playback = _mic_monitor_player.get_stream_playback() as AudioStreamGeneratorPlayback


func _ensure_android_mic_permission() -> bool:
    if not OS.has_feature("android"):
        return true

    if _has_android_mic_permission():
        return true

    if OS.has_method("request_permission"):
        OS.request_permission(ANDROID_MIC_PERMISSION)
    elif OS.has_method("request_permissions"):
        OS.request_permissions()
    else:
        return false

    # Let Android runtime permission dialog complete.
    await get_tree().process_frame
    await get_tree().create_timer(0.35).timeout
    return _has_android_mic_permission()


func _has_android_mic_permission() -> bool:
    if not OS.has_feature("android"):
        return true

    if OS.has_method("get_granted_permissions"):
        var granted_permissions: PackedStringArray = OS.get_granted_permissions()
        return granted_permissions.has(ANDROID_MIC_PERMISSION)

    return false


func _debug_print_android_permission_state() -> void:
    if not OS.has_feature("android"):
        return
    if not OS.has_method("get_granted_permissions"):
        print("Android mic permission debug: OS.get_granted_permissions not available.")
        return
    var granted_permissions: PackedStringArray = OS.get_granted_permissions()
    print("Android mic permission granted: " + str(granted_permissions.has(ANDROID_MIC_PERMISSION)))
    print("Granted permissions: " + str(granted_permissions))


func _update_mic_monitor() -> void:
    if not _enable_mic_button.button_pressed:
        return
    if _is_mic_level_too_low():
        _mic_monitor_db = -80.0
        return

    _ensure_mic_monitor_player()
    if _mic_monitor_playback == null:
        return

    var available_frames: int = AudioServer.get_input_frames_available()
    if available_frames <= 0:
        return

    var input_frames: PackedVector2Array = AudioServer.get_input_frames(available_frames)
    if input_frames.is_empty():
        return

    var monitor_gain: float = _map_mic_knob_to_linear_gain(_get_controller_mic_knob_value()) * MIC_MONITOR_ATTENUATION
    var peak_linear: float = 0.0
    for frame in input_frames:
        var out_frame: Vector2 = frame * monitor_gain
        _mic_monitor_playback.push_frame(out_frame)
        peak_linear = maxf(peak_linear, absf(out_frame.x))
        peak_linear = maxf(peak_linear, absf(out_frame.y))

    _mic_monitor_db = linear_to_db(maxf(0.0001, peak_linear))


func _get_controller_mic_knob_value() -> float:
    var controller: DJ_Controller = DJ_Controller.Get_Instance()
    if controller == null:
        return 0.0

    var mic_knob_node: Node = controller.get_node_or_null("Controls/Mic Level")
    if mic_knob_node == null:
        return 0.0

    var knob_value_variant: Variant = mic_knob_node.get("Value")
    if knob_value_variant == null:
        return 0.0

    return clampf(float(knob_value_variant), 0.0, 1.0)


func _map_mic_knob_to_linear_gain(alpha: float) -> float:
    alpha = clampf(alpha, 0.0, 1.0)
    if alpha <= 0.5:
        return remap(alpha, 0.0, 0.5, 0.0, 0.5)
    return remap(alpha, 0.5, 1.0, 0.5, 2.0)


func _is_mic_level_too_low() -> bool:
    return _get_controller_mic_knob_value() <= MIC_NA_THRESHOLD


func get_mic_monitor_db() -> float:
    return _mic_monitor_db


func _ensure_recordings_directory() -> int:
    return DirAccess.make_dir_recursive_absolute(RECORDINGS_DIR)


func _ensure_master_record_effect() -> AudioEffectRecord:
    var master_bus_index: int = AudioServer.get_bus_index(MASTER_BUS_NAME)
    if master_bus_index < 0:
        return null

    var effect_count: int = AudioServer.get_bus_effect_count(master_bus_index)
    for effect_slot in range(effect_count):
        var current_effect: AudioEffect = AudioServer.get_bus_effect(master_bus_index, effect_slot)
        if current_effect is AudioEffectRecord:
            return current_effect as AudioEffectRecord

    var record_effect: AudioEffectRecord = AudioEffectRecord.new()
    AudioServer.add_bus_effect(master_bus_index, record_effect, 0)
    return record_effect


func _start_recording_pulse() -> void:
    _stop_recording_pulse()
    _recording_pulse_tween = create_tween()
    _recording_pulse_tween.set_loops()
    _recording_pulse_tween.tween_property(main_container, "modulate", Color(1.0, 0.25, 0.25, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _recording_pulse_tween.tween_property(main_container, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_recording_pulse() -> void:
    if _recording_pulse_tween != null:
        _recording_pulse_tween.kill()
        _recording_pulse_tween = null
    main_container.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _set_status_localized(key: String) -> void:
    _status_translation_key = key
    _status_raw_text = ""
    _status_label.text = tr(key)


func _set_status_raw(raw_text: String) -> void:
    _status_translation_key = ""
    _status_raw_text = raw_text
    _status_label.text = raw_text


func _make_timestamp_string() -> String:
    var dt: Dictionary = Time.get_datetime_dict_from_system()
    var year: int = int(dt.get("year", 1970))
    var month: int = int(dt.get("month", 1))
    var day: int = int(dt.get("day", 1))
    var hour: int = int(dt.get("hour", 0))
    var minute: int = int(dt.get("minute", 0))
    var second: int = int(dt.get("second", 0))
    return "%04d%02d%02d_%02d%02d%02d" % [year, month, day, hour, minute, second]


func _debug_print_user_storage() -> void:
    print("--- Recording Debug: user:// ---")
    _print_directory_contents("user://")
    print("--- Recording Debug: user://Recordings/ ---")
    _print_directory_contents(RECORDINGS_DIR)


func _print_directory_contents(path: String) -> void:
    var dir: DirAccess = DirAccess.open(path)
    if dir == null:
        print(path + " -> [ERROR] Could not open directory.")
        return

    dir.list_dir_begin()
    while true:
        var entry_name: String = dir.get_next()
        if entry_name.is_empty():
            break
        if entry_name.begins_with("."):
            continue
        var entry_kind: String = "[DIR]" if dir.current_is_dir() else "[FILE]"
        print(path + " -> " + entry_kind + " " + entry_name)
    dir.list_dir_end()
