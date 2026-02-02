@tool
class_name MusicKey extends Object

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
    "Chromatic",                    "Major",                    "Natural Minor",                
    "Harmonic Minor",               "Melodic Minor",            "Melodic Minor (jazz)",
    "Harmonic Major",               "Ionian",                   "Dorian",
    "Phrygian",                     "Lydian",                   "Mixolydian",
    "Aeolian",                      "Locrian",                  "Major Pentatonic",
    "Minor Pentatonic",             "Blues",                    "Major blues",
    "Whole tone",                   "Augmented",                "Diminished (Whole-Half)",
    "Diminished (Half-Whole)",      "Octatonic",                "Hexatonic",    
    "Tritone",                      "Prometheus",               "Enigmatic",    
    "Overtone",                     "Leading Whole tone",       "Neapolitan Minor",
    "Neapolitan Major",             "Hungarian Minor",          "Hungarian Major",
    "Romanian Minor",               "Ukrainian Dorian",         "Double Harmonic",
    "Byzantine",                    "Persian",                  "Arabic",
    "Phrygian Dominant",            "Altered",                  "Super Locrian",    
    "Lydian Dominant",              "Mixolydian b6",            "Locrian #2",   
    "Locrian natural 6",            "Lydian augmented",         "Dorian b2",    
    "Phrygian #6",                  "Major Locrian",            "Minor Major",  
    "Bebop Major",                  "Bebop Dominant",           "Bebop Dorian",
    "Bebop Melodic Minor",          "Bebop Minor",              "Acoustic", 
    "Spanish",                      "Gypsy Minor",              "Gypsy Major",
    "Flamenco",                     "Hirajoshi",                "Kumoi",
    "Iwato",                        "In",                       "Yo",
    "Ritsu",                        "Akebono",                  "Pelog",
    "Slendro",                      "Messiaen mode 1",          "Messiaen mode 2",
    "Messiaen mode 3",              "Messiaen mode 4",          "Messiaen mode 5",
    "Messiaen mode 6",              "Messiaen mode 7",          "Bilawal",
    "Kafi",                         "Asavari",                  "Bhairavi",
    "Bhairav",                      "Kalyan",                   "Marwa",
    "Poorvi",                       "Todi",                     "Khamaj",
    "Major hexatonic",              "Minor hexatonic",          "Blues hexatonic",
    "Nine-note blues",              "Major bebop (6th added)",  "Dominant bebop (Major 7th added)",
    "Dorian bebop (Major 3rd added)", "Pentatonic (neutral)",   "Pentatonic (suspended)",
    "Minor Pentatonic (b5 added)",  "Major Pentatonic (b3 added)", "Balinese pelog",
    "Balinese slendro",             "Rast",                     "Bayati",
    "Hijaz",                        "Nahawand",                 "Saba",
    "Kurd",                         "Ajam",                     "Sikah",
    "Huzam",                        "Nawa Athar",               "Athar Kurd",
    "Suznak",                       "Nahawand Kurd",            "Hijaz Kar",
    "Shadd Araban" ]



func GetNote(capitalise = false) -> String:
    return m_notes_str[m_note_index] if capitalise else m_notes_str[m_note_index]


func GetScale(capitalise = false) -> StringName:
    return m_scales_str[m_scale_index] if capitalise else m_scales_str[m_scale_index]


func Equals(other_music_key : MusicKey):
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


static func Make_with_Enum(note : m_notes_enum, scale : m_scales_enum) -> MusicKey:
    var key = MusicKey
    key.m_note_index = note
    key.m_scale_index = scale
    
    return key


static func String_to_MusicKey(music_key_string : String) -> MusicKey:
    var split_point = music_key_string.find(" ")
    var note = music_key_string.substr(0, (split_point + 1))
    var scale = music_key_string.substr(split_point)
    
    var NewKey = MusicKey.new()
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

### INSERT ENUM VERSION HERE ###

