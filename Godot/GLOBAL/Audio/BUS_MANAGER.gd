extends Node
class_name BUS_MANAGER


# ---- Beat FX: single vs multiple, and active state ---
static var ONE_FX_AT_A_TIME: bool = true # FLX4 style (one FX at a time) or allow stacking (AWFUL PERFORMANCE)?

static func Allow_Multiple_FX_at_same_time() -> bool:
    return ONE_FX_AT_A_TIME == false
    
    
static func Set_Allow_Multiple_FX_at_same_time(enabled : bool):
    ONE_FX_AT_A_TIME = not enabled
    
    
## false means we cant do multiple FX at the same time now 
static func Toggle_Allow_Multiple_FX_at_same_time() -> bool:
    ONE_FX_AT_A_TIME = not ONE_FX_AT_A_TIME
    return not ONE_FX_AT_A_TIME
    
    
enum E_Track_FX_Policy
{
    FX_Disabled,
    Only_Track_1,
    Only_Track_2,
    Both_Tracks,
}
    
static var CURRENT_TRACK_FX_POLICY : E_Track_FX_Policy = E_Track_FX_Policy.FX_Disabled

static func Can_Track_1_Take_FX() -> bool:
    return CURRENT_TRACK_FX_POLICY in [E_Track_FX_Policy.Only_Track_1, E_Track_FX_Policy.Both_Tracks]

static func Can_Track_2_Take_FX() -> bool:
    return CURRENT_TRACK_FX_POLICY in [E_Track_FX_Policy.Only_Track_2, E_Track_FX_Policy.Both_Tracks]


static func Set_Track_1_can_take_FX(enabled:bool):
    if CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Both_Tracks and not enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Only_Track_2
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Only_Track_2 and enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Both_Tracks
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Only_Track_1 and not enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.FX_Disabled
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.FX_Disabled and enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Only_Track_1
    print("FX Policy is now " + str(CURRENT_TRACK_FX_POLICY))

static func Set_Track_2_can_take_FX(enabled:bool):
    if CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Both_Tracks and not enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Only_Track_1
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Only_Track_1 and enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Both_Tracks
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.Only_Track_2 and not enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.FX_Disabled
    elif CURRENT_TRACK_FX_POLICY == E_Track_FX_Policy.FX_Disabled and enabled:
        CURRENT_TRACK_FX_POLICY = E_Track_FX_Policy.Only_Track_2
    print("FX Policy is now " + str(CURRENT_TRACK_FX_POLICY))
        


static var active_effects_Channel_1 : Dictionary[E_BEAT_FX_TYPE, int] = {} # the int is the INDEX of that effect on a bus, an index of -1 means the effect is inactive / disabled
static var active_effects_Channel_2 : Dictionary[E_BEAT_FX_TYPE, int] = {}
#var active_effects_Channel_3 : Dictionary[E_BEAT_FX_TYPE, int] = {}
#var active_effects_Channel_4 : Dictionary[E_BEAT_FX_TYPE, int] = {}
static var _pitch_shift_scale_override_by_channel: Array[float] = [-1.0, -1.0, -1.0, -1.0]


const CFX_LOWPASS_SLOT : int = 2
const CFX_HIGHPASS_SLOT : int = 3
const BEAT_FX_SLOT_SINGLE: int = 4  # When 1 FX at once, only this slot is used (0=trim, 1=eq, 2=lowpass, 3=highpass)

