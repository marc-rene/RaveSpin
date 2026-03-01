extends Node
class_name BUS_MANAGER



# do NOT mess with this order... unless you change Main Audio Bus Layout.tres
enum E_AUDIO_BUSSES
{
    MASTER,
    MIXER,
    MICROPHONE_FX,
    MICROPHONE_INPUT,
    CHANNEL_ONE_FX,
    CHANNEL_ONE_INPUT,
    CHANNEL_TWO_FX,
    CHANNEL_TWO_INPUT,
    CHANNEL_THREE_FX,
    CHANNEL_THREE_INPUT,
    CHANNEL_FOUR_FX,
    CHANNEL_FOUR_INPUT,
}

# NEVER add effects to raw imput... MAYBE amplify but thats it
const BUS_NAMES : Dictionary[E_AUDIO_BUSSES, StringName] = {
    E_AUDIO_BUSSES.MASTER : &"Master",
    E_AUDIO_BUSSES.MIXER : &"Main Mixer",
    E_AUDIO_BUSSES.MICROPHONE_FX : &"Microphone FX",
    E_AUDIO_BUSSES.MICROPHONE_INPUT : &"Microphone Input",
    E_AUDIO_BUSSES.CHANNEL_ONE_FX : &"Channel 1 FX",
    E_AUDIO_BUSSES.CHANNEL_ONE_INPUT : &"Channel 1 Input",
    E_AUDIO_BUSSES.CHANNEL_TWO_FX : &"Channel 2 FX",
    E_AUDIO_BUSSES.CHANNEL_TWO_INPUT : &"Channel 2 Input",
    E_AUDIO_BUSSES.CHANNEL_THREE_FX : &"Channel 3 FX",
    E_AUDIO_BUSSES.CHANNEL_THREE_INPUT : &"Channel 3 Input",
    E_AUDIO_BUSSES.CHANNEL_FOUR_FX : &"Channel 4 FX",
    E_AUDIO_BUSSES.CHANNEL_FOUR_INPUT : &"Channel 4 Input",
}

enum EFFECTS_ORDER
{
    TRIM,           # Slot 0: AudioEffectAmplify
    EQ_HIGH,        # Slot 1: AudioEffectEQ6 band 5 (10000 Hz)
    EQ_MID,         # Slot 1: AudioEffectEQ6 band 3 (1000 Hz)
    EQ_LOW,         # Slot 1: AudioEffectEQ6 band 0 (32 Hz)
    SOUND_COLOR_FX, # Slot 2: AudioEffectLowPassFilter
}

const EQ6_BAND_LOW : int = 0    # 32 Hz
const EQ6_BAND_MID : int = 3    # 1000 Hz
const EQ6_BAND_HIGH :int = 5    # 10000 Hz

const TRIM_DB_NEUTRAL : float   = 0.0 # 0.5
const TRIM_DB_MIN : float       = -24.0   # knob 0.0
const TRIM_DB_MAX : float       = 12.0    # knob 1.0

const EQ_DB_NEUTRAL : float     = 0.0 # 0.5
const EQ_DB_MIN : float         = -12.0     # knob 0.0 (cut)
const EQ_DB_MAX : float         = 12.0      # knob 1.0 (boost)


const SOUND_COLOR_CUTOFF_OPEN_HZ : float    = 20000.0   # "0" position = no filter (full pass)
const SOUND_COLOR_CUTOFF_CLOSED_HZ : float  = 20.0    # full clockwise = dark
const SOUND_COLOR_RESONANCE_NEUTRAL : float = 0.0    # no resonance at neutral


# Beat FX set (Tribe XR Online FLX4 reference + extra native Godot effects). Order = FX SELECT.
# FLX4/rekordbox/Serato: typically ONE Beat FX active at a time (FX SELECT). Some software allows stacking.
enum E_BEAT_FX_TYPE
{
    # Core
    FILTER,     # AudioEffectHighPassFilter — opposite of channel CFX (low-pass); this one cuts lows
    DELAY,      # AudioEffectDelay
    ECHO,       # AudioEffectDelay  - same same, but diffeeereeennnttt... different params)
    REVERB,     # AudioEffectReverb
    TRANS,      # AudioEffectDelay - short tap 50–200 ms + feedback for stutter/transition
    FLANGER,    # AudioEffectChorus
    PHASER,     # AudioEffectPhaser
    PITCH,      # AudioEffectPitchShift
    # Extras :) Thanks godot!
    CRUSH,      # AudioEffectDistortion (MODE_LOFI)
    COMPRESSOR, # AudioEffectCompressor
    LIMITER,    # AudioEffectLimiter
    BAND_PASS,  # AudioEffectBandPassFilter
    PANNER,     # AudioEffectPanner
    STEREO_ENHANCE, # AudioEffectStereoEnhance
    DISTORTION, # AudioEffectDistortion (drive/overdrive)
}