# An Enum version of the m_scales_str Array
enum m_scales_enum {UNKNOWN,                CHROMATIC,              MAJOR,                  
NATURAL_MINOR,          HARMONIC_MINOR,         MELODIC_MINOR,          
MELODIC_MINOR_JAZZ,     HARMONIC_MAJOR,         IONIAN,                 
DORIAN,                 PHRYGIAN,               LYDIAN,                 
MIXOLYDIAN,             AEOLIAN,                LOCRIAN,                
MAJOR_PENTATONIC,       MINOR_PENTATONIC,       BLUES,                  
MAJOR_BLUES,            WHOLE_TONE,             AUGMENTED,              
DIMINISHED_WHOLE_HALF,  DIMINISHED_HALF_WHOLE,  OCTATONIC,              
HEXATONIC,              TRITONE,                PROMETHEUS,             
ENIGMATIC,              OVERTONE,               LEADING_WHOLE_TONE,     
NEAPOLITAN_MINOR,       NEAPOLITAN_MAJOR,       HUNGARIAN_MINOR,        
HUNGARIAN_MAJOR,        ROMANIAN_MINOR,         UKRAINIAN_DORIAN,       
DOUBLE_HARMONIC,        BYZANTINE,              PERSIAN,                
ARABIC,                 PHRYGIAN_DOMINANT,      ALTERED,                
SUPER_LOCRIAN,          LYDIAN_DOMINANT,        MIXOLYDIAN_B6,          
LOCRIAN_s2,             LOCRIAN_NATURAL_6,      LYDIAN_AUGMENTED,       
DORIAN_B2,              PHRYGIAN_s6,            MAJOR_LOCRIAN,          
MINOR_MAJOR,            BEBOP_MAJOR,            BEBOP_DOMINANT,         
BEBOP_DORIAN,           BEBOP_MELODIC_MINOR,    BEBOP_MINOR,            
ACOUSTIC,               SPANISH,                GYPSY_MINOR,            
GYPSY_MAJOR,            FLAMENCO,               HIRAJOSHI,              
KUMOI,                  IWATO,                  IN,                     
YO,                     RITSU,                  AKEBONO,                
PELOG,                  SLENDRO,                MESSIAEN_MODE_1,        
MESSIAEN_MODE_2,        MESSIAEN_MODE_3,        MESSIAEN_MODE_4,        
MESSIAEN_MODE_5,        MESSIAEN_MODE_6,        MESSIAEN_MODE_7,        
BILAWAL,                KAFI,                   ASAVARI,                
BHAIRAVI,               BHAIRAV,                KALYAN,                 
MARWA,                  POORVI,                 TODI,                   
KHAMAJ,                 MAJOR_HEXATONIC,        MINOR_HEXATONIC,        
BLUES_HEXATONIC,        NINE_NOTE_BLUES,        MAJOR_BEBOP_6TH_ADDED,  
DOMINANT_BEBOP_MAJOR_7TH_ADDED, DORIAN_BEBOP_MAJOR_3RD_ADDED, PENTATONIC_NEUTRAL,     
PENTATONIC_SUSPENDED,   MINOR_PENTATONIC_B5_ADDED, MAJOR_PENTATONIC_B3_ADDED, 
BALINESE_PELOG,         BALINESE_SLENDRO,       RAST,                   
BAYATI,                 HIJAZ,                  NAHAWAND,               
SABA,                   KURD,                   AJAM,                   
SIKAH,                  HUZAM,                  NAWA_ATHAR,             
ATHAR_KURD,             SUZNAK,                 NAHAWAND_KURD,          
HIJAZ_KAR,              SHADD_ARABAN,           }

# A function to translate any m_scales_str StringNames to m_scales_enum Enums
# NOTE: You must supply the UPPERCASE version...

