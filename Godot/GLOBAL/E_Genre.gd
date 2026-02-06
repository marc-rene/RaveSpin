class_name EGenre
extends Object

# All possible Genres that a song could be
# TODO: Delete this and replace 
const m_MusicGenres_str : Array[StringName] = [
    "Unknown",
    "Other",
    
    # Blues Roots and Folk
	"American Blues",
	"Blues",
	"Delta Blues",
	"Chicago Blues",
	"Texas Blues",
	"Piedmont Blues",
	"Jump Blues",
	"Boogie Woogie",
	"Country Blues",
	"Electric Blues",
	"Harmonica Blues",
	"Swamp Blues",
	"Zydeco",
	"Cajun",
	"Bluegrass",
	"Old Time",
	"Appalachian Folk",
	"Folk",
	"Contemporary Folk",
	"Folk Rock",
	"Singer Songwriter",
	"Americana",
	"Gospel",
	"Spiritual",
	"Work Song",
	"Sea Shanty",
	"Chant",
	"Acoustic",
	"Roots Rock",

	# Country
	"Country",
	"Classic Country",
	"Outlaw Country",
	"Country Rock",
	"Country Pop",
	"Alternative Country",
	"Bluegrass Gospel",
	"Honky Tonk",
	"Western Swing",
	"Nashville Sound",
	"Bakersfield Sound",
	"Cowboy",
	"Country and Irish", # irish circuit country tag
	"Celtic Country",

	# Rock
	"Rock",
	"Classic Rock",
	"Hard Rock",
	"Soft Rock",
	"Arena Rock",
	"Rock and Roll",
	"Garage Rock",
	"Psychedelic Rock",
	"Progressive Rock",
	"Art Rock",
	"Glam Rock",
	"Pub Rock",
	"Indie Rock",
	"Alternative Rock",
	"College Rock",
	"Post Rock",
	"Shoegaze",
	"Dream Pop",
	"Noise Rock",
	"Math Rock",
	"Stoner Rock",
	"Sludge Rock",
	"Desert Rock",
	"Grunge",
	"Britpop",
	"Madchester",
	"New Wave",
	"Synth Rock",
	"Post Punk",
	"Gothic Rock",
	"Industrial Rock",

	# Punk and Hardcore
	"Punk",
	"Hardcore",
	"Hardcore Punk",
	"Post Hardcore",
	"Pop Punk",
	"Skate Punk",
	"Oi",
	"Anarcho Punk",
	"Crust Punk",
	"D Beat",
	"Street Punk",
	"Emo",
	"Emo Pop",
	"Screamo",

	# Metal
	"Metal",
	"Heavy Metal",
	"Thrash Metal",
	"Speed Metal",
	"Power Metal",
	"Progressive Metal",
	"Doom Metal",
	"Sludge Metal",
	"Stoner Metal",
	"Black Metal",
	"Symphonic Black Metal",
	"Atmospheric Black Metal",
	"Death Metal",
	"Melodic Death Metal",
	"Technical Death Metal",
	"Deathcore",
	"Metalcore",
	"Grindcore",
	"Goregrind",
	"Nu Metal",
	"Industrial Metal",
	"Folk Metal",
	"Viking Metal",
	"Gothic Metal",
	"Symphonic Metal",
	"Post Metal",

	# Pop
	"Pop",
	"Pop Rock",
	"Teen Pop",
	"Electropop",
	"Synthpop",
	"Dance Pop",
	"Indie Pop",
	"Art Pop",
	"Hyperpop",
	"Chamber Pop",
	"Baroque Pop",
	"Sunshine Pop",
	"Easy Listening",
	"Adult Contemporary",
	"Ballad",
	"Vocal Pop",

	# R and B Soul and Funk
	"Randb",
	"Contemporary Randb",
	"Neo Soul",
	"Soul",
	"Motown",
	"Northern Soul",
	"Southern Soul",
	"Funk",
	"P Funk",
	"Disco",
	"Boogie",
	"Quiet Storm",

	# Hip Hop and Rap
	"Hip Hop",
	"Rap",
	"Old School Hip Hop",
	"Golden Age Hip Hop",
	"Boom Bap",
	"Conscious Hip Hop",
	"Alternative Hip Hop",
	"Experimental Hip Hop",
	"Trip Hop",
	"Lo Fi Hip Hop",
	"Trap",
	"Drill",
	"UK Drill",
	"Grime",
	"Cloud Rap",
	"Crunk",
	"G Funk",
	"Gangsta Rap",
	"Horrorcore",
	"Memphis Rap",
	"Phonk",
	"Jazz Rap",

	# Jazz
	"Jazz",
	"Traditional Jazz",
	"Dixieland",
	"Swing",
	"Big Band",
	"Bebop",
	"Hard Bop",
	"Cool Jazz",
	"Modal Jazz",
	"Free Jazz",
	"Avant Garde Jazz",
	"Jazz Fusion",
	"Smooth Jazz",
	"Vocal Jazz",
	"Latin Jazz",
	"Acid Jazz",

	# Classical and Soundtrack
	"Classical",
	"Baroque",
	"Classical Period",
	"Romantic",
	"Modern Classical",
	"Contemporary Classical",
	"Orchestral",
	"Chamber Music",
	"Opera",
	"Choral",
	"Sacred",
	"Early Music",
	"Minimalism",
	"Avant Garde",
	"Serialism",
	"Film Score",
	"Soundtrack",
	"Video Game Music",
	"Library Music",
	"Ambient Classical",

	# Electronic General
	"Electronic",
	"EDM", # marketing umbrella tag

	# Electronic House
	"House",
	"Chicago House",
	"Deep House",
	"Soulful House",
	"Funky House",
	"Disco House",
	"Nu Disco",
	"Italo Disco",
	"Electro Disco",
	"Jackin House",
	"Lo Fi House",
	"Progressive House",
	"Electro House",
	"Big Room",
	"Future House",
	"Slap House",
	"Bass House",
	"Tech House",
	"Minimal House",
	"Microhouse", # often tagged as minimal
	"Ghetto House",
	"Acid House",
	"Tribal House",
	"Afro House",
	"Latin House",
	"Balearic Beat",
	"Garage House",
	"Hard House",
	"Progressive Trance",
	"Deep Tech",

	# Electronic Techno
	"Techno",
	"Detroit Techno",
	"Acid Techno",
	"Ambient Techno",
	"Bleep Techno",
	"Deep Techno",
	"Dub Techno",
	"Minimal Techno",
	"Hard Techno",
	"Hardgroove Techno", # groove focused techno
	"Industrial Techno",
	"Melodic Techno",
	"Peak Time Techno",
	"Schranz", # hard fast techno tag
	"Wonky Techno",
	"Free Tekno", # free party tekno scene spelling
	"Tekno", # alternate spelling of free tekno
	"Makina",
	"Berlin Techno", # scene tag
	"Warehouse Techno", # scene tag
	"Driving Techno", # descriptor tag
	"Hypnotic Techno", # descriptor tag

	# Electronic Trance
	"Trance",
	"Uplifting Trance",
	"Vocal Trance",
	"Tech Trance",
	"Hard Trance",
	"Goa Trance",
	"Psytrance",
	"Acid Trance",
	"Dream Trance",

	# Electronic Breaks and Bass
	"Electro",
	"Electroclash",
	"Breakbeat",
	"Breaks",
	"Big Beat",
	"Nu Skool Breaks",
	"Broken Beat",
	"Future Bass",
	"Midtempo Bass",
	"Glitch Hop",
	"IDM", # intelligent dance music tag
	"Glitch",
	"Experimental Electronic",
	"EDM Trap",

	# Electronic Ambient and Downtempo
	"Ambient",
	"Dark Ambient",
	"Drone",
	"Chillout",
	"Downtempo",
	"Psybient",
	"Psydub",

	# Electronic Industrial and EBM
	"Industrial",
	"EBM", # electronic body music
	"Industrial Dance",

	# Electronic Hard Dance
	"Hard Dance",
	"Hardstyle",
	"Rawstyle",
	"Jumpstyle",
	"Hands Up",
	"Hard NRG",
	"Eurodance",
	"Italo Dance",
	"Hi NRG", # high energy dance music

	# UK Rave and Breakbeat
	"Rave",
	"Oldskool Rave",
	"Hardcore Rave",
	"UK Bass", # uk bass umbrella tag
	"Breakbeat Hardcore",
	"Darkcore",
	"Hardcore Breaks",

	# Drum and Bass and Jungle
	"Jungle",
	"Ragga Jungle",
	"Drum and Bass",
	"Atmospheric Drum and Bass",
	"Dancefloor Drum and Bass",
	"Darkstep",
	"Deep Drum and Bass",
	"Drill and Bass",
	"Drumfunk",
	"Drumstep",
	"Dubwise",
	"Halftime",
	"Hardstep",
	"Jazzstep",
	"Jump Up",
	"Liquid Funk",
	"Minimal Drum and Bass",
	"Neurofunk",
	"Techstep",
	"Trancestep",
	"Technoid",
	"Liquid Drum and Bass",

	# UK Garage and Bass
	"UK Garage",
	"Two Step",
	"Speed Garage",
	"Future Garage",
	"Breakstep",
	"Bassline",
	"UK Funky",

	# Dubstep
	"Dubstep",
	"Brostep",
	"Riddim",
	"Post Dubstep",
	"Wobblestep",

	# Hardcore Techno
	"Hardcore Techno",
	"Gabber",
	"Happy Hardcore",
	"Freeform Hardcore",
	"Frenchcore",
	"Doomcore",
	"Industrial Hardcore",
	"Speedcore",
	"Terrorcore",
	"Uptempo Hardcore",
	"Powerstomp",
	"J Core",
	"Modern Hardtek",
	"Raggatek",
	"Pumpcore",

	# Breakcore and Extremes
	"Breakcore",
	"Extratone",
	"Splittercore",

	# UK Scene Tags
	"Donk", # northern england bouncy dance tag
	"Scouse House", # liverpool bouncy house tag

	# Reggae and Caribbean
	"Reggae",
	"Roots Reggae",
	"Dub",
	"Dancehall",
	"Rocksteady",
	"Ska",
	"Two Tone",
	"Reggaeton",
	"Soca",
	"Calypso",

	# Latin and Iberian
	"Latin",
	"Salsa",
	"Bachata",
	"Merengue",
	"Cumbia",
	"Cumbia Sonidera",
	"Tejano",
	"Norteno",
	"Banda",
	"Mariachi",
	"Ranchera",
	"Latin Pop",
	"Latin Rock",
	"Bossa Nova",
	"Samba",
	"MPB",
	"Forro",
	"Pagode",
	"Tango",
	"Flamenco",
	"Fado",

	# Africa
	"Highlife",
	"Afrobeat",
	"Afrobeats",
	"Amapiano",
	"Kwaito",
	"Gqom",
	"Soukous",
	"Makossa",
	"Mbalax",
	"Gnawa",
	"Rai",
	"Afropop",

	# Middle East and North Africa
	"Arabic Pop",
	"Arabesque",
	"Dabke",
	"Turkish Pop",
	"Turkish Folk",
	"Persian Pop",
	"Persian Traditional",
	"Anatolian Rock",
	"Qawwali",
	"Sufi",

	# South Asia
	"Indian Classical",
	"Hindustani Classical",
	"Carnatic",
	"Bollywood",
	"Bhangra",
	"Ghazal",
	"Desi Hip Hop",
	"Pakistani Pop",

	# East and Southeast Asia
	"C Pop", # chinese language pop umbrella
	"Mandopop",
	"Cantopop",
	"Hokkien Pop",
	"Hakka Pop",
	"Shidaiqu", # early chinese popular music
	"Guoyue", # national music tradition
	"Chinese Traditional",
	"Chinese Folk",
	"Chinese Opera",
	"Peking Opera",
	"Kunqu",
	"Yue Opera",
	"Cantonese Opera",
	"Jiangnan Sizhu", # silk and bamboo ensemble tradition
	"Nanyin", # minnan classical music tradition
	"K Pop",
	"J Pop",
	"Kayokyoku", # japanese pop era style
	"Enka", # japanese ballad style
	"Visual Kei", # japanese rock fashion scene
	"J Rock",
	"J Hip Hop",
	"City Pop", # japanese pop style
	"K Rock",
	"T Pop",
	"Thai Pop",
	"V Pop",
	"Viet Pop",
	"Pinoy Pop",
	"Original Pilipino Music", # also known as OPM
	"Gamelan",
	"Dangdut",
	"Kroncong",

	# Russia and Slavic
	"Russian Chanson", # urban ballad tradition
	"Estrada", # soviet stage pop tradition
	"Russian Romance",
	"Bard Song", # russian author song tradition
	"Russian Folk",
	"Slavic Folk",
	"Tuvan Throat Singing", # tuva overtone singing tradition
	"Hardbass", # russian meme hard dance tag
	"Russian Orthodox Liturgical", # church liturgical tradition

	# Celtic
	"Celtic",
	"Irish Traditional",
	"Irish Folk",
	"Sean Nos", # irish unaccompanied singing
	"Celtic Rock",
	"Celtic Punk",
	"Scottish Traditional",
	"Breton Folk",

	# Spoken and Utility
	"Instrumental",
	"a Cappella",
	"Live",
	"Spoken Word",
	"Comedy",
	"Audiobook",
	"Podcast",
	"Kids",
	"Holiday",
	"Christmas",
	"Wedding",
	"Meditation",
	"ASMR", # autonomous sensory response tag
	"Fitness",
	"Workout",
	"Study",
	"Sleep",
    "Nature",
]










