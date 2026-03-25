@tool
class_name EMusicKey 
extends Object

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


func Equals(other_music_key : EMusicKey):
    return  (other_music_key.m_note_index == m_note_index) \
    and     (other_music_key.m_scale_index == m_scale_index) 


func _to_string() -> String:
    return "%s %s" % [GetNote(), GetScale()]


## NOTE: We Don't use flats, only sharps, and please notate as '#'
## A Sharp Major should be {"A#", "Major"}
func Set_with_String(note = "A", scale = "Major"):
    
    #var stripped_note = note.remove_chars(" _-!\"£$%^&*()+}{~@:<>?/.,|\\").to_upper()
    #if stripped_note.length() == 2:
        #if stripped_note[1] != null:
            #stripped_note[1] = '#' 
#
    #if stripped_note[0] not in "ABCDEFG":
        #stripped_note[0] = 'C'
        #printerr("Given an invalid note : %s" % stripped_note)
    #
    #if m_notes_str.has(stripped_note):
        #printerr("Given an invalid note : %s" % stripped_note)
         #
    #m_note_index = m_notes_str.find(stripped_note)
    #
    #var letters_only = RegEx.new()
    #letters_only.compile("[^A-Z1-7]")
    #var stripped_scale : String = scale.to_upper()
    #stripped_scale = letters_only.sub(stripped_scale, "", true)
    #
    #for current_scale in m_scales_str:
        #var compare_string = letters_only.sub(current_scale.to_upper(), "", true)
        #if compare_string == stripped_scale:
            #m_scale_index = m_scales_str.find(current_scale)
            #break;
    m_note_index = m_notes_str_to_m_notes_enum(note.to_upper())
    m_scale_index = m_scales_str_to_m_scales_enum(scale.to_upper())



func _init(note : m_notes_enum = m_notes_enum.C, scale : m_scales_enum = m_scales_enum.UNKNOWN):
    m_note_index = note
    m_scale_index = scale


static func Make_with_Enum(note : m_notes_enum, scale : m_scales_enum) -> EMusicKey:
    var key = EMusicKey
    key.m_note_index = note
    key.m_scale_index = scale
    
    return key


static func String_to_MusicKey(music_key_string : String) -> EMusicKey:
    var split_point = music_key_string.find(" ")
    var note = music_key_string.substr(0, (split_point + 1))
    var scale = music_key_string.substr(split_point)
    
    var NewKey = EMusicKey.new()
    NewKey.Set_with_String(note, scale)
    
    return NewKey
    
    

# An Enum version of the m_notes_str Array
enum m_notes_enum {C,                      Cs,                     D,                      
Ds,                     E,                      F,                      
Fs,                     G,                      Gs,                     
A,                      As,                     B,                      
}

# A function to translate any m_notes_str StringNames to m_notes_enum Enums
# NOTE: You must supply the UPPERCASE version...

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

# An Enum version of the m_scales_str Array
enum m_scales_enum {UNKNOWN,                MAJOR,                  NATURAL_MINOR,          
HARMONIC_MINOR,         MELODIC_MINOR,          GYPSY_MINOR,            
NEAPOLITAN_MINOR,       HUNGARIAN_MINOR,        MAJOR_PENTATONIC,       
MINOR_PENTATONIC,       BLUES,                  DORIAN,                 
PHRYGIAN,               LYDIAN,                 MIXOLYDIAN,             
LOCRIAN,                CHROMATIC,              WHOLE_TONE,             
OCTATONIC,              ARABIC,                 }
# A function to translate any m_scales_str StringNames to m_scales_enum Enums
# NOTE: You must supply the UPPERCASE version...

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
