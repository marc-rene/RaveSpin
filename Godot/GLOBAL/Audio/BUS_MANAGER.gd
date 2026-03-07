extends Node
class_name BUS_MANAGER



# do NOT mess with this order... unless you change Main Audio Bus Layout.tres
enum E_AUDIO_BUSSES
{
    MASTER,
    #MIXER,
    #MICROPHONE_FX,
    MICROPHONE_INPUT,
    CHANNEL_ONE_FX,
    CHANNEL_ONE_INPUT,
    CHANNEL_TWO_FX,
    CHANNEL_TWO_INPUT,
    #CHANNEL_THREE_FX,
    CHANNEL_THREE_INPUT,
    #CHANNEL_FOUR_FX,
    CHANNEL_FOUR_INPUT,
}

# NEVER add effects to raw imput... MAYBE amplify but thats it
const BUS_NAMES : Dictionary[E_AUDIO_BUSSES, StringName] = {
    E_AUDIO_BUSSES.MASTER : &"Master",
    #E_AUDIO_BUSSES.MIXER : &"Main Mixer",
    #E_AUDIO_BUSSES.MICROPHONE_FX : &"Microphone FX",
    E_AUDIO_BUSSES.MICROPHONE_INPUT : &"Microphone Input",
    #E_AUDIO_BUSSES.CHANNEL_ONE_FX : &"Channel 1 FX",
    E_AUDIO_BUSSES.CHANNEL_ONE_INPUT : &"Channel 1 Input",
    #E_AUDIO_BUSSES.CHANNEL_TWO_FX : &"Channel 2 FX",
    E_AUDIO_BUSSES.CHANNEL_TWO_INPUT : &"Channel 2 Input",
    #E_AUDIO_BUSSES.CHANNEL_THREE_FX : &"Channel 3 FX",
    E_AUDIO_BUSSES.CHANNEL_THREE_INPUT : &"Channel 3 Input",
    #E_AUDIO_BUSSES.CHANNEL_FOUR_FX : &"Channel 4 FX",
    E_AUDIO_BUSSES.CHANNEL_FOUR_INPUT : &"Channel 4 Input",
}

enum E_CORE_EFFECTS_ORDER
{
    TRIM,           # Slot 0: AudioEffectAmplify
    EQ_HIGH,        # Slot 1: AudioEffectEQ6 band 5 (10000 Hz)
    EQ_MID,         # Slot 1: AudioEffectEQ6 band 3 (1000 Hz)
    EQ_LOW,         # Slot 1: AudioEffectEQ6 band 0 (32 Hz)
    SOUND_COLOR_FX, # Slot 2: Low pass filter THEN high pass filter
}

# Im explicitingly setting the int values cause I want to make sure that band[0] IS 32hz
enum E_BAND_HZ
{
    HZ_32       = 0,
    HZ_100      = 1,
    HZ_320      = 2,
    HZ_1000     = 3,
    HZ_3200     = 4,
    HZ_10000    = 5,
}

const TRIM_DB_NEUTRAL : float   = 0.0 # 0.5
const TRIM_DB_MIN : float       = -24.0   # knob 0.0
const TRIM_DB_MAX : float       = 24.0    # knob 1.0

const EQ_DB_NEUTRAL : float     = 0.0 # 0.5
const EQ_DB_MIN : float         = -60.0     # knob 0.0 (cut)
const EQ_DB_MAX : float         = 24.0      # knob 1.0 (boost)

const CFX_CUTOFF_CLOSED_HZ : float = 100.0   # dark / bass-only
const CFX_CUTOFF_OPEN_HZ   : float = 22000.0 # full range (no filter at 0.5)

# So EQ bands are made up of 6+ different freqs bands, but we only have "high" "mid" "low"
# each knob will have different weights for how they affect the other hz
# these weights are pulled out of thin air / chatgpt
const EQ6_LOW_WEIGHTS : Dictionary[E_BAND_HZ, float] = { 
    E_BAND_HZ.HZ_32 : 1.0, 
    E_BAND_HZ.HZ_100 : 0.8,
    E_BAND_HZ.HZ_320 : 0.3,
    E_BAND_HZ.HZ_1000 : 0.0,
    E_BAND_HZ.HZ_3200 : 0.0,
    E_BAND_HZ.HZ_10000 : 0.0
    }

const EQ6_MID_WEIGHTS : Dictionary[E_BAND_HZ, float] = {
    E_BAND_HZ.HZ_32 : 0.0,
    E_BAND_HZ.HZ_100 : 0.2,
    E_BAND_HZ.HZ_320 : 0.7,
    E_BAND_HZ.HZ_1000 : 1.0,
    E_BAND_HZ.HZ_3200 : 0.4,
    E_BAND_HZ.HZ_10000 : 0.0
}