### INSERT ENUM VERSION HERE ###

# An Enum version of the m_MusicGenres_str Array
enum m_MusicGenres_enum {UNKNOWN,                OTHER,                  AMERICAN_BLUES,         
BLUES,                  DELTA_BLUES,            CHICAGO_BLUES,          
TEXAS_BLUES,            PIEDMONT_BLUES,         JUMP_BLUES,             
BOOGIE_WOOGIE,          COUNTRY_BLUES,          ELECTRIC_BLUES,         
HARMONICA_BLUES,        SWAMP_BLUES,            ZYDECO,                 
CAJUN,                  BLUEGRASS,              OLD_TIME,               
APPALACHIAN_FOLK,       FOLK,                   CONTEMPORARY_FOLK,      
FOLK_ROCK,              SINGER_SONGWRITER,      AMERICANA,              
GOSPEL,                 SPIRITUAL,              WORK_SONG,              
SEA_SHANTY,             CHANT,                  ACOUSTIC,               
ROOTS_ROCK,             COUNTRY,                CLASSIC_COUNTRY,        
OUTLAW_COUNTRY,         COUNTRY_ROCK,           COUNTRY_POP,            
ALTERNATIVE_COUNTRY,    BLUEGRASS_GOSPEL,       HONKY_TONK,             
WESTERN_SWING,          NASHVILLE_SOUND,        BAKERSFIELD_SOUND,      
COWBOY,                 COUNTRY_AND_IRISH,      CELTIC_COUNTRY,         
ROCK,                   CLASSIC_ROCK,           HARD_ROCK,              
SOFT_ROCK,              ARENA_ROCK,             ROCK_AND_ROLL,          
GARAGE_ROCK,            PSYCHEDELIC_ROCK,       PROGRESSIVE_ROCK,       
ART_ROCK,               GLAM_ROCK,              PUB_ROCK,               
INDIE_ROCK,             ALTERNATIVE_ROCK,       COLLEGE_ROCK,           
POST_ROCK,              SHOEGAZE,               DREAM_POP,              
NOISE_ROCK,             MATH_ROCK,              STONER_ROCK,            
SLUDGE_ROCK,            DESERT_ROCK,            GRUNGE,                 
BRITPOP,                MADCHESTER,             NEW_WAVE,               
SYNTH_ROCK,             POST_PUNK,              GOTHIC_ROCK,            
INDUSTRIAL_ROCK,        PUNK,                   HARDCORE,               
HARDCORE_PUNK,          POST_HARDCORE,          POP_PUNK,               
SKATE_PUNK,             OI,                     ANARCHO_PUNK,           
CRUST_PUNK,             D_BEAT,                 STREET_PUNK,            
EMO,                    EMO_POP,                SCREAMO,                
METAL,                  HEAVY_METAL,            THRASH_METAL,           
SPEED_METAL,            POWER_METAL,            PROGRESSIVE_METAL,      
DOOM_METAL,             SLUDGE_METAL,           STONER_METAL,           
BLACK_METAL,            SYMPHONIC_BLACK_METAL,  ATMOSPHERIC_BLACK_METAL, 
DEATH_METAL,            MELODIC_DEATH_METAL,    TECHNICAL_DEATH_METAL,  
DEATHCORE,              METALCORE,              GRINDCORE,              
GOREGRIND,              NU_METAL,               INDUSTRIAL_METAL,       
FOLK_METAL,             VIKING_METAL,           GOTHIC_METAL,           
SYMPHONIC_METAL,        POST_METAL,             POP,                    
POP_ROCK,               TEEN_POP,               ELECTROPOP,             
SYNTHPOP,               DANCE_POP,              INDIE_POP,              
ART_POP,                HYPERPOP,               CHAMBER_POP,            
BAROQUE_POP,            SUNSHINE_POP,           EASY_LISTENING,         
ADULT_CONTEMPORARY,     BALLAD,                 VOCAL_POP,              
RANDB,                  CONTEMPORARY_RANDB,     NEO_SOUL,               
SOUL,                   MOTOWN,                 NORTHERN_SOUL,          
SOUTHERN_SOUL,          FUNK,                   P_FUNK,                 
DISCO,                  BOOGIE,                 QUIET_STORM,            
HIP_HOP,                RAP,                    OLD_SCHOOL_HIP_HOP,     
GOLDEN_AGE_HIP_HOP,     BOOM_BAP,               CONSCIOUS_HIP_HOP,      
ALTERNATIVE_HIP_HOP,    EXPERIMENTAL_HIP_HOP,   TRIP_HOP,               
LO_FI_HIP_HOP,          TRAP,                   DRILL,                  
UK_DRILL,               GRIME,                  CLOUD_RAP,              
CRUNK,                  G_FUNK,                 GANGSTA_RAP,            
HORRORCORE,             MEMPHIS_RAP,            PHONK,                  
JAZZ_RAP,               JAZZ,                   TRADITIONAL_JAZZ,       
DIXIELAND,              SWING,                  BIG_BAND,               
BEBOP,                  HARD_BOP,               COOL_JAZZ,              
MODAL_JAZZ,             FREE_JAZZ,              AVANT_GARDE_JAZZ,       
JAZZ_FUSION,            SMOOTH_JAZZ,            VOCAL_JAZZ,             
LATIN_JAZZ,             ACID_JAZZ,              CLASSICAL,              
BAROQUE,                CLASSICAL_PERIOD,       ROMANTIC,               
MODERN_CLASSICAL,       CONTEMPORARY_CLASSICAL, ORCHESTRAL,             
CHAMBER_MUSIC,          OPERA,                  CHORAL,                 
SACRED,                 EARLY_MUSIC,            MINIMALISM,             
AVANT_GARDE,            SERIALISM,              FILM_SCORE,             
SOUNDTRACK,             VIDEO_GAME_MUSIC,       LIBRARY_MUSIC,          
AMBIENT_CLASSICAL,      ELECTRONIC,             EDM,                    
HOUSE,                  CHICAGO_HOUSE,          DEEP_HOUSE,             
SOULFUL_HOUSE,          FUNKY_HOUSE,            DISCO_HOUSE,            
NU_DISCO,               ITALO_DISCO,            ELECTRO_DISCO,          
JACKIN_HOUSE,           LO_FI_HOUSE,            PROGRESSIVE_HOUSE,      
ELECTRO_HOUSE,          BIG_ROOM,               FUTURE_HOUSE,           
SLAP_HOUSE,             BASS_HOUSE,             TECH_HOUSE,             
MINIMAL_HOUSE,          MICROHOUSE,             GHETTO_HOUSE,           
ACID_HOUSE,             TRIBAL_HOUSE,           AFRO_HOUSE,             
LATIN_HOUSE,            BALEARIC_BEAT,          GARAGE_HOUSE,           
HARD_HOUSE,             PROGRESSIVE_TRANCE,     DEEP_TECH,              
TECHNO,                 DETROIT_TECHNO,         ACID_TECHNO,            
AMBIENT_TECHNO,         BLEEP_TECHNO,           DEEP_TECHNO,            
DUB_TECHNO,             MINIMAL_TECHNO,         HARD_TECHNO,            
HARDGROOVE_TECHNO,      INDUSTRIAL_TECHNO,      MELODIC_TECHNO,         
PEAK_TIME_TECHNO,       SCHRANZ,                WONKY_TECHNO,           
FREE_TEKNO,             TEKNO,                  MAKINA,                 
BERLIN_TECHNO,          WAREHOUSE_TECHNO,       DRIVING_TECHNO,         
HYPNOTIC_TECHNO,        TRANCE,                 UPLIFTING_TRANCE,       
VOCAL_TRANCE,           TECH_TRANCE,            HARD_TRANCE,            
GOA_TRANCE,             PSYTRANCE,              ACID_TRANCE,            
DREAM_TRANCE,           ELECTRO,                ELECTROCLASH,           
BREAKBEAT,              BREAKS,                 BIG_BEAT,               
NU_SKOOL_BREAKS,        BROKEN_BEAT,            FUTURE_BASS,            
MIDTEMPO_BASS,          GLITCH_HOP,             IDM,                    
GLITCH,                 EXPERIMENTAL_ELECTRONIC, EDM_TRAP,               
AMBIENT,                DARK_AMBIENT,           DRONE,                  
CHILLOUT,               DOWNTEMPO,              PSYBIENT,               
PSYDUB,                 INDUSTRIAL,             EBM,                    
INDUSTRIAL_DANCE,       HARD_DANCE,             HARDSTYLE,              
RAWSTYLE,               JUMPSTYLE,              HANDS_UP,               
HARD_NRG,               EURODANCE,              ITALO_DANCE,            
HI_NRG,                 RAVE,                   OLDSKOOL_RAVE,          
HARDCORE_RAVE,          UK_BASS,                BREAKBEAT_HARDCORE,     
DARKCORE,               HARDCORE_BREAKS,        JUNGLE,                 
RAGGA_JUNGLE,           DRUM_AND_BASS,          ATMOSPHERIC_DRUM_AND_BASS, 
DANCEFLOOR_DRUM_AND_BASS, DARKSTEP,               DEEP_DRUM_AND_BASS,     
DRILL_AND_BASS,         DRUMFUNK,               DRUMSTEP,               
DUBWISE,                HALFTIME,               HARDSTEP,               
JAZZSTEP,               JUMP_UP,                LIQUID_FUNK,            
MINIMAL_DRUM_AND_BASS,  NEUROFUNK,              TECHSTEP,               
TRANCESTEP,             TECHNOID,               LIQUID_DRUM_AND_BASS,   
UK_GARAGE,              TWO_STEP,               SPEED_GARAGE,           
FUTURE_GARAGE,          BREAKSTEP,              BASSLINE,               
UK_FUNKY,               DUBSTEP,                BROSTEP,                
RIDDIM,                 POST_DUBSTEP,           WOBBLESTEP,             
HARDCORE_TECHNO,        GABBER,                 HAPPY_HARDCORE,         
FREEFORM_HARDCORE,      FRENCHCORE,             DOOMCORE,               
INDUSTRIAL_HARDCORE,    SPEEDCORE,              TERRORCORE,             
UPTEMPO_HARDCORE,       POWERSTOMP,             J_CORE,                 
MODERN_HARDTEK,         RAGGATEK,               PUMPCORE,               
BREAKCORE,              EXTRATONE,              SPLITTERCORE,           
DONK,                   SCOUSE_HOUSE,           REGGAE,                 
ROOTS_REGGAE,           DUB,                    DANCEHALL,              
ROCKSTEADY,             SKA,                    TWO_TONE,               
REGGAETON,              SOCA,                   CALYPSO,                
LATIN,                  SALSA,                  BACHATA,                
MERENGUE,               CUMBIA,                 CUMBIA_SONIDERA,        
TEJANO,                 NORTENO,                BANDA,                  
MARIACHI,               RANCHERA,               LATIN_POP,              
LATIN_ROCK,             BOSSA_NOVA,             SAMBA,                  
MPB,                    FORRO,                  PAGODE,                 
TANGO,                  FLAMENCO,               FADO,                   
HIGHLIFE,               AFROBEAT,               AFROBEATS,              
AMAPIANO,               KWAITO,                 GQOM,                   
SOUKOUS,                MAKOSSA,                MBALAX,                 
GNAWA,                  RAI,                    AFROPOP,                
ARABIC_POP,             ARABESQUE,              DABKE,                  
TURKISH_POP,            TURKISH_FOLK,           PERSIAN_POP,            
PERSIAN_TRADITIONAL,    ANATOLIAN_ROCK,         QAWWALI,                
SUFI,                   INDIAN_CLASSICAL,       HINDUSTANI_CLASSICAL,   
CARNATIC,               BOLLYWOOD,              BHANGRA,                
GHAZAL,                 DESI_HIP_HOP,           PAKISTANI_POP,          
C_POP,                  MANDOPOP,               CANTOPOP,               
HOKKIEN_POP,            HAKKA_POP,              SHIDAIQU,               
GUOYUE,                 CHINESE_TRADITIONAL,    CHINESE_FOLK,           
CHINESE_OPERA,          PEKING_OPERA,           KUNQU,                  
YUE_OPERA,              CANTONESE_OPERA,        JIANGNAN_SIZHU,         
NANYIN,                 K_POP,                  J_POP,                  
KAYOKYOKU,              ENKA,                   VISUAL_KEI,             
J_ROCK,                 J_HIP_HOP,              CITY_POP,               
K_ROCK,                 T_POP,                  THAI_POP,               
V_POP,                  VIET_POP,               PINOY_POP,              
ORIGINAL_PILIPINO_MUSIC, GAMELAN,                DANGDUT,                
KRONCONG,               RUSSIAN_CHANSON,        ESTRADA,                
RUSSIAN_ROMANCE,        BARD_SONG,              RUSSIAN_FOLK,           
SLAVIC_FOLK,            TUVAN_THROAT_SINGING,   HARDBASS,               
RUSSIAN_ORTHODOX_LITURGICAL, CELTIC,                 IRISH_TRADITIONAL,      
IRISH_FOLK,             SEAN_NOS,               CELTIC_ROCK,            
CELTIC_PUNK,            SCOTTISH_TRADITIONAL,   BRETON_FOLK,            
INSTRUMENTAL,           A_CAPPELLA,             LIVE,                   
SPOKEN_WORD,            COMEDY,                 AUDIOBOOK,              
PODCAST,                KIDS,                   HOLIDAY,                
CHRISTMAS,              WEDDING,                MEDITATION,             
ASMR,                   FITNESS,                WORKOUT,                
STUDY,                  SLEEP,                  NATURE,                 
}
# A function to translate any m_MusicGenres_str StringNames to m_MusicGenres_enum Enums
# NOTE: You must supply the UPPERCASE version...

