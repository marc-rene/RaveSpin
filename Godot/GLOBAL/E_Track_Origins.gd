extends "res://Scripts/EnumManager.gd"



# All possible origins / platforms that we could get a song from
const Track_Origins_str: Array[StringName] = [
    "Other",

    # MAIN Local options
    "Local Storage",
    "Local Network (SMB)",        # Windows/NAS file share
    "Local Network (DLNA/UPnP)",  # Media server discovery/streaming on LAN
    "Direct URL (HTTP)",
    "FTP",                        # Legacy file transfer protocol
    "SFTP",                       # SSH File Transfer Protocol
    
    # major streaming
    "Spotify",
    "Apple Music",
    "Amazon Music",
    "YouTube Music",
    "Deezer",
    "TIDAL",
    "Qobuz",
    "Pandora",
    "iHeartRadio",
    "Napster",      # Apparantly it STILL exists??
    "iTunes Store",

    # cloud storage - If someone else makes a good enough API?
    "OneDrive",
    "Google Drive",
    "Dropbox",
    "iCloud Drive",
    "MEGA",
    "Nextcloud",
    
    # misc platforms
    "SoundCloud",
    "Bandcamp",
    "YouTube",
    "TikTok",
    "Instagram (Music)",
    "Mixcloud",
    "Audiomack",
    "HearThis.at",
    "Reverb Nation",

    # DJ-specfic
    "Beatport",
    "Beatsource",
    "Traxsource",
    "Juno Download",
    "7-Digital",                 
    "HDtracks",                 
    "Bleep",                    
    "Boomkat",                  
    "BPM Supreme",              
    "DJcity",                   
    "ZIPDJ",                    
    "Digital DJ Pool",          
    "Direct Music Service (DMS)",

    # Russia / bloc
    "Yandex Music",
    "VK Music",
    "Zvuk", # СберЗвук
    "Odnoklassniki Music",
    "MTS Music",
    "BOOM (VK/UMA)",

    # China
    "QQ Music",
    "NetEase Cloud Music", # 163 music
    "KuGou Music",
    "KuWo Music",
    "Migu Music",
    "Xiami (legacy)", #metadata only

    # Japan / Korea / Taiwan
    "Line Music",
    "AWA",
    "Recochoku",
    "KKBOX",
    "Melon",
    "Genie Music",
    "FLO",

    # India / South Asia
    "JioSaavn", # Jio + Saavn merge
    "Gaana",
    "Wynk Music",
    "Hungama Music", # metadata only

    # Vietnam + neighbours
    "MOOV",    
    "JOOX", 
    "Zing MP3",
    "NhacCuaTui",                 
    "Langit Musik",

    # Africa + Arabia
    "Anghami",
    "Boomplay",
    "Mdundo",

    # mostly classics
    "Naxos Music Library",
]




static func Track_Origin_toString(origin : Track_Origins_enum) -> StringName:
    return Track_Origins_str[origin]
    
    
static func Track_Origin_toEnum(origin : StringName) -> Track_Origins_enum:
    var index = Track_Origins_str.find(origin)
    if index < 0:
        index = 0
        printerr("%s isn't a valid platform??? Assuming it's %s" % [origin, Track_Origins_str[index]])
    
   # var plat = Track_Origins_enum[index]
    
    return Track_Origins_enum[Convert_String_to_Enum(Track_Origins_str[index])]




### INSERT ENUM VERSION HERE ###

# An Enum version of the Track_Origins_str Array
enum Track_Origins_enum {   OTHER,                  LOCAL_STORAGE,          LOCAL_NETWORK_SMB,      
                            LOCAL_NETWORK_DLNA_UPNP, DIRECT_URL_HTTP,        FTP,                    
                            SFTP,                   SPOTIFY,                APPLE_MUSIC,            
                            AMAZON_MUSIC,           YOUTUBE_MUSIC,          DEEZER,                 
                            TIDAL,                  QOBUZ,                  PANDORA,                
                            IHEARTRADIO,            NAPSTER,                ITUNES_STORE,           
                            ONEDRIVE,               GOOGLE_DRIVE,           DROPBOX,                
                            ICLOUD_DRIVE,           MEGA,                   NEXTCLOUD,              
                            SOUNDCLOUD,             BANDCAMP,               YOUTUBE,                
                            TIKTOK,                 INSTAGRAM_MUSIC,        MIXCLOUD,               
                            AUDIOMACK,              HEARTHIS_AT,            REVERB_NATION,          
                            BEATPORT,               BEATSOURCE,             TRAXSOURCE,             
                            JUNO_DOWNLOAD,          DIGITAL7,               HDTRACKS,               
                            BLEEP,                  BOOMKAT,                BPM_SUPREME,            
                            DJCITY,                 ZIPDJ,                  DIGITAL_DJ_POOL,        
                            DIRECT_MUSIC_SERVICE_DMS, YANDEX_MUSIC,           VK_MUSIC,               
                            ZVUK,                   ODNOKLASSNIKI_MUSIC,    MTS_MUSIC,              
                            BOOM_VK_UMA,            QQ_MUSIC,               NETEASE_CLOUD_MUSIC,    
                            KUGOU_MUSIC,            KUWO_MUSIC,             MIGU_MUSIC,             
                            XIAMI_LEGACY,           LINE_MUSIC,             AWA,                    
                            RECOCHOKU,              KKBOX,                  MELON,                  
                            GENIE_MUSIC,            FLO,                    JIOSAAVN,               
                            GAANA,                  WYNK_MUSIC,             HUNGAMA_MUSIC,          
                            MOOV,                   JOOX,                   ZING_MP3,               
                            NHACCUATUI,             LANGIT_MUSIK,           ANGHAMI,                
                            BOOMPLAY,               MDUNDO,                 NAXOS_MUSIC_LIBRARY,    
                            }