const EQ6_HIGH_WEIGHTS : Dictionary[E_BAND_HZ, float] = {
    E_BAND_HZ.HZ_32 : 0.0,
    E_BAND_HZ.HZ_100 : 0.0,
    E_BAND_HZ.HZ_320 : 0.0,
    E_BAND_HZ.HZ_1000 : 0.0,
    E_BAND_HZ.HZ_3200 : 0.6,
    E_BAND_HZ.HZ_10000 : 1.0
}

# So Give me the low, mid, hi alpha floats (0-1) and then spit out a dictionary of the new HZ but in 0-1 form
static func Calculate_Weights_Normal(low_alpha : float = 0.5, mid_alpha : float = 0.5, high_alpha : float = 0.5) -> Dictionary[E_BAND_HZ, float]:
    low_alpha = clampf(low_alpha, 0.0, 1.0)
    mid_alpha = clampf(mid_alpha, 0.0, 1.0)
    high_alpha = clampf(high_alpha, 0.0, 1.0)
    
    var new_weights : Dictionary[E_BAND_HZ, float] = {}
    for band in E_BAND_HZ.values():
        var weighted_alpha : float = (
            low_alpha * EQ6_LOW_WEIGHTS[band] +
            mid_alpha * EQ6_MID_WEIGHTS[band] +
            high_alpha * EQ6_HIGH_WEIGHTS[band]
        )
        new_weights[band] = clampf(weighted_alpha, 0.0, 1.0)
    
    return new_weights
    
    

# Beat FX set (Tribe XR Online FLX4 reference + extra native Godot effects). Order = FX SELECT.
# FLX4/rekordbox/Serato: typically ONE Beat FX active at a time (FX SELECT). Some software allows stacking.
enum E_BEAT_FX_TYPE
{
    # Core
    DELAY,      # AudioEffectDelay
    ECHO,       # AudioEffectDelay  - same same, but diffeeereeennnttt... different params)
    REVERB,     # AudioEffectReverb
    TRANS,      # AudioEffectDelay - short tap like 50-200 ms + feedback for stutter/transition
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
@export var ONE_FX_AT_A_TIME: bool = true # FLX4 style (one FX at a time) or allow stacking (AWFUL PERFORMANCE)?

static var active_effects_Channel_1 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled
static var active_effects_Channel_2 : Dictionary[E_BEAT_FX_TYPE, int] = {}
#var active_effects_Channel_3 : Dictionary[E_BEAT_FX_TYPE, int] = {}
#var active_effects_Channel_4 : Dictionary[E_BEAT_FX_TYPE, int] = {}


const CFX_LOWPASS_SLOT : int = 2
const CFX_HIGHPASS_SLOT : int = 3
const BEAT_FX_SLOT_SINGLE: int = 4  # When 1 FX at once, only this slot is used (0=trim, 1=eq, 2=lowpass, 3=highpass)



# Same thing as Calculate_Weights_Normal, except returns raw dB values for each EQ6 band.
# Input is still low/mid/high alpha (0-1), which is remapped to EQ_DB_MIN...EQ_DB_MAX first.
static func Calculate_Weights_DB(low_alpha : float = 0.5, mid_alpha : float = 0.5, high_alpha : float = 0.5) -> Dictionary[E_BAND_HZ, float]:
    low_alpha = clampf(low_alpha, 0.0, 1.0)
    mid_alpha = clampf(mid_alpha, 0.0, 1.0)
    high_alpha = clampf(high_alpha, 0.0, 1.0)
    
    var low_db : float = remap(low_alpha, 0.0, 1.0, EQ_DB_MIN, EQ_DB_MAX)
    var mid_db : float = remap(mid_alpha, 0.0, 1.0, EQ_DB_MIN, EQ_DB_MAX)
    var high_db : float = remap(high_alpha, 0.0, 1.0, EQ_DB_MIN, EQ_DB_MAX)
    
    var new_band_dbs : Dictionary[E_BAND_HZ, float] = {}
    for band in E_BAND_HZ:
        var band_db : float = (
            low_db * EQ6_LOW_WEIGHTS[band] +
            mid_db * EQ6_MID_WEIGHTS[band] +
            high_db * EQ6_HIGH_WEIGHTS[band]
        )
        new_band_dbs[band] = clampf(band_db, EQ_DB_MIN, EQ_DB_MAX)
    