# ---- Beat FX: single vs multiple, and active state ---

@export var single_effect_at_a_time: bool = true # FLX4 style (one FX at a time) or allow stacking (AWFUL PERFORMANCE)?
const BEAT_FX_SLOT_SINGLE: int = 3  # When 1 FX at once, only this slot is used (0=trim, 1=eq, 2=lowpass)

var active_effects_Channel_1 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled
var active_effects_Channel_2 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled
var active_effects_Channel_3 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled
var active_effects_Channel_4 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled


static func Get_Channel_Index(Which_Bus : E_AUDIO_BUSSES) -> int:
    return AudioServer.get_bus_index(BUS_NAMES[Which_Bus])

# THESE EFFECTS DERIVE FROM AudioEffect BUT WE CAN'T RETURN?? CURSE YOU GDSCRIPT 
static func get_beat_fx_class(fx_type: E_BEAT_FX_TYPE) -> Variant:
    match fx_type:
        E_BEAT_FX_TYPE.FILTER:
            return AudioEffectHighPassFilter
        E_BEAT_FX_TYPE.DELAY, E_BEAT_FX_TYPE.ECHO, E_BEAT_FX_TYPE.TRANS:
            return AudioEffectDelay
        E_BEAT_FX_TYPE.REVERB:
            return AudioEffectReverb
        E_BEAT_FX_TYPE.FLANGER:
            return AudioEffectChorus
        E_BEAT_FX_TYPE.PHASER:
            return AudioEffectPhaser
        E_BEAT_FX_TYPE.PITCH:
            return AudioEffectPitchShift
        E_BEAT_FX_TYPE.CRUSH, E_BEAT_FX_TYPE.DISTORTION:
            return AudioEffectDistortion
        E_BEAT_FX_TYPE.COMPRESSOR:
            return AudioEffectCompressor
        E_BEAT_FX_TYPE.LIMITER:
            return AudioEffectLimiter
        E_BEAT_FX_TYPE.BAND_PASS:
            return AudioEffectBandPassFilter
        E_BEAT_FX_TYPE.PANNER:
            return AudioEffectPanner
        E_BEAT_FX_TYPE.STEREO_ENHANCE:
            return AudioEffectStereoEnhance
        _:
            return null

static var BUS_Manager_Instance : BUS_MANAGER = null

func _ready() -> void:
    if BUS_Manager_Instance == null:
        BUS_Manager_Instance = self
    else:
        push_warning("Yo... you silly goose! we already have a bus manager??")


func _get_bus_index_for_channel_fx(channel: int) -> int:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_enum: E_AUDIO_BUSSES
    match channel:
        0: bus_enum = E_AUDIO_BUSSES.CHANNEL_ONE_FX
        1: bus_enum = E_AUDIO_BUSSES.CHANNEL_TWO_FX
        2: bus_enum = E_AUDIO_BUSSES.CHANNEL_THREE_FX
        3: bus_enum = E_AUDIO_BUSSES.CHANNEL_FOUR_FX
        _: return -1
    if not BUS_NAMES.has(bus_enum):
        return -1
    return AudioServer.get_bus_index(BUS_NAMES[bus_enum])


func _get_active_effects_for_channel(channel: int) -> Dictionary:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    match channel:
        0: return active_effects_Channel_1
        1: return active_effects_Channel_2
        2: return active_effects_Channel_3
        3: return active_effects_Channel_4
        _: return {}


func _get_next_free_slot(bus_index: int, channel: int) -> int:
    var used: Array[int] = []
    var d: Dictionary = _get_active_effects_for_channel(channel)
    for slot in d.values():
        if slot >= BEAT_FX_SLOT_SINGLE:
            used.append(slot)
    var slot: int = BEAT_FX_SLOT_SINGLE
    while slot in used:
        slot += 1
    return slot


