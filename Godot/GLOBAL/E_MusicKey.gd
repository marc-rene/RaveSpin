@tool
class_name EMusicKey 
extends Object

## Music key value object (note + scale).
## Used by song metadata and key-related DJ features.
var m_note_index : m_notes_enum
var m_scale_index : m_scales_enum
    
const m_notes_str : Array[StringName] = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
    ]


const m_scales_str : Array[StringName] = [ "Unknown",           
"Major",
"Natural Minor",
"Harmonic Minor",
"Melodic Minor",
"Gypsy Minor",
"Neapolitan Minor",
"Hungarian Minor",
"Major Pentatonic",
"Minor Pentatonic",
"Blues",
"Dorian",
"Phrygian",
"Lydian",
"Mixolydian",
"Locrian",
"Chromatic",
"Whole Tone",
"Octatonic",
"Arabic",
];



func GetNote(capitalise = false) -> String:
    return m_notes_str[m_note_index] if capitalise else m_notes_str[m_note_index]


func GetScale(capitalise = false) -> StringName:
    return m_scales_str[m_scale_index] if capitalise else m_scales_str[m_scale_index]


## Compares this key with another key.
func Equals(other_music_key : EMusicKey):
    return  (other_music_key.m_note_index == m_note_index) \
    and     (other_music_key.m_scale_index == m_scale_index) 


## Returns a display string in "NOTE SCALE" format.
func _to_string() -> String:
    return "%s %s" % [GetNote(), GetScale()]


## NOTE: We Don't use flats, only sharps, and please notate as '#'
## A Sharp Major should be {"A#", "Major"}
## Parses note/scale strings into enum values.
func Set_with_String(note = "A", scale = "Major"):

    m_note_index = m_notes_str_to_m_notes_enum(note.to_upper())
    m_scale_index = m_scales_str_to_m_scales_enum(scale.to_upper())



## Creates a key from enum values.
func _init(note : m_notes_enum = m_notes_enum.C, scale : m_scales_enum = m_scales_enum.UNKNOWN):
    m_note_index = note
    m_scale_index = scale


## Helper constructor from enum note + scale.
static func Make_with_Enum(note : m_notes_enum, scale : m_scales_enum) -> EMusicKey:
    var key = EMusicKey
    key.m_note_index = note
    key.m_scale_index = scale
    
    return key


## Parses "NOTE SCALE" text into an `EMusicKey`.
static func String_to_MusicKey(music_key_string : String) -> EMusicKey:
    var split_point = music_key_string.find(" ")
    var note = music_key_string.substr(0, (split_point + 1))
    var scale = music_key_string.substr(split_point)
    
    var NewKey = EMusicKey.new()
    NewKey.Set_with_String(note, scale)
    
    return NewKey
    
    

## Enum version of `m_notes_str`.
enum m_notes_enum {C,                      Cs,                     D,                      
Ds,                     E,                      F,                      
Fs,                     G,                      Gs,                     
A,                      As,                     B,                      
}

## Converts note text to note enum.
## Input should be uppercase note text.

static func m_notes_str_to_m_notes_enum(string_version : String):
    match string_version:
        "C":
            return m_notes_enum.C
        "C#":
            return m_notes_enum.Cs
        "D":
            return m_notes_enum.D
        "D#":
            return m_notes_enum.Ds
        "E":
            return m_notes_enum.E
        "F":
            return m_notes_enum.F
        "F#":
            return m_notes_enum.Fs
        "G":
            return m_notes_enum.G
        "G#":
            return m_notes_enum.Gs
        "A":
            return m_notes_enum.A
        "A#":
            return m_notes_enum.As
        "B":
            return m_notes_enum.B
        _:
            return m_notes_enum.C






### INSERT ENUM VERSION HERE ##

## Enum version of `m_scales_str`.
enum m_scales_enum {UNKNOWN,                MAJOR,                  NATURAL_MINOR,          
HARMONIC_MINOR,         MELODIC_MINOR,          GYPSY_MINOR,            
NEAPOLITAN_MINOR,       HUNGARIAN_MINOR,        MAJOR_PENTATONIC,       
MINOR_PENTATONIC,       BLUES,                  DORIAN,                 
PHRYGIAN,               LYDIAN,                 MIXOLYDIAN,             
LOCRIAN,                CHROMATIC,              WHOLE_TONE,             
OCTATONIC,              ARABIC,                 }
## Converts scale text to scale enum.
## Input should be uppercase scale text.

static func m_scales_str_to_m_scales_enum(string_version : String):
    string_version = string_version.to_upper().strip_edges().strip_escapes()
    match string_version:
        "UNKNOWN":
            return m_scales_enum.UNKNOWN
        "MAJOR":
            return m_scales_enum.MAJOR
        "NATURAL MINOR":
            return m_scales_enum.NATURAL_MINOR
        "HARMONIC MINOR":
            return m_scales_enum.HARMONIC_MINOR
        "MELODIC MINOR":
            return m_scales_enum.MELODIC_MINOR
        "GYPSY MINOR":
            return m_scales_enum.GYPSY_MINOR
        "NEAPOLITAN MINOR":
            return m_scales_enum.NEAPOLITAN_MINOR
        "HUNGARIAN MINOR":
            return m_scales_enum.HUNGARIAN_MINOR
        "MAJOR PENTATONIC":
            return m_scales_enum.MAJOR_PENTATONIC
        "MINOR PENTATONIC":
            return m_scales_enum.MINOR_PENTATONIC
        "BLUES":
            return m_scales_enum.BLUES
        "DORIAN":
            return m_scales_enum.DORIAN
        "PHRYGIAN":
            return m_scales_enum.PHRYGIAN
        "LYDIAN":
            return m_scales_enum.LYDIAN
        "MIXOLYDIAN":
            return m_scales_enum.MIXOLYDIAN
        "LOCRIAN":
            return m_scales_enum.LOCRIAN
        "CHROMATIC":
            return m_scales_enum.CHROMATIC
        "WHOLE TONE":
            return m_scales_enum.WHOLE_TONE
        "OCTATONIC":
            return m_scales_enum.OCTATONIC
        "ARABIC":
            return m_scales_enum.ARABIC
        _:
            return m_scales_enum.UNKNOWN