    return new_band_dbs







static func Get_Channel_Index_e(Which_Bus : E_AUDIO_BUSSES) -> int:
    return AudioServer.get_bus_index(BUS_NAMES[Which_Bus])


static func Get_Channel_Index_i(Which_Channel : int) -> int:
    var temp_channel_bus : E_AUDIO_BUSSES
    temp_channel_bus = E_AUDIO_BUSSES.CHANNEL_ONE_INPUT if Which_Channel == 0 else E_AUDIO_BUSSES.CHANNEL_TWO_INPUT
    return AudioServer.get_bus_index(BUS_NAMES[temp_channel_bus])


# THESE EFFECTS DERIVE FROM AudioEffect BUT WE CAN'T RETURN?? CURSE YOU GDSCRIPT 
static func get_beat_fx_class(fx_type: E_BEAT_FX_TYPE) -> Variant:
    match fx_type:
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





static func _get_active_effects_for_channel(channel: int) -> Dictionary[E_BEAT_FX_TYPE, int]:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    match channel:
        0: return active_effects_Channel_1
        1: return active_effects_Channel_2
        _: return {}


## whats the next free slot in our bus for us to add an FX? get the index of that slot
func _get_next_free_slot(channel: int) -> int:
    if ONE_FX_AT_A_TIME:
        return BEAT_FX_SLOT_SINGLE
        
    var used: Array[int] = []
    for slot in _get_active_effects_for_channel(channel).values():
        if slot >= BEAT_FX_SLOT_SINGLE:
            used.append(slot)
    var slot: int = BEAT_FX_SLOT_SINGLE
    while slot in used:
        slot += 1
    return slot


func _create_beat_fx_instance(fx_type: E_BEAT_FX_TYPE) -> AudioEffect:
    var new_fx : Variant = get_beat_fx_class(fx_type) # GDSCRIPT DOESN'T ACCEPT AudioEffect AS VALID SET... need to use horrible Varient
    if new_fx == null:
        return null
    var effect: AudioEffect = new_fx.new()
    if effect is AudioEffectDistortion and fx_type == E_BEAT_FX_TYPE.CRUSH:
        (effect as AudioEffectDistortion).mode = AudioEffectDistortion.MODE_LOFI
    return effect


func add_beat_fx(fx_type: E_BEAT_FX_TYPE, channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_index: int = Get_Channel_Index_i(channel)
    if bus_index < 0:
        return
    var active_fx : Dictionary = _get_active_effects_for_channel(channel)
        
    if ONE_FX_AT_A_TIME:
        # Only slot 3's used... replace whats is there.
        if active_fx.size() > 0:
            var existing_slot: int = active_fx.values()[0]
            AudioServer.remove_bus_effect(bus_index, existing_slot)
            active_fx.clear()
        var effect: AudioEffect = _create_beat_fx_instance(fx_type)
        if effect != null:
            AudioServer.add_bus_effect(bus_index, effect, BEAT_FX_SLOT_SINGLE)
            AudioServer.set_bus_effect_enabled(bus_index, BEAT_FX_SLOT_SINGLE, true)
            active_fx[fx_type] = BEAT_FX_SLOT_SINGLE
    else:
        # Multiple: set next free slot and add effect there and oray
        if active_fx.has(fx_type):
            return  # already on
        var slot: int = _get_next_free_slot(channel)
        var effect: AudioEffect = _create_beat_fx_instance(fx_type)
        if effect:
            AudioServer.add_bus_effect(bus_index, effect, slot)
            AudioServer.set_bus_effect_enabled(bus_index, slot, true)
            active_fx[fx_type] = slot


static func remove_beat_fx(fx_type: E_BEAT_FX_TYPE, channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_index: int = Get_Channel_Index_i(channel)
    if bus_index < 0:
        return
    var active_fx: Dictionary = _get_active_effects_for_channel(channel)
    if active_fx.has(fx_type) == false:
        return
    var slot: int = active_fx[fx_type]
    active_fx.erase(fx_type)
    var fx_count: int = AudioServer.get_bus_effect_count(bus_index)
    if slot < fx_count:
        AudioServer.remove_bus_effect(bus_index, slot)
        # Indices after slot shifted down by 1
        for fx_key in active_fx.keys():
            if active_fx[fx_key] > slot:
                active_fx[fx_key] = active_fx[fx_key] - 1


func toggle_beat_fx(fx_type: E_BEAT_FX_TYPE, channel : int) -> void:
    if is_beat_fx_active(fx_type, channel):
        remove_beat_fx(fx_type, channel)
    else:
        add_beat_fx(fx_type, channel)


func is_beat_fx_active(fx_type: E_BEAT_FX_TYPE, channel : int) -> bool:
    return _get_active_effects_for_channel(channel).has(fx_type)


# Thank you ChatGPT for automating this horriblness: add/remove by name (for LibreBox_Manager button handlers)
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
