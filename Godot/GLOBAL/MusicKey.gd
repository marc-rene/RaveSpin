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
    return m_notes_str[m_note_index].to_upper() if capitalise else m_notes_str[m_note_index]


func GetScale(capitalise = false) -> StringName:
    return m_scales_str[m_scale_index].to_upper() if capitalise else m_scales_str[m_scale_index]


func Equals(other_music_key : MusicKey):
    return  (other_music_key.m_note_index == m_note_index) \
    and     (other_music_key.m_scale_index == m_scale_index) 


func _to_string() -> String:
    return "%s %s" % [GetNote(), GetScale()]


## NOTE: We Don't use flats, only sharps, and please notate as '#'
## A Sharp Major should be {"A#", "Major"}
func Set_with_String(note = "A", scale = "Major"):
    
    var stripped_note = note.remove_chars(" _-!\"£$%^&*()+}{~@:<>?/.,|\\").to_upper()
    if stripped_note.length() == 2:
        if stripped_note[1] != null:
            stripped_note[1] = '#' 

    if stripped_note[0] not in "ABCDEFG":
        stripped_note[0] = 'C'
        printerr("Given an invalid note : %s" % stripped_note)
    
    if m_notes_str.has(stripped_note):
        printerr("Given an invalid note : %s" % stripped_note)
         
    m_note_index = m_notes_str.find(stripped_note)
    
    var letters_only = RegEx.new()
    letters_only.compile("[^A-Z1-7]")
    var stripped_scale : String = scale.to_upper()
    stripped_scale = letters_only.sub(stripped_scale, "", true)
    
    for current_scale in m_scales_str:
        var compare_string = letters_only.sub(current_scale.to_upper(), "", true)
        if compare_string == stripped_scale:
            m_scale_index = m_scales_str.find(current_scale)
            break;



func Set_with_Enum(note : m_notes_enum, scale : m_scales_enum):
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
    
    
   
enum m_notes_enum { C,    Cs,
                    D,    Ds,
                    E,
                    F,    Fs,
                    G,    Gs,
                    A,    As,
                    B
                    }

### INSERT ENUM VERSION HERE ###
enum m_scales_enum {    
    UNKNOWN,            CHROMATIC,          MAJOR,                  NATURAL_MINOR,     
    HARMONIC_MINOR,     MELODIC_MINOR,      MELODIC_MINOR_JAZZ,     HARMONIC_MAJOR,     
    IONIAN,             DORIAN,             PHRYGIAN,               LYDIAN,     
    MIXOLYDIAN,         AEOLIAN,            LOCRIAN,                MAJOR_PENTATONIC,     
    MINOR_PENTATONIC,   BLUES,              MAJOR_BLUES,            WHOLE_TONE,     
    AUGMENTED,          DIMINISHED_WHOLE_HALF, DIMINISHED_HALF_WHOLE, OCTATONIC,     
    HEXATONIC,          TRITONE,            PROMETHEUS,             ENIGMATIC,     
    OVERTONE,           LEADING_WHOLE_TONE, NEAPOLITAN_MINOR,       NEAPOLITAN_MAJOR,     
    HUNGARIAN_MINOR,    HUNGARIAN_MAJOR,    ROMANIAN_MINOR,         UKRAINIAN_DORIAN,     
    DOUBLE_HARMONIC,    BYZANTINE,          PERSIAN,                ARABIC,     
    PHRYGIAN_DOMINANT,  ALTERED,            SUPER_LOCRIAN,          LYDIAN_DOMINANT,     
    MIXOLYDIAN_B6,      LOCRIAN_2,          LOCRIAN_NATURAL_6,      LYDIAN_AUGMENTED,     
    DORIAN_B2,          PHRYGIAN_6,         MAJOR_LOCRIAN,          MINOR_MAJOR,     
    BEBOP_MAJOR,        BEBOP_DOMINANT,     BEBOP_DORIAN,           BEBOP_MELODIC_MINOR,     
    BEBOP_MINOR,        ACOUSTIC,           SPANISH,                GYPSY_MINOR,     
    GYPSY_MAJOR,        FLAMENCO,           HIRAJOSHI,              KUMOI,     
    IWATO,              IN,                 YO,                     RITSU,     
    AKEBONO,            PELOG,              SLENDRO,                MESSIAEN_MODE_1,     
    MESSIAEN_MODE_2,    MESSIAEN_MODE_3,    MESSIAEN_MODE_4,        MESSIAEN_MODE_5,     
    MESSIAEN_MODE_6,    MESSIAEN_MODE_7,    BILAWAL,                KAFI,     
    ASAVARI,            BHAIRAVI,           BHAIRAV,                KALYAN,     
    MARWA,              POORVI,             TODI,                   KHAMAJ,     
    MAJOR_HEXATONIC,    MINOR_HEXATONIC,    BLUES_HEXATONIC,        NINE_NOTE_BLUES,     
    MAJOR_BEBOP_6TH_ADDED, DOMINANT_BEBOP_MAJOR_7TH_ADDED, DORIAN_BEBOP_MAJOR_3RD_ADDED, PENTATONIC_NEUTRAL,     
    PENTATONIC_SUSPENDED,  MINOR_PENTATONIC_B5_ADDED, MAJOR_PENTATONIC_B3_ADDED, BALINESE_PELOG,     
    BALINESE_SLENDRO,   RAST,               BAYATI,                 HIJAZ,     
    NAHAWAND,           SABA,               KURD,                   AJAM,     
    SIKAH,              HUZAM,              NAWA_ATHAR,             ATHAR_KURD,     
    SUZNAK,             NAHAWAND_KURD,      HIJAZ_KAR,              SHADD_ARABAN,     
}