# do NOT mess with this order... unless you change Main Audio Bus Layout.tres
enum E_AUDIO_BUSSES
{
    MASTER,
    #MIXER,
    #MICROPHONE_FX,
    MICROPHONE_INPUT,
    #CHANNEL_ONE_FX,
    CHANNEL_ONE_INPUT,
    #CHANNEL_TWO_FX,
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

const Beat_FX_Names : Dictionary[E_BEAT_FX_TYPE, String] = {
    E_BEAT_FX_TYPE.DELAY : "DELAY",
    E_BEAT_FX_TYPE.ECHO : "ECHO",
    E_BEAT_FX_TYPE.REVERB : "REVERB",
    E_BEAT_FX_TYPE.TRANS : "TRANS",
    E_BEAT_FX_TYPE.FLANGER : "FLANGER",
    E_BEAT_FX_TYPE.PHASER : "PHASER",
    E_BEAT_FX_TYPE.PITCH : "PITCH",
    E_BEAT_FX_TYPE.CRUSH : "CRUSH",
    E_BEAT_FX_TYPE.COMPRESSOR : "COMPRESSOR",
    E_BEAT_FX_TYPE.LIMITER : "LIMITER",
    E_BEAT_FX_TYPE.BAND_PASS : "BAND PASS",
    E_BEAT_FX_TYPE.PANNER : "PANNER",
    E_BEAT_FX_TYPE.STEREO_ENHANCE : "STEREO ENHANCE",
    E_BEAT_FX_TYPE.DISTORTION : "DISTORTION",
}

## Translation CSV keys (see Language/LANG_Translation.csv).
const Beat_FX_Translation_Keys: Dictionary[E_BEAT_FX_TYPE, String] = {
    E_BEAT_FX_TYPE.DELAY: "KEY_FX_DELAY",
    E_BEAT_FX_TYPE.ECHO: "KEY_FX_ECHO",
    E_BEAT_FX_TYPE.REVERB: "KEY_FX_REVERB",
    E_BEAT_FX_TYPE.TRANS: "KEY_FX_TRANS",
    E_BEAT_FX_TYPE.FLANGER: "KEY_FX_FLANGER",
    E_BEAT_FX_TYPE.PHASER: "KEY_FX_PHASER",
    E_BEAT_FX_TYPE.PITCH: "KEY_FX_PITCH",
    E_BEAT_FX_TYPE.CRUSH: "KEY_FX_CRUSH",
    E_BEAT_FX_TYPE.COMPRESSOR: "KEY_FX_COMPRESSOR",
    E_BEAT_FX_TYPE.LIMITER: "KEY_FX_LIMITER",
    E_BEAT_FX_TYPE.BAND_PASS: "KEY_FX_BAND_PASS",
    E_BEAT_FX_TYPE.PANNER: "KEY_FX_PANNER",
    E_BEAT_FX_TYPE.STEREO_ENHANCE: "KEY_FX_STEREO_ENHANCE",
    E_BEAT_FX_TYPE.DISTORTION: "KEY_FX_DISTORTION",
}


static func beat_fx_translation_key(fx: E_BEAT_FX_TYPE) -> String:
    return Beat_FX_Translation_Keys.get(fx, "KEY_FX_DELAY")


static func Set_Pitch_Shift_Semitone_Override(channel: int, semitones: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var scale: float = pow(2.0, float(semitones) / 12.0)
    _pitch_shift_scale_override_by_channel[channel] = scale


static func Clear_Pitch_Shift_Semitone_Override(channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    _pitch_shift_scale_override_by_channel[channel] = -1.0


static func _get_pitch_shift_scale_override(channel: int) -> float:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    if channel < 0 or channel >= _pitch_shift_scale_override_by_channel.size():
        return -1.0
    return _pitch_shift_scale_override_by_channel[channel]


    
    

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



# Same thing as Calculate_Weights_Normal, except returns raw dB values for each EQ6 band.
# Input is still low/mid/high alpha (0-1), which is remapped to EQ_DB_MIN...EQ_DB_MAX first.
static func Calculate_Weights_DB(low_alpha : float = 0.5, mid_alpha : float = 0.5, high_alpha : float = 0.5) -> Dictionary[E_BAND_HZ, float]:
    low_alpha = remap(low_alpha, 0.0, 1.0, 0.0, 2.0)
    mid_alpha = remap(mid_alpha, 0.0, 1.0, 0.0, 2.0)
    high_alpha = remap(high_alpha, 0.0, 1.0, 0.0, 2.0)
    
    var low_db : float =    clampf(linear_to_db(low_alpha), BUS_MANAGER.EQ_DB_MIN, BUS_MANAGER.EQ_DB_MAX)
    var mid_db : float =    clampf(linear_to_db(mid_alpha), BUS_MANAGER.EQ_DB_MIN, BUS_MANAGER.EQ_DB_MAX)
    var high_db : float =   clampf(linear_to_db(high_alpha), BUS_MANAGER.EQ_DB_MIN, BUS_MANAGER.EQ_DB_MAX)
    
    var new_band_dbs : Dictionary[E_BAND_HZ, float] = {}
    for band in E_BAND_HZ.values():
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
static func _get_next_free_slot(channel: int) -> int:
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


static func _create_beat_fx_instance(fx_type: E_BEAT_FX_TYPE) -> AudioEffect:
    var new_fx : Variant = get_beat_fx_class(fx_type) # GDSCRIPT DOESN'T ACCEPT AudioEffect AS VALID SET... need to use horrible Varient
    if new_fx == null:
        return null
    var effect: AudioEffect = new_fx.new()
    if effect is AudioEffectDistortion and fx_type == E_BEAT_FX_TYPE.CRUSH:
        (effect as AudioEffectDistortion).mode = AudioEffectDistortion.MODE_LOFI
    return effect


static func add_beat_fx(fx_type: E_BEAT_FX_TYPE, channel: int) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    var bus_index: int = Get_Channel_Index_i(channel)
    if bus_index < 0:
        return
    var active_fx : Dictionary = _get_active_effects_for_channel(channel)
        
    if ONE_FX_AT_A_TIME:
        # Only slot 4's used... replace whats is there.
        if AudioServer.get_bus_effect_count(bus_index) > BEAT_FX_SLOT_SINGLE:
            AudioServer.remove_bus_effect(bus_index, BEAT_FX_SLOT_SINGLE )
            active_fx.clear()
        var effect: AudioEffect = _create_beat_fx_instance(fx_type)
        if effect != null:
            AudioServer.add_bus_effect(bus_index, effect, BEAT_FX_SLOT_SINGLE)
            AudioServer.set_bus_effect_enabled(bus_index, BEAT_FX_SLOT_SINGLE, true)
            active_fx[fx_type] = BEAT_FX_SLOT_SINGLE
    else:
        # Multiple: set next free slot and add effect there and pray
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


static func toggle_beat_fx(fx_type: E_BEAT_FX_TYPE, channel : int) -> void:
    if is_beat_fx_active(fx_type, channel):
        remove_beat_fx(fx_type, channel)
    else:
        add_beat_fx(fx_type, channel)


static func is_beat_fx_active(fx_type: E_BEAT_FX_TYPE, channel : int) -> bool:
    return _get_active_effects_for_channel(channel).has(fx_type)


## Beat FX "power" knob: alpha 0 = no audible effect (like off), alpha 1 = full effect. Call every frame from Controller.
static func Apply_Beat_FX_Level(channel: int, alpha: float) -> void:
    channel = Utility.Clamp_to_Valid_TrackID(channel)
    alpha = clampf(alpha, 0.0, 1.0)
    var bus_index: int = Get_Channel_Index_i(channel)
    if bus_index < 0:
        return
    var active_fx: Dictionary = _get_active_effects_for_channel(channel)
    for fx_type in active_fx:
        var slot: int = active_fx[fx_type]
        if slot >= AudioServer.get_bus_effect_count(bus_index):
            continue
        var effect: AudioEffect = AudioServer.get_bus_effect(bus_index, slot)
        if effect != null:
            _set_beat_fx_effect_level(effect, fx_type, alpha, channel)


## Per-effect "amount" so that alpha 0 = inaudible, alpha 1 = full. Effect-specific parameter scaling.
static func _set_beat_fx_effect_level(effect: AudioEffect, fx_type: E_BEAT_FX_TYPE, alpha: float, channel: int = 0) -> void:
    alpha = clampf(alpha, 0.0, 1.0)
    if effect is AudioEffectDelay:
        var d: AudioEffectDelay = effect as AudioEffectDelay
        var db_off: float = -80.0
        d.tap1_level_db = lerpf(db_off, 0.0, alpha)
        d.tap2_level_db = lerpf(db_off, -6.0, alpha)
        d.feedback_level_db = lerpf(db_off, -6.0, alpha)
    elif effect is AudioEffectReverb:
        var r: AudioEffectReverb = effect as AudioEffectReverb
        r.dry = 1.0 - alpha
        r.wet = alpha
    elif effect is AudioEffectChorus:
        var c: AudioEffectChorus = effect as AudioEffectChorus
        for i in range(c.voice_count):
            c.set_voice_depth_ms(i, lerpf(0.0, 3.0, alpha))
            c.set_voice_level_db(i, lerpf(-80.0, 0.0, alpha))
    elif effect is AudioEffectPhaser:
        var p: AudioEffectPhaser = effect as AudioEffectPhaser
        p.depth = lerpf(0.0, 1.0, alpha)
    elif effect is AudioEffectPitchShift:
        var ps: AudioEffectPitchShift = effect as AudioEffectPitchShift
        var override_scale: float = _get_pitch_shift_scale_override(channel)
        ps.pitch_scale = override_scale if override_scale > 0.0 else lerpf(1.0, 1.5, alpha)
    elif effect is AudioEffectDistortion:
        var dist: AudioEffectDistortion = effect as AudioEffectDistortion
        dist.drive = lerpf(0.0, 1.0, alpha)
    elif effect is AudioEffectCompressor:
        var comp: AudioEffectCompressor = effect as AudioEffectCompressor
        comp.ratio = lerpf(1.0, 4.0, alpha)
    elif effect is AudioEffectLimiter:
        var lim: AudioEffectLimiter = effect as AudioEffectLimiter
        lim.threshold_db = lerpf(6.0, -12.0, alpha)
    elif effect is AudioEffectBandPassFilter:
        var bp: AudioEffectBandPassFilter = effect as AudioEffectBandPassFilter
        bp.resonance = lerpf(0.1, 2.0, alpha)
    elif effect is AudioEffectPanner:
        var pan: AudioEffectPanner = effect as AudioEffectPanner
        pan.pan = lerpf(0.0, 1.0, alpha)
    elif effect is AudioEffectStereoEnhance:
        var se: AudioEffectStereoEnhance = effect as AudioEffectStereoEnhance
        se.pan_pullout = lerpf(0.0, 1.0, alpha)