static func m_MusicGenres_str_to_m_MusicGenres_enum(string_version : String):
    match string_version:
        "UNKNOWN":
            return m_MusicGenres_enum.UNKNOWN
        "OTHER":
            return m_MusicGenres_enum.OTHER
        "AMERICAN BLUES":
            return m_MusicGenres_enum.AMERICAN_BLUES
        "BLUES":
            return m_MusicGenres_enum.BLUES
        "DELTA BLUES":
            return m_MusicGenres_enum.DELTA_BLUES
        "CHICAGO BLUES":
            return m_MusicGenres_enum.CHICAGO_BLUES
        "TEXAS BLUES":
            return m_MusicGenres_enum.TEXAS_BLUES
        "PIEDMONT BLUES":
            return m_MusicGenres_enum.PIEDMONT_BLUES
        "JUMP BLUES":
            return m_MusicGenres_enum.JUMP_BLUES
        "BOOGIE WOOGIE":
            return m_MusicGenres_enum.BOOGIE_WOOGIE
        "COUNTRY BLUES":
            return m_MusicGenres_enum.COUNTRY_BLUES
        "ELECTRIC BLUES":
            return m_MusicGenres_enum.ELECTRIC_BLUES
        "HARMONICA BLUES":
            return m_MusicGenres_enum.HARMONICA_BLUES
        "SWAMP BLUES":
            return m_MusicGenres_enum.SWAMP_BLUES
        "ZYDECO":
            return m_MusicGenres_enum.ZYDECO
        "CAJUN":
            return m_MusicGenres_enum.CAJUN
        "BLUEGRASS":
            return m_MusicGenres_enum.BLUEGRASS
        "OLD TIME":
            return m_MusicGenres_enum.OLD_TIME
        "APPALACHIAN FOLK":
            return m_MusicGenres_enum.APPALACHIAN_FOLK
        "FOLK":
            return m_MusicGenres_enum.FOLK
        "CONTEMPORARY FOLK":
            return m_MusicGenres_enum.CONTEMPORARY_FOLK
        "FOLK ROCK":
            return m_MusicGenres_enum.FOLK_ROCK
        "SINGER SONGWRITER":
            return m_MusicGenres_enum.SINGER_SONGWRITER
        "AMERICANA":
            return m_MusicGenres_enum.AMERICANA
        "GOSPEL":
            return m_MusicGenres_enum.GOSPEL
        "SPIRITUAL":
            return m_MusicGenres_enum.SPIRITUAL
        "WORK SONG":
            return m_MusicGenres_enum.WORK_SONG
        "SEA SHANTY":
            return m_MusicGenres_enum.SEA_SHANTY
        "CHANT":
            return m_MusicGenres_enum.CHANT
        "ACOUSTIC":
            return m_MusicGenres_enum.ACOUSTIC
        "ROOTS ROCK":
            return m_MusicGenres_enum.ROOTS_ROCK
        "COUNTRY":
            return m_MusicGenres_enum.COUNTRY
        "CLASSIC COUNTRY":
            return m_MusicGenres_enum.CLASSIC_COUNTRY
        "OUTLAW COUNTRY":
            return m_MusicGenres_enum.OUTLAW_COUNTRY
        "COUNTRY ROCK":
            return m_MusicGenres_enum.COUNTRY_ROCK
        "COUNTRY POP":
            return m_MusicGenres_enum.COUNTRY_POP
        "ALTERNATIVE COUNTRY":
            return m_MusicGenres_enum.ALTERNATIVE_COUNTRY
        "BLUEGRASS GOSPEL":
            return m_MusicGenres_enum.BLUEGRASS_GOSPEL
        "HONKY TONK":
            return m_MusicGenres_enum.HONKY_TONK
        "WESTERN SWING":
            return m_MusicGenres_enum.WESTERN_SWING
        "NASHVILLE SOUND":
            return m_MusicGenres_enum.NASHVILLE_SOUND
        "BAKERSFIELD SOUND":
            return m_MusicGenres_enum.BAKERSFIELD_SOUND
        "COWBOY":
            return m_MusicGenres_enum.COWBOY
        "COUNTRY AND IRISH":
            return m_MusicGenres_enum.COUNTRY_AND_IRISH
        "CELTIC COUNTRY":
            return m_MusicGenres_enum.CELTIC_COUNTRY
        "ROCK":
            return m_MusicGenres_enum.ROCK
        "CLASSIC ROCK":
            return m_MusicGenres_enum.CLASSIC_ROCK
        "HARD ROCK":
            return m_MusicGenres_enum.HARD_ROCK
        "SOFT ROCK":
            return m_MusicGenres_enum.SOFT_ROCK
        "ARENA ROCK":
            return m_MusicGenres_enum.ARENA_ROCK
        "ROCK AND ROLL":
            return m_MusicGenres_enum.ROCK_AND_ROLL
        "GARAGE ROCK":
            return m_MusicGenres_enum.GARAGE_ROCK
        "PSYCHEDELIC ROCK":
            return m_MusicGenres_enum.PSYCHEDELIC_ROCK
        "PROGRESSIVE ROCK":
            return m_MusicGenres_enum.PROGRESSIVE_ROCK
        "ART ROCK":
            return m_MusicGenres_enum.ART_ROCK
        "GLAM ROCK":
            return m_MusicGenres_enum.GLAM_ROCK
        "PUB ROCK":
            return m_MusicGenres_enum.PUB_ROCK
        "INDIE ROCK":
            return m_MusicGenres_enum.INDIE_ROCK
        "ALTERNATIVE ROCK":
            return m_MusicGenres_enum.ALTERNATIVE_ROCK
        "COLLEGE ROCK":
            return m_MusicGenres_enum.COLLEGE_ROCK
        "POST ROCK":
            return m_MusicGenres_enum.POST_ROCK
        "SHOEGAZE":
            return m_MusicGenres_enum.SHOEGAZE
        "DREAM POP":
            return m_MusicGenres_enum.DREAM_POP
        "NOISE ROCK":
            return m_MusicGenres_enum.NOISE_ROCK
        "MATH ROCK":
            return m_MusicGenres_enum.MATH_ROCK
        "STONER ROCK":
            return m_MusicGenres_enum.STONER_ROCK
        "SLUDGE ROCK":
            return m_MusicGenres_enum.SLUDGE_ROCK
        "DESERT ROCK":
            return m_MusicGenres_enum.DESERT_ROCK
        "GRUNGE":
            return m_MusicGenres_enum.GRUNGE
        "BRITPOP":
            return m_MusicGenres_enum.BRITPOP
        "MADCHESTER":
            return m_MusicGenres_enum.MADCHESTER
        "NEW WAVE":
            return m_MusicGenres_enum.NEW_WAVE
        "SYNTH ROCK":
            return m_MusicGenres_enum.SYNTH_ROCK
        "POST PUNK":
            return m_MusicGenres_enum.POST_PUNK
        "GOTHIC ROCK":
            return m_MusicGenres_enum.GOTHIC_ROCK
        "INDUSTRIAL ROCK":
            return m_MusicGenres_enum.INDUSTRIAL_ROCK
        "PUNK":
            return m_MusicGenres_enum.PUNK
        "HARDCORE":
            return m_MusicGenres_enum.HARDCORE
        "HARDCORE PUNK":
            return m_MusicGenres_enum.HARDCORE_PUNK
        "POST HARDCORE":
            return m_MusicGenres_enum.POST_HARDCORE
        "POP PUNK":
            return m_MusicGenres_enum.POP_PUNK
        "SKATE PUNK":
            return m_MusicGenres_enum.SKATE_PUNK
        "OI":
            return m_MusicGenres_enum.OI
        "ANARCHO PUNK":
            return m_MusicGenres_enum.ANARCHO_PUNK
        "CRUST PUNK":
            return m_MusicGenres_enum.CRUST_PUNK
        "D BEAT":
            return m_MusicGenres_enum.D_BEAT
        "STREET PUNK":
            return m_MusicGenres_enum.STREET_PUNK
        "EMO":
            return m_MusicGenres_enum.EMO
        "EMO POP":
            return m_MusicGenres_enum.EMO_POP
        "SCREAMO":
            return m_MusicGenres_enum.SCREAMO
        "METAL":
            return m_MusicGenres_enum.METAL
        "HEAVY METAL":
            return m_MusicGenres_enum.HEAVY_METAL
        "THRASH METAL":
            return m_MusicGenres_enum.THRASH_METAL
        "SPEED METAL":
            return m_MusicGenres_enum.SPEED_METAL
        "POWER METAL":
            return m_MusicGenres_enum.POWER_METAL
        "PROGRESSIVE METAL":
            return m_MusicGenres_enum.PROGRESSIVE_METAL
        "DOOM METAL":
            return m_MusicGenres_enum.DOOM_METAL
        "SLUDGE METAL":
            return m_MusicGenres_enum.SLUDGE_METAL
        "STONER METAL":
            return m_MusicGenres_enum.STONER_METAL
        "BLACK METAL":
            return m_MusicGenres_enum.BLACK_METAL
        "SYMPHONIC BLACK METAL":
            return m_MusicGenres_enum.SYMPHONIC_BLACK_METAL
        "ATMOSPHERIC BLACK METAL":
            return m_MusicGenres_enum.ATMOSPHERIC_BLACK_METAL
        "DEATH METAL":
            return m_MusicGenres_enum.DEATH_METAL
        "MELODIC DEATH METAL":
            return m_MusicGenres_enum.MELODIC_DEATH_METAL
        "TECHNICAL DEATH METAL":
            return m_MusicGenres_enum.TECHNICAL_DEATH_METAL
        "DEATHCORE":
            return m_MusicGenres_enum.DEATHCORE
        "METALCORE":
            return m_MusicGenres_enum.METALCORE
        "GRINDCORE":
            return m_MusicGenres_enum.GRINDCORE
        "GOREGRIND":
            return m_MusicGenres_enum.GOREGRIND
        "NU METAL":
            return m_MusicGenres_enum.NU_METAL
        "INDUSTRIAL METAL":
            return m_MusicGenres_enum.INDUSTRIAL_METAL
        "FOLK METAL":
            return m_MusicGenres_enum.FOLK_METAL
        "VIKING METAL":
            return m_MusicGenres_enum.VIKING_METAL
        "GOTHIC METAL":
            return m_MusicGenres_enum.GOTHIC_METAL
        "SYMPHONIC METAL":
            return m_MusicGenres_enum.SYMPHONIC_METAL
        "POST METAL":
            return m_MusicGenres_enum.POST_METAL
        "POP":
            return m_MusicGenres_enum.POP
        "POP ROCK":
            return m_MusicGenres_enum.POP_ROCK
        "TEEN POP":
            return m_MusicGenres_enum.TEEN_POP
        "ELECTROPOP":
            return m_MusicGenres_enum.ELECTROPOP
        "SYNTHPOP":
            return m_MusicGenres_enum.SYNTHPOP
        "DANCE POP":
            return m_MusicGenres_enum.DANCE_POP
        "INDIE POP":
            return m_MusicGenres_enum.INDIE_POP
        "ART POP":
            return m_MusicGenres_enum.ART_POP
        "HYPERPOP":
            return m_MusicGenres_enum.HYPERPOP
        "CHAMBER POP":
            return m_MusicGenres_enum.CHAMBER_POP
        "BAROQUE POP":
            return m_MusicGenres_enum.BAROQUE_POP
        "SUNSHINE POP":
            return m_MusicGenres_enum.SUNSHINE_POP
        "EASY LISTENING":
            return m_MusicGenres_enum.EASY_LISTENING
        "ADULT CONTEMPORARY":
            return m_MusicGenres_enum.ADULT_CONTEMPORARY
        "BALLAD":
            return m_MusicGenres_enum.BALLAD
        "VOCAL POP":
            return m_MusicGenres_enum.VOCAL_POP
        "RANDB":
            return m_MusicGenres_enum.RANDB
        "CONTEMPORARY RANDB":
            return m_MusicGenres_enum.CONTEMPORARY_RANDB
        "NEO SOUL":
            return m_MusicGenres_enum.NEO_SOUL
        "SOUL":
            return m_MusicGenres_enum.SOUL
        "MOTOWN":
            return m_MusicGenres_enum.MOTOWN
        "NORTHERN SOUL":
            return m_MusicGenres_enum.NORTHERN_SOUL
        "SOUTHERN SOUL":
            return m_MusicGenres_enum.SOUTHERN_SOUL
        "FUNK":
            return m_MusicGenres_enum.FUNK
        "P FUNK":
            return m_MusicGenres_enum.P_FUNK
        "DISCO":
            return m_MusicGenres_enum.DISCO
        "BOOGIE":
            return m_MusicGenres_enum.BOOGIE
        "QUIET STORM":
            return m_MusicGenres_enum.QUIET_STORM
        "HIP HOP":
            return m_MusicGenres_enum.HIP_HOP
        "RAP":
            return m_MusicGenres_enum.RAP
        "OLD SCHOOL HIP HOP":
            return m_MusicGenres_enum.OLD_SCHOOL_HIP_HOP
        "GOLDEN AGE HIP HOP":
            return m_MusicGenres_enum.GOLDEN_AGE_HIP_HOP
        "BOOM BAP":
            return m_MusicGenres_enum.BOOM_BAP
        "CONSCIOUS HIP HOP":
            return m_MusicGenres_enum.CONSCIOUS_HIP_HOP
        "ALTERNATIVE HIP HOP":
            return m_MusicGenres_enum.ALTERNATIVE_HIP_HOP
        "EXPERIMENTAL HIP HOP":
            return m_MusicGenres_enum.EXPERIMENTAL_HIP_HOP
        "TRIP HOP":
            return m_MusicGenres_enum.TRIP_HOP
        "LO FI HIP HOP":
            return m_MusicGenres_enum.LO_FI_HIP_HOP
        "TRAP":
            return m_MusicGenres_enum.TRAP
        "DRILL":
            return m_MusicGenres_enum.DRILL
        "UK DRILL":
            return m_MusicGenres_enum.UK_DRILL
        "GRIME":
            return m_MusicGenres_enum.GRIME
        "CLOUD RAP":
            return m_MusicGenres_enum.CLOUD_RAP
        "CRUNK":
            return m_MusicGenres_enum.CRUNK
        "G FUNK":
            return m_MusicGenres_enum.G_FUNK
        "GANGSTA RAP":
            return m_MusicGenres_enum.GANGSTA_RAP
        "HORRORCORE":
            return m_MusicGenres_enum.HORRORCORE
        "MEMPHIS RAP":
            return m_MusicGenres_enum.MEMPHIS_RAP
        "PHONK":
            return m_MusicGenres_enum.PHONK
        "JAZZ RAP":
            return m_MusicGenres_enum.JAZZ_RAP
        "JAZZ":
            return m_MusicGenres_enum.JAZZ
        "TRADITIONAL JAZZ":
            return m_MusicGenres_enum.TRADITIONAL_JAZZ
        "DIXIELAND":
            return m_MusicGenres_enum.DIXIELAND
        "SWING":
            return m_MusicGenres_enum.SWING
        "BIG BAND":
            return m_MusicGenres_enum.BIG_BAND
        "BEBOP":
            return m_MusicGenres_enum.BEBOP
        "HARD BOP":
            return m_MusicGenres_enum.HARD_BOP
        "COOL JAZZ":
            return m_MusicGenres_enum.COOL_JAZZ
        "MODAL JAZZ":
            return m_MusicGenres_enum.MODAL_JAZZ
        "FREE JAZZ":
            return m_MusicGenres_enum.FREE_JAZZ
        "AVANT GARDE JAZZ":
            return m_MusicGenres_enum.AVANT_GARDE_JAZZ
        "JAZZ FUSION":
            return m_MusicGenres_enum.JAZZ_FUSION
        "SMOOTH JAZZ":
            return m_MusicGenres_enum.SMOOTH_JAZZ
        "VOCAL JAZZ":
            return m_MusicGenres_enum.VOCAL_JAZZ
        "LATIN JAZZ":
            return m_MusicGenres_enum.LATIN_JAZZ
        "ACID JAZZ":
            return m_MusicGenres_enum.ACID_JAZZ
        "CLASSICAL":
            return m_MusicGenres_enum.CLASSICAL
        "BAROQUE":
            return m_MusicGenres_enum.BAROQUE
        "CLASSICAL PERIOD":
            return m_MusicGenres_enum.CLASSICAL_PERIOD
        "ROMANTIC":
            return m_MusicGenres_enum.ROMANTIC
        "MODERN CLASSICAL":
            return m_MusicGenres_enum.MODERN_CLASSICAL
        "CONTEMPORARY CLASSICAL":
            return m_MusicGenres_enum.CONTEMPORARY_CLASSICAL
        "ORCHESTRAL":
            return m_MusicGenres_enum.ORCHESTRAL
        "CHAMBER MUSIC":
            return m_MusicGenres_enum.CHAMBER_MUSIC
        "OPERA":
            return m_MusicGenres_enum.OPERA
        "CHORAL":
            return m_MusicGenres_enum.CHORAL
        "SACRED":
            return m_MusicGenres_enum.SACRED
        "EARLY MUSIC":
            return m_MusicGenres_enum.EARLY_MUSIC
        "MINIMALISM":
            return m_MusicGenres_enum.MINIMALISM
        "AVANT GARDE":
            return m_MusicGenres_enum.AVANT_GARDE
        "SERIALISM":
            return m_MusicGenres_enum.SERIALISM
        "FILM SCORE":
            return m_MusicGenres_enum.FILM_SCORE
        "SOUNDTRACK":
            return m_MusicGenres_enum.SOUNDTRACK
        "VIDEO GAME MUSIC":
            return m_MusicGenres_enum.VIDEO_GAME_MUSIC
        "LIBRARY MUSIC":
            return m_MusicGenres_enum.LIBRARY_MUSIC
        "AMBIENT CLASSICAL":
            return m_MusicGenres_enum.AMBIENT_CLASSICAL
        "ELECTRONIC":
            return m_MusicGenres_enum.ELECTRONIC
        "EDM":
            return m_MusicGenres_enum.EDM
        "HOUSE":
            return m_MusicGenres_enum.HOUSE
        "CHICAGO HOUSE":
            return m_MusicGenres_enum.CHICAGO_HOUSE
        "DEEP HOUSE":
            return m_MusicGenres_enum.DEEP_HOUSE
        "SOULFUL HOUSE":
            return m_MusicGenres_enum.SOULFUL_HOUSE
        "FUNKY HOUSE":
            return m_MusicGenres_enum.FUNKY_HOUSE
        "DISCO HOUSE":
            return m_MusicGenres_enum.DISCO_HOUSE
        "NU DISCO":
            return m_MusicGenres_enum.NU_DISCO
        "ITALO DISCO":
            return m_MusicGenres_enum.ITALO_DISCO
        "ELECTRO DISCO":
            return m_MusicGenres_enum.ELECTRO_DISCO
        "JACKIN HOUSE":
            return m_MusicGenres_enum.JACKIN_HOUSE
        "LO FI HOUSE":
            return m_MusicGenres_enum.LO_FI_HOUSE
        "PROGRESSIVE HOUSE":
            return m_MusicGenres_enum.PROGRESSIVE_HOUSE
        "ELECTRO HOUSE":
            return m_MusicGenres_enum.ELECTRO_HOUSE
        "BIG ROOM":
            return m_MusicGenres_enum.BIG_ROOM
        "FUTURE HOUSE":
            return m_MusicGenres_enum.FUTURE_HOUSE
        "SLAP HOUSE":
            return m_MusicGenres_enum.SLAP_HOUSE
        "BASS HOUSE":
            return m_MusicGenres_enum.BASS_HOUSE
        "TECH HOUSE":
            return m_MusicGenres_enum.TECH_HOUSE
        "MINIMAL HOUSE":
            return m_MusicGenres_enum.MINIMAL_HOUSE
        "MICROHOUSE":
            return m_MusicGenres_enum.MICROHOUSE
        "GHETTO HOUSE":
            return m_MusicGenres_enum.GHETTO_HOUSE
        "ACID HOUSE":
            return m_MusicGenres_enum.ACID_HOUSE
        "TRIBAL HOUSE":
            return m_MusicGenres_enum.TRIBAL_HOUSE
        "AFRO HOUSE":
            return m_MusicGenres_enum.AFRO_HOUSE
        "LATIN HOUSE":
            return m_MusicGenres_enum.LATIN_HOUSE
        "BALEARIC BEAT":
            return m_MusicGenres_enum.BALEARIC_BEAT
        "GARAGE HOUSE":
            return m_MusicGenres_enum.GARAGE_HOUSE
        "HARD HOUSE":
            return m_MusicGenres_enum.HARD_HOUSE
        "PROGRESSIVE TRANCE":
            return m_MusicGenres_enum.PROGRESSIVE_TRANCE
        "DEEP TECH":
            return m_MusicGenres_enum.DEEP_TECH
        "TECHNO":
            return m_MusicGenres_enum.TECHNO
        "DETROIT TECHNO":
            return m_MusicGenres_enum.DETROIT_TECHNO
        "ACID TECHNO":
            return m_MusicGenres_enum.ACID_TECHNO
        "AMBIENT TECHNO":
            return m_MusicGenres_enum.AMBIENT_TECHNO
        "BLEEP TECHNO":
            return m_MusicGenres_enum.BLEEP_TECHNO
        "DEEP TECHNO":
            return m_MusicGenres_enum.DEEP_TECHNO
        "DUB TECHNO":
            return m_MusicGenres_enum.DUB_TECHNO
        "MINIMAL TECHNO":
            return m_MusicGenres_enum.MINIMAL_TECHNO
        "HARD TECHNO":
            return m_MusicGenres_enum.HARD_TECHNO
        "HARDGROOVE TECHNO":
            return m_MusicGenres_enum.HARDGROOVE_TECHNO
        "INDUSTRIAL TECHNO":
            return m_MusicGenres_enum.INDUSTRIAL_TECHNO
        "MELODIC TECHNO":
            return m_MusicGenres_enum.MELODIC_TECHNO
        "PEAK TIME TECHNO":
            return m_MusicGenres_enum.PEAK_TIME_TECHNO
        "SCHRANZ":
            return m_MusicGenres_enum.SCHRANZ
        "WONKY TECHNO":
            return m_MusicGenres_enum.WONKY_TECHNO
        "FREE TEKNO":
            return m_MusicGenres_enum.FREE_TEKNO
        "TEKNO":
            return m_MusicGenres_enum.TEKNO
        "MAKINA":
            return m_MusicGenres_enum.MAKINA
        "BERLIN TECHNO":
            return m_MusicGenres_enum.BERLIN_TECHNO
        "WAREHOUSE TECHNO":
            return m_MusicGenres_enum.WAREHOUSE_TECHNO
        "DRIVING TECHNO":
            return m_MusicGenres_enum.DRIVING_TECHNO
        "HYPNOTIC TECHNO":
            return m_MusicGenres_enum.HYPNOTIC_TECHNO
        "TRANCE":
            return m_MusicGenres_enum.TRANCE
        "UPLIFTING TRANCE":
            return m_MusicGenres_enum.UPLIFTING_TRANCE
        "VOCAL TRANCE":
            return m_MusicGenres_enum.VOCAL_TRANCE
        "TECH TRANCE":
            return m_MusicGenres_enum.TECH_TRANCE
        "HARD TRANCE":
            return m_MusicGenres_enum.HARD_TRANCE
        "GOA TRANCE":
            return m_MusicGenres_enum.GOA_TRANCE
        "PSYTRANCE":
            return m_MusicGenres_enum.PSYTRANCE
        "ACID TRANCE":
            return m_MusicGenres_enum.ACID_TRANCE
        "DREAM TRANCE":
            return m_MusicGenres_enum.DREAM_TRANCE
        "ELECTRO":
            return m_MusicGenres_enum.ELECTRO
        "ELECTROCLASH":
            return m_MusicGenres_enum.ELECTROCLASH
        "BREAKBEAT":
            return m_MusicGenres_enum.BREAKBEAT
        "BREAKS":
            return m_MusicGenres_enum.BREAKS
        "BIG BEAT":
            return m_MusicGenres_enum.BIG_BEAT
        "NU SKOOL BREAKS":
            return m_MusicGenres_enum.NU_SKOOL_BREAKS
        "BROKEN BEAT":
            return m_MusicGenres_enum.BROKEN_BEAT
        "FUTURE BASS":
            return m_MusicGenres_enum.FUTURE_BASS
        "MIDTEMPO BASS":
            return m_MusicGenres_enum.MIDTEMPO_BASS
        "GLITCH HOP":
            return m_MusicGenres_enum.GLITCH_HOP
        "IDM":
            return m_MusicGenres_enum.IDM
        "GLITCH":
            return m_MusicGenres_enum.GLITCH
        "EXPERIMENTAL ELECTRONIC":
            return m_MusicGenres_enum.EXPERIMENTAL_ELECTRONIC
        "EDM TRAP":
            return m_MusicGenres_enum.EDM_TRAP
        "AMBIENT":
            return m_MusicGenres_enum.AMBIENT
        "DARK AMBIENT":
            return m_MusicGenres_enum.DARK_AMBIENT
        "DRONE":
            return m_MusicGenres_enum.DRONE
        "CHILLOUT":
            return m_MusicGenres_enum.CHILLOUT
        "DOWNTEMPO":
            return m_MusicGenres_enum.DOWNTEMPO
        "PSYBIENT":
            return m_MusicGenres_enum.PSYBIENT
        "PSYDUB":
            return m_MusicGenres_enum.PSYDUB
        "INDUSTRIAL":
            return m_MusicGenres_enum.INDUSTRIAL
        "EBM":
            return m_MusicGenres_enum.EBM
        "INDUSTRIAL DANCE":
            return m_MusicGenres_enum.INDUSTRIAL_DANCE
        "HARD DANCE":
            return m_MusicGenres_enum.HARD_DANCE
        "HARDSTYLE":
            return m_MusicGenres_enum.HARDSTYLE
        "RAWSTYLE":
            return m_MusicGenres_enum.RAWSTYLE
        "JUMPSTYLE":
            return m_MusicGenres_enum.JUMPSTYLE
        "HANDS UP":
            return m_MusicGenres_enum.HANDS_UP
        "HARD NRG":
            return m_MusicGenres_enum.HARD_NRG
        "EURODANCE":
            return m_MusicGenres_enum.EURODANCE
        "ITALO DANCE":
            return m_MusicGenres_enum.ITALO_DANCE
        "HI NRG":
            return m_MusicGenres_enum.HI_NRG
        "RAVE":
            return m_MusicGenres_enum.RAVE
        "OLDSKOOL RAVE":
            return m_MusicGenres_enum.OLDSKOOL_RAVE
        "HARDCORE RAVE":
            return m_MusicGenres_enum.HARDCORE_RAVE
        "UK BASS":
            return m_MusicGenres_enum.UK_BASS
        "BREAKBEAT HARDCORE":
            return m_MusicGenres_enum.BREAKBEAT_HARDCORE
        "DARKCORE":
            return m_MusicGenres_enum.DARKCORE
        "HARDCORE BREAKS":
            return m_MusicGenres_enum.HARDCORE_BREAKS
        "JUNGLE":
            return m_MusicGenres_enum.JUNGLE
        "RAGGA JUNGLE":
            return m_MusicGenres_enum.RAGGA_JUNGLE
        "DRUM AND BASS":
            return m_MusicGenres_enum.DRUM_AND_BASS
        "ATMOSPHERIC DRUM AND BASS":
            return m_MusicGenres_enum.ATMOSPHERIC_DRUM_AND_BASS
        "DANCEFLOOR DRUM AND BASS":
            return m_MusicGenres_enum.DANCEFLOOR_DRUM_AND_BASS
        "DARKSTEP":
            return m_MusicGenres_enum.DARKSTEP
        "DEEP DRUM AND BASS":
            return m_MusicGenres_enum.DEEP_DRUM_AND_BASS
        "DRILL AND BASS":
            return m_MusicGenres_enum.DRILL_AND_BASS
        "DRUMFUNK":
            return m_MusicGenres_enum.DRUMFUNK
        "DRUMSTEP":
            return m_MusicGenres_enum.DRUMSTEP
        "DUBWISE":
            return m_MusicGenres_enum.DUBWISE
        "HALFTIME":
            return m_MusicGenres_enum.HALFTIME
        "HARDSTEP":
            return m_MusicGenres_enum.HARDSTEP
        "JAZZSTEP":
            return m_MusicGenres_enum.JAZZSTEP
        "JUMP UP":
            return m_MusicGenres_enum.JUMP_UP
        "LIQUID FUNK":
            return m_MusicGenres_enum.LIQUID_FUNK
        "MINIMAL DRUM AND BASS":
            return m_MusicGenres_enum.MINIMAL_DRUM_AND_BASS
        "NEUROFUNK":
            return m_MusicGenres_enum.NEUROFUNK
        "TECHSTEP":
            return m_MusicGenres_enum.TECHSTEP
        "TRANCESTEP":
            return m_MusicGenres_enum.TRANCESTEP
        "TECHNOID":
            return m_MusicGenres_enum.TECHNOID
        "LIQUID DRUM AND BASS":
            return m_MusicGenres_enum.LIQUID_DRUM_AND_BASS
        "UK GARAGE":
            return m_MusicGenres_enum.UK_GARAGE
        "TWO STEP":
            return m_MusicGenres_enum.TWO_STEP
        "SPEED GARAGE":
            return m_MusicGenres_enum.SPEED_GARAGE
        "FUTURE GARAGE":
            return m_MusicGenres_enum.FUTURE_GARAGE
        "BREAKSTEP":
            return m_MusicGenres_enum.BREAKSTEP
        "BASSLINE":
            return m_MusicGenres_enum.BASSLINE
        "UK FUNKY":
            return m_MusicGenres_enum.UK_FUNKY
        "DUBSTEP":
            return m_MusicGenres_enum.DUBSTEP
        "BROSTEP":
            return m_MusicGenres_enum.BROSTEP
        "RIDDIM":
            return m_MusicGenres_enum.RIDDIM
        "POST DUBSTEP":
            return m_MusicGenres_enum.POST_DUBSTEP
        "WOBBLESTEP":
            return m_MusicGenres_enum.WOBBLESTEP
        "HARDCORE TECHNO":
            return m_MusicGenres_enum.HARDCORE_TECHNO
        "GABBER":
            return m_MusicGenres_enum.GABBER
        "HAPPY HARDCORE":
            return m_MusicGenres_enum.HAPPY_HARDCORE
        "FREEFORM HARDCORE":
            return m_MusicGenres_enum.FREEFORM_HARDCORE
        "FRENCHCORE":
            return m_MusicGenres_enum.FRENCHCORE
        "DOOMCORE":
            return m_MusicGenres_enum.DOOMCORE
        "INDUSTRIAL HARDCORE":
            return m_MusicGenres_enum.INDUSTRIAL_HARDCORE
        "SPEEDCORE":
            return m_MusicGenres_enum.SPEEDCORE
        "TERRORCORE":
            return m_MusicGenres_enum.TERRORCORE
        "UPTEMPO HARDCORE":
            return m_MusicGenres_enum.UPTEMPO_HARDCORE
        "POWERSTOMP":
            return m_MusicGenres_enum.POWERSTOMP
        "J CORE":
            return m_MusicGenres_enum.J_CORE
        "MODERN HARDTEK":
            return m_MusicGenres_enum.MODERN_HARDTEK
        "RAGGATEK":
            return m_MusicGenres_enum.RAGGATEK
        "PUMPCORE":
            return m_MusicGenres_enum.PUMPCORE
        "BREAKCORE":
            return m_MusicGenres_enum.BREAKCORE
        "EXTRATONE":
            return m_MusicGenres_enum.EXTRATONE
        "SPLITTERCORE":
            return m_MusicGenres_enum.SPLITTERCORE
        "DONK":
            return m_MusicGenres_enum.DONK
        "SCOUSE HOUSE":
            return m_MusicGenres_enum.SCOUSE_HOUSE
        "REGGAE":
            return m_MusicGenres_enum.REGGAE
        "ROOTS REGGAE":
            return m_MusicGenres_enum.ROOTS_REGGAE
        "DUB":
            return m_MusicGenres_enum.DUB
        "DANCEHALL":
            return m_MusicGenres_enum.DANCEHALL
        "ROCKSTEADY":
            return m_MusicGenres_enum.ROCKSTEADY
        "SKA":
            return m_MusicGenres_enum.SKA
        "TWO TONE":
            return m_MusicGenres_enum.TWO_TONE
        "REGGAETON":
            return m_MusicGenres_enum.REGGAETON
        "SOCA":
            return m_MusicGenres_enum.SOCA
        "CALYPSO":
            return m_MusicGenres_enum.CALYPSO
        "LATIN":
            return m_MusicGenres_enum.LATIN
        "SALSA":
            return m_MusicGenres_enum.SALSA
        "BACHATA":
            return m_MusicGenres_enum.BACHATA
        "MERENGUE":
            return m_MusicGenres_enum.MERENGUE
        "CUMBIA":
            return m_MusicGenres_enum.CUMBIA
        "CUMBIA SONIDERA":
            return m_MusicGenres_enum.CUMBIA_SONIDERA
        "TEJANO":
            return m_MusicGenres_enum.TEJANO
        "NORTENO":
            return m_MusicGenres_enum.NORTENO
        "BANDA":
            return m_MusicGenres_enum.BANDA
        "MARIACHI":
            return m_MusicGenres_enum.MARIACHI
        "RANCHERA":
            return m_MusicGenres_enum.RANCHERA
        "LATIN POP":
            return m_MusicGenres_enum.LATIN_POP
        "LATIN ROCK":
            return m_MusicGenres_enum.LATIN_ROCK
        "BOSSA NOVA":
            return m_MusicGenres_enum.BOSSA_NOVA
        "SAMBA":
            return m_MusicGenres_enum.SAMBA
        "MPB":
            return m_MusicGenres_enum.MPB
        "FORRO":
            return m_MusicGenres_enum.FORRO
        "PAGODE":
            return m_MusicGenres_enum.PAGODE
        "TANGO":
            return m_MusicGenres_enum.TANGO
        "FLAMENCO":
            return m_MusicGenres_enum.FLAMENCO
        "FADO":
            return m_MusicGenres_enum.FADO
        "HIGHLIFE":
            return m_MusicGenres_enum.HIGHLIFE
        "AFROBEAT":
            return m_MusicGenres_enum.AFROBEAT
        "AFROBEATS":
            return m_MusicGenres_enum.AFROBEATS
        "AMAPIANO":
            return m_MusicGenres_enum.AMAPIANO
        "KWAITO":
            return m_MusicGenres_enum.KWAITO
        "GQOM":
            return m_MusicGenres_enum.GQOM
        "SOUKOUS":
            return m_MusicGenres_enum.SOUKOUS
        "MAKOSSA":
            return m_MusicGenres_enum.MAKOSSA
        "MBALAX":
            return m_MusicGenres_enum.MBALAX
        "GNAWA":
            return m_MusicGenres_enum.GNAWA
        "RAI":
            return m_MusicGenres_enum.RAI
        "AFROPOP":
            return m_MusicGenres_enum.AFROPOP
        "ARABIC POP":
            return m_MusicGenres_enum.ARABIC_POP
        "ARABESQUE":
            return m_MusicGenres_enum.ARABESQUE
        "DABKE":
            return m_MusicGenres_enum.DABKE
        "TURKISH POP":
            return m_MusicGenres_enum.TURKISH_POP
        "TURKISH FOLK":
            return m_MusicGenres_enum.TURKISH_FOLK
        "PERSIAN POP":
            return m_MusicGenres_enum.PERSIAN_POP
        "PERSIAN TRADITIONAL":
            return m_MusicGenres_enum.PERSIAN_TRADITIONAL
        "ANATOLIAN ROCK":
            return m_MusicGenres_enum.ANATOLIAN_ROCK
        "QAWWALI":
            return m_MusicGenres_enum.QAWWALI
        "SUFI":
            return m_MusicGenres_enum.SUFI
        "INDIAN CLASSICAL":
            return m_MusicGenres_enum.INDIAN_CLASSICAL
        "HINDUSTANI CLASSICAL":
            return m_MusicGenres_enum.HINDUSTANI_CLASSICAL
        "CARNATIC":
            return m_MusicGenres_enum.CARNATIC
        "BOLLYWOOD":
            return m_MusicGenres_enum.BOLLYWOOD
        "BHANGRA":
            return m_MusicGenres_enum.BHANGRA
        "GHAZAL":
            return m_MusicGenres_enum.GHAZAL
        "DESI HIP HOP":
            return m_MusicGenres_enum.DESI_HIP_HOP
        "PAKISTANI POP":
            return m_MusicGenres_enum.PAKISTANI_POP
        "C POP":
            return m_MusicGenres_enum.C_POP
        "MANDOPOP":
            return m_MusicGenres_enum.MANDOPOP
        "CANTOPOP":
            return m_MusicGenres_enum.CANTOPOP
        "HOKKIEN POP":
            return m_MusicGenres_enum.HOKKIEN_POP
        "HAKKA POP":
            return m_MusicGenres_enum.HAKKA_POP
        "SHIDAIQU":
            return m_MusicGenres_enum.SHIDAIQU
        "GUOYUE":
            return m_MusicGenres_enum.GUOYUE
        "CHINESE TRADITIONAL":
            return m_MusicGenres_enum.CHINESE_TRADITIONAL
        "CHINESE FOLK":
            return m_MusicGenres_enum.CHINESE_FOLK
        "CHINESE OPERA":
            return m_MusicGenres_enum.CHINESE_OPERA
        "PEKING OPERA":
            return m_MusicGenres_enum.PEKING_OPERA
        "KUNQU":
            return m_MusicGenres_enum.KUNQU
        "YUE OPERA":
            return m_MusicGenres_enum.YUE_OPERA
        "CANTONESE OPERA":
            return m_MusicGenres_enum.CANTONESE_OPERA
        "JIANGNAN SIZHU":
            return m_MusicGenres_enum.JIANGNAN_SIZHU
        "NANYIN":
            return m_MusicGenres_enum.NANYIN
        "K POP":
            return m_MusicGenres_enum.K_POP
        "J POP":
            return m_MusicGenres_enum.J_POP
        "KAYOKYOKU":
            return m_MusicGenres_enum.KAYOKYOKU
        "ENKA":
            return m_MusicGenres_enum.ENKA
        "VISUAL KEI":
            return m_MusicGenres_enum.VISUAL_KEI
        "J ROCK":
            return m_MusicGenres_enum.J_ROCK
        "J HIP HOP":
            return m_MusicGenres_enum.J_HIP_HOP
        "CITY POP":
            return m_MusicGenres_enum.CITY_POP
        "K ROCK":
            return m_MusicGenres_enum.K_ROCK
        "T POP":
            return m_MusicGenres_enum.T_POP
        "THAI POP":
            return m_MusicGenres_enum.THAI_POP
        "V POP":
            return m_MusicGenres_enum.V_POP
        "VIET POP":
            return m_MusicGenres_enum.VIET_POP
        "PINOY POP":
            return m_MusicGenres_enum.PINOY_POP
        "ORIGINAL PILIPINO MUSIC":
            return m_MusicGenres_enum.ORIGINAL_PILIPINO_MUSIC
        "GAMELAN":
            return m_MusicGenres_enum.GAMELAN
        "DANGDUT":
            return m_MusicGenres_enum.DANGDUT
        "KRONCONG":
            return m_MusicGenres_enum.KRONCONG
        "RUSSIAN CHANSON":
            return m_MusicGenres_enum.RUSSIAN_CHANSON
        "ESTRADA":
            return m_MusicGenres_enum.ESTRADA
        "RUSSIAN ROMANCE":
            return m_MusicGenres_enum.RUSSIAN_ROMANCE
        "BARD SONG":
            return m_MusicGenres_enum.BARD_SONG
        "RUSSIAN FOLK":
            return m_MusicGenres_enum.RUSSIAN_FOLK
        "SLAVIC FOLK":
            return m_MusicGenres_enum.SLAVIC_FOLK
        "TUVAN THROAT SINGING":
            return m_MusicGenres_enum.TUVAN_THROAT_SINGING
        "HARDBASS":
            return m_MusicGenres_enum.HARDBASS
        "RUSSIAN ORTHODOX LITURGICAL":
            return m_MusicGenres_enum.RUSSIAN_ORTHODOX_LITURGICAL
        "CELTIC":
            return m_MusicGenres_enum.CELTIC
        "IRISH TRADITIONAL":
            return m_MusicGenres_enum.IRISH_TRADITIONAL
        "IRISH FOLK":
            return m_MusicGenres_enum.IRISH_FOLK
        "SEAN NOS":
            return m_MusicGenres_enum.SEAN_NOS
        "CELTIC ROCK":
            return m_MusicGenres_enum.CELTIC_ROCK
        "CELTIC PUNK":
            return m_MusicGenres_enum.CELTIC_PUNK
        "SCOTTISH TRADITIONAL":
            return m_MusicGenres_enum.SCOTTISH_TRADITIONAL
        "BRETON FOLK":
            return m_MusicGenres_enum.BRETON_FOLK
        "INSTRUMENTAL":
            return m_MusicGenres_enum.INSTRUMENTAL
        "A CAPPELLA":
            return m_MusicGenres_enum.A_CAPPELLA
        "LIVE":
            return m_MusicGenres_enum.LIVE
        "SPOKEN WORD":
            return m_MusicGenres_enum.SPOKEN_WORD
        "COMEDY":
            return m_MusicGenres_enum.COMEDY
        "AUDIOBOOK":
            return m_MusicGenres_enum.AUDIOBOOK
        "PODCAST":
            return m_MusicGenres_enum.PODCAST
        "KIDS":
            return m_MusicGenres_enum.KIDS
        "HOLIDAY":
            return m_MusicGenres_enum.HOLIDAY
        "CHRISTMAS":
            return m_MusicGenres_enum.CHRISTMAS
        "WEDDING":
            return m_MusicGenres_enum.WEDDING
        "MEDITATION":
            return m_MusicGenres_enum.MEDITATION
        "ASMR":
            return m_MusicGenres_enum.ASMR
        "FITNESS":
            return m_MusicGenres_enum.FITNESS
        "WORKOUT":
            return m_MusicGenres_enum.WORKOUT
        "STUDY":
            return m_MusicGenres_enum.STUDY
        "SLEEP":
            return m_MusicGenres_enum.SLEEP
        "NATURE":
            return m_MusicGenres_enum.NATURE
        _:
            return m_MusicGenres_enum.UNKNOWN