func _create_beat_fx_instance(fx_type: E_BEAT_FX_TYPE) -> AudioEffect:
    var new_fx: Variant = get_beat_fx_class(fx_type) # GDSCRIPT DOESN'T ACCEPT AudioEffect AS VALID SET... need to use horrible Varient
    if new_fx == null:
        return null
    var effect: AudioEffect = new_fx.new()
    if effect is AudioEffectDistortion and fx_type == E_BEAT_FX_TYPE.CRUSH:
        (effect as AudioEffectDistortion).mode = AudioEffectDistortion.MODE_LOFI
    return effect


func add_beat_fx(fx_type: E_BEAT_FX_TYPE, channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_index: int = _get_bus_index_for_channel_fx(channel)
    if bus_index < 0:
        return
    var active : Dictionary = _get_active_effects_for_channel(channel)
        
    if single_effect_at_a_time:
        # Only slot 3's used... replace whats is there.
        if active.size() > 0:
            var existing_slot: int = active.values()[0]
            AudioServer.remove_bus_effect(bus_index, existing_slot)
            active.clear()
        var effect: AudioEffect = _create_beat_fx_instance(fx_type)
        if effect != null:
            AudioServer.add_bus_effect(bus_index, effect, BEAT_FX_SLOT_SINGLE)
            AudioServer.set_bus_effect_enabled(bus_index, BEAT_FX_SLOT_SINGLE, true)
            active[fx_type] = BEAT_FX_SLOT_SINGLE
    else:
        # Multiple: set next free slot and add effect there and oray
        if active.has(fx_type):
            return  # already on
        var slot: int = _get_next_free_slot(bus_index, channel)
        var effect: AudioEffect = _create_beat_fx_instance(fx_type)
        if effect != null:
            AudioServer.add_bus_effect(bus_index, effect, slot)
            AudioServer.set_bus_effect_enabled(bus_index, slot, true)
            active[fx_type] = slot


func remove_beat_fx(fx_type: E_BEAT_FX_TYPE, channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_index: int = _get_bus_index_for_channel_fx(channel)
    if bus_index < 0:
        return
    var active: Dictionary = _get_active_effects_for_channel(channel)
    if not active.has(fx_type):
        return
    var slot: int = active[fx_type]
    active.erase(fx_type)
    var count: int = AudioServer.get_bus_effect_count(bus_index)
    if slot < count:
        AudioServer.remove_bus_effect(bus_index, slot)
        # Indices after slot shifted down by 1
        for k in active.keys():
            if active[k] > slot:
                active[k] = active[k] - 1


func toggle_beat_fx(fx_type: E_BEAT_FX_TYPE, channel : int) -> void:
    if is_beat_fx_active(fx_type, channel):
        remove_beat_fx(fx_type, channel)
    else:
        add_beat_fx(fx_type, channel)


func is_beat_fx_active(fx_type: E_BEAT_FX_TYPE, channel : int) -> bool:
    return _get_active_effects_for_channel(channel).has(fx_type)


# Thank you ChatGPT for automating this horriblness: add/remove by name (for LibreBox_Manager button handlers)
func add_filter_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.FILTER, channel)
func add_delay_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.DELAY, channel)
func add_echo_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.ECHO, channel)
func add_reverb_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.REVERB, channel)
func add_trans_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.TRANS, channel)
func add_flanger_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.FLANGER, channel)
func add_phaser_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.PHASER, channel)
func add_pitch_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.PITCH, channel)
func add_crush_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.CRUSH, channel)
func add_compressor_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.COMPRESSOR, channel)
func add_limiter_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.LIMITER, channel)
func add_band_pass_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.BAND_PASS, channel)
func add_panner_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.PANNER, channel)
func add_stereo_enhance_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.STEREO_ENHANCE, channel)
func add_distortion_effect(channel : int) -> void:
    add_beat_fx(E_BEAT_FX_TYPE.DISTORTION, channel)

func remove_filter_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.FILTER, channel)
func remove_delay_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.DELAY, channel)
func remove_echo_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.ECHO, channel)
func remove_reverb_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.REVERB, channel)
func remove_trans_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.TRANS, channel)
func remove_flanger_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.FLANGER, channel)
func remove_phaser_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.PHASER, channel)
func remove_pitch_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.PITCH, channel)
func remove_crush_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.CRUSH, channel)
func remove_compressor_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.COMPRESSOR, channel)
func remove_limiter_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.LIMITER, channel)
func remove_band_pass_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.BAND_PASS, channel)
func remove_panner_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.PANNER, channel)
func remove_stereo_enhance_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.STEREO_ENHANCE, channel)
func remove_distortion_effect(channel : int) -> void:
    remove_beat_fx(E_BEAT_FX_TYPE.DISTORTION, channel)