static func m_scales_str_to_m_scales_enum(string_version : String):
    match string_version:
        "UNKNOWN":
            return m_scales_enum.UNKNOWN
        "CHROMATIC":
            return m_scales_enum.CHROMATIC
        "MAJOR":
            return m_scales_enum.MAJOR
        "NATURAL MINOR":
            return m_scales_enum.NATURAL_MINOR
        "HARMONIC MINOR":
            return m_scales_enum.HARMONIC_MINOR
        "MELODIC MINOR":
            return m_scales_enum.MELODIC_MINOR
        "MELODIC MINOR (JAZZ)":
            return m_scales_enum.MELODIC_MINOR_JAZZ
        "HARMONIC MAJOR":
            return m_scales_enum.HARMONIC_MAJOR
        "IONIAN":
            return m_scales_enum.IONIAN
        "DORIAN":
            return m_scales_enum.DORIAN
        "PHRYGIAN":
            return m_scales_enum.PHRYGIAN
        "LYDIAN":
            return m_scales_enum.LYDIAN
        "MIXOLYDIAN":
            return m_scales_enum.MIXOLYDIAN
        "AEOLIAN":
            return m_scales_enum.AEOLIAN
        "LOCRIAN":
            return m_scales_enum.LOCRIAN
        "MAJOR PENTATONIC":
            return m_scales_enum.MAJOR_PENTATONIC
        "MINOR PENTATONIC":
            return m_scales_enum.MINOR_PENTATONIC
        "BLUES":
            return m_scales_enum.BLUES
        "MAJOR BLUES":
            return m_scales_enum.MAJOR_BLUES
        "WHOLE TONE":
            return m_scales_enum.WHOLE_TONE
        "AUGMENTED":
            return m_scales_enum.AUGMENTED
        "DIMINISHED (WHOLE-HALF)":
            return m_scales_enum.DIMINISHED_WHOLE_HALF
        "DIMINISHED (HALF-WHOLE)":
            return m_scales_enum.DIMINISHED_HALF_WHOLE
        "OCTATONIC":
            return m_scales_enum.OCTATONIC
        "HEXATONIC":
            return m_scales_enum.HEXATONIC
        "TRITONE":
            return m_scales_enum.TRITONE
        "PROMETHEUS":
            return m_scales_enum.PROMETHEUS
        "ENIGMATIC":
            return m_scales_enum.ENIGMATIC
        "OVERTONE":
            return m_scales_enum.OVERTONE
        "LEADING WHOLE TONE":
            return m_scales_enum.LEADING_WHOLE_TONE
        "NEAPOLITAN MINOR":
            return m_scales_enum.NEAPOLITAN_MINOR
        "NEAPOLITAN MAJOR":
            return m_scales_enum.NEAPOLITAN_MAJOR
        "HUNGARIAN MINOR":
            return m_scales_enum.HUNGARIAN_MINOR
        "HUNGARIAN MAJOR":
            return m_scales_enum.HUNGARIAN_MAJOR
        "ROMANIAN MINOR":
            return m_scales_enum.ROMANIAN_MINOR
        "UKRAINIAN DORIAN":
            return m_scales_enum.UKRAINIAN_DORIAN
        "DOUBLE HARMONIC":
            return m_scales_enum.DOUBLE_HARMONIC
        "BYZANTINE":
            return m_scales_enum.BYZANTINE
        "PERSIAN":
            return m_scales_enum.PERSIAN
        "ARABIC":
            return m_scales_enum.ARABIC
        "PHRYGIAN DOMINANT":
            return m_scales_enum.PHRYGIAN_DOMINANT
        "ALTERED":
            return m_scales_enum.ALTERED
        "SUPER LOCRIAN":
            return m_scales_enum.SUPER_LOCRIAN
        "LYDIAN DOMINANT":
            return m_scales_enum.LYDIAN_DOMINANT
        "MIXOLYDIAN B6":
            return m_scales_enum.MIXOLYDIAN_B6
        "LOCRIAN #2":
            return m_scales_enum.LOCRIAN_s2
        "LOCRIAN NATURAL 6":
            return m_scales_enum.LOCRIAN_NATURAL_6
        "LYDIAN AUGMENTED":
            return m_scales_enum.LYDIAN_AUGMENTED
        "DORIAN B2":
            return m_scales_enum.DORIAN_B2
        "PHRYGIAN #6":
            return m_scales_enum.PHRYGIAN_s6
        "MAJOR LOCRIAN":
            return m_scales_enum.MAJOR_LOCRIAN
        "MINOR MAJOR":
            return m_scales_enum.MINOR_MAJOR
        "BEBOP MAJOR":
            return m_scales_enum.BEBOP_MAJOR
        "BEBOP DOMINANT":
            return m_scales_enum.BEBOP_DOMINANT
        "BEBOP DORIAN":
            return m_scales_enum.BEBOP_DORIAN
        "BEBOP MELODIC MINOR":
            return m_scales_enum.BEBOP_MELODIC_MINOR
        "BEBOP MINOR":
            return m_scales_enum.BEBOP_MINOR
        "ACOUSTIC":
            return m_scales_enum.ACOUSTIC
        "SPANISH":
            return m_scales_enum.SPANISH
        "GYPSY MINOR":
            return m_scales_enum.GYPSY_MINOR
        "GYPSY MAJOR":
            return m_scales_enum.GYPSY_MAJOR
        "FLAMENCO":
            return m_scales_enum.FLAMENCO
        "HIRAJOSHI":
            return m_scales_enum.HIRAJOSHI
        "KUMOI":
            return m_scales_enum.KUMOI
        "IWATO":
            return m_scales_enum.IWATO
        "IN":
            return m_scales_enum.IN
        "YO":
            return m_scales_enum.YO
        "RITSU":
            return m_scales_enum.RITSU
        "AKEBONO":
            return m_scales_enum.AKEBONO
        "PELOG":
            return m_scales_enum.PELOG
        "SLENDRO":
            return m_scales_enum.SLENDRO
        "MESSIAEN MODE 1":
            return m_scales_enum.MESSIAEN_MODE_1
        "MESSIAEN MODE 2":
            return m_scales_enum.MESSIAEN_MODE_2
        "MESSIAEN MODE 3":
            return m_scales_enum.MESSIAEN_MODE_3
        "MESSIAEN MODE 4":
            return m_scales_enum.MESSIAEN_MODE_4
        "MESSIAEN MODE 5":
            return m_scales_enum.MESSIAEN_MODE_5
        "MESSIAEN MODE 6":
            return m_scales_enum.MESSIAEN_MODE_6
        "MESSIAEN MODE 7":
            return m_scales_enum.MESSIAEN_MODE_7
        "BILAWAL":
            return m_scales_enum.BILAWAL
        "KAFI":
            return m_scales_enum.KAFI
        "ASAVARI":
            return m_scales_enum.ASAVARI
        "BHAIRAVI":
            return m_scales_enum.BHAIRAVI
        "BHAIRAV":
            return m_scales_enum.BHAIRAV
        "KALYAN":
            return m_scales_enum.KALYAN
        "MARWA":
            return m_scales_enum.MARWA
        "POORVI":
            return m_scales_enum.POORVI
        "TODI":
            return m_scales_enum.TODI
        "KHAMAJ":
            return m_scales_enum.KHAMAJ
        "MAJOR HEXATONIC":
            return m_scales_enum.MAJOR_HEXATONIC
        "MINOR HEXATONIC":
            return m_scales_enum.MINOR_HEXATONIC
        "BLUES HEXATONIC":
            return m_scales_enum.BLUES_HEXATONIC
        "NINE-NOTE BLUES":
            return m_scales_enum.NINE_NOTE_BLUES
        "MAJOR BEBOP (6TH ADDED)":
            return m_scales_enum.MAJOR_BEBOP_6TH_ADDED
        "DOMINANT BEBOP (MAJOR 7TH ADDED)":
            return m_scales_enum.DOMINANT_BEBOP_MAJOR_7TH_ADDED
        "DORIAN BEBOP (MAJOR 3RD ADDED)":
            return m_scales_enum.DORIAN_BEBOP_MAJOR_3RD_ADDED
        "PENTATONIC (NEUTRAL)":
            return m_scales_enum.PENTATONIC_NEUTRAL
        "PENTATONIC (SUSPENDED)":
            return m_scales_enum.PENTATONIC_SUSPENDED
        "MINOR PENTATONIC (B5 ADDED)":
            return m_scales_enum.MINOR_PENTATONIC_B5_ADDED
        "MAJOR PENTATONIC (B3 ADDED)":
            return m_scales_enum.MAJOR_PENTATONIC_B3_ADDED
        "BALINESE PELOG":
            return m_scales_enum.BALINESE_PELOG
        "BALINESE SLENDRO":
            return m_scales_enum.BALINESE_SLENDRO
        "RAST":
            return m_scales_enum.RAST
        "BAYATI":
            return m_scales_enum.BAYATI
        "HIJAZ":
            return m_scales_enum.HIJAZ
        "NAHAWAND":
            return m_scales_enum.NAHAWAND
        "SABA":
            return m_scales_enum.SABA
        "KURD":
            return m_scales_enum.KURD
        "AJAM":
            return m_scales_enum.AJAM
        "SIKAH":
            return m_scales_enum.SIKAH
        "HUZAM":
            return m_scales_enum.HUZAM
        "NAWA ATHAR":
            return m_scales_enum.NAWA_ATHAR
        "ATHAR KURD":
            return m_scales_enum.ATHAR_KURD
        "SUZNAK":
            return m_scales_enum.SUZNAK
        "NAHAWAND KURD":
            return m_scales_enum.NAHAWAND_KURD
        "HIJAZ KAR":
            return m_scales_enum.HIJAZ_KAR
        "SHADD ARABAN":
            return m_scales_enum.SHADD_ARABAN
        _:
            return m_scales_enum.UNKNOWN
