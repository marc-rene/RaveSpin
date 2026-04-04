extends Object
class_name ETrackOrigins

## Track origin catalogue.
## Maps platform labels to enum values and optional logo textures.

## All known source platform labels used by metadata and UI.
const Track_Origins_str : Array[StringName] = [
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




## Converts origin enum to display string.
static func Track_Origin_toString(origin : Track_Origins_enum) -> StringName:
    return Track_Origins_str[origin]
    
    
## Converts origin display string to enum value.
static func Track_Origin_toEnum(origin : StringName) -> Track_Origins_enum:
    var index = Track_Origins_str.find(origin)
    if index < 0:
        index = 0
        printerr("%s isn't a valid platform??? Assuming it's %s" % [origin, Track_Origins_str[index]])
    
    # var plat = Track_Origins_enum[index]
    #return Track_Origins_enum[Convert_String_to_Enum(Track_Origins_str[index])]
    return Track_Origins_str_to_Track_Origins_enum(origin.to_upper())


## Returns UI logo texture path for a given source platform.
static func Get_Origin_Platform_Logo(platform : Track_Origins_enum) -> StringName:
    match platform:
        Track_Origins_enum.LOCAL_STORAGE:
            return "res://Art/Icon/Streaming_Platforms/T_LocalStorage.png"
            
        Track_Origins_enum.LOCAL_NETWORK_SMB:
            return "res://Art/Icon/Streaming_Platforms/T_LAN.png"
        Track_Origins_enum.LOCAL_NETWORK_DLNA_UPNP:
            return "res://Art/Icon/Streaming_Platforms/T_LAN.png"
            
        Track_Origins_enum.FTP:
            return "res://Art/Icon/Streaming_Platforms/T_FTP.png"
        Track_Origins_enum.SFTP:
            return "res://Art/Icon/Streaming_Platforms/T_FTP.png"
            
        Track_Origins_enum.SPOTIFY:
            return "res://Art/Icon/Streaming_Platforms/T_Spotify.png"
            
        Track_Origins_enum.APPLE_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_AppleMusic.png"
        Track_Origins_enum.ITUNES_STORE:
            return "res://Art/Icon/Streaming_Platforms/T_iTunes.png"
            
        Track_Origins_enum.AMAZON_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_AmazonMusic.png"
            
        Track_Origins_enum.YOUTUBE_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_YouTube_Music.png"
        Track_Origins_enum.YOUTUBE:
            return "res://Art/Icon/Streaming_Platforms/T_YouTube_Regular.png"
            
        Track_Origins_enum.DEEZER:
            return "res://Art/Icon/Streaming_Platforms/T_Deezer.png"
            
        Track_Origins_enum.TIDAL:
            return "res://Art/Icon/Streaming_Platforms/T_Tidal.png"
        
        Track_Origins_enum.NAPSTER:
            return "res://Art/Icon/Streaming_Platforms/T_Napster.png"
        
        Track_Origins_enum.ONEDRIVE:
            return "res://Art/Icon/Streaming_Platforms/T_OneDrive.png"
        
        Track_Origins_enum.GOOGLE_DRIVE:
            return "res://Art/Icon/Streaming_Platforms/T_GoogleDrive.png"
        
        Track_Origins_enum.DROPBOX:
            return "res://Art/Icon/Streaming_Platforms/T_DropBox.png"
        
        Track_Origins_enum.MEGA:
            return "res://Art/Icon/Streaming_Platforms/T_MEGA.png"
        
        Track_Origins_enum.SOUNDCLOUD:
            return "res://Art/Icon/Streaming_Platforms/T_SoundCloud.png"
        
        Track_Origins_enum.TIKTOK:
            return "res://Art/Icon/Streaming_Platforms/T_TikTok.png"
        
        Track_Origins_enum.YANDEX_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_YandexMusic.png"
        
        Track_Origins_enum.VK_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_VKMusic.png"
        
        Track_Origins_enum.QQ_MUSIC:
            return "res://Art/Icon/Streaming_Platforms/T_QQMusic.png"
        
        _:
            return "res://Art/Icon/Streaming_Platforms/T_GenericDatabase.png"
        
        
        
        


### INSERT ENUM VERSION HERE ###

## Enum version of `Track_Origins_str`.
enum Track_Origins_enum {OTHER,                  LOCAL_STORAGE,          LOCAL_NETWORK_SMB,      
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

## Converts platform label text to enum value.
## Input should be uppercase for exact match behaviour.

static func Track_Origins_str_to_Track_Origins_enum(string_version : String):
    match string_version:
        "OTHER":
            return Track_Origins_enum.OTHER
        "LOCAL STORAGE":
            return Track_Origins_enum.LOCAL_STORAGE
        "LOCAL NETWORK (SMB)":
            return Track_Origins_enum.LOCAL_NETWORK_SMB
        "LOCAL NETWORK (DLNA/UPNP)":
            return Track_Origins_enum.LOCAL_NETWORK_DLNA_UPNP
        "DIRECT URL (HTTP)":
            return Track_Origins_enum.DIRECT_URL_HTTP
        "FTP":
            return Track_Origins_enum.FTP
        "SFTP":
            return Track_Origins_enum.SFTP
        "SPOTIFY":
            return Track_Origins_enum.SPOTIFY
        "APPLE MUSIC":
            return Track_Origins_enum.APPLE_MUSIC
        "AMAZON MUSIC":
            return Track_Origins_enum.AMAZON_MUSIC
        "YOUTUBE MUSIC":
            return Track_Origins_enum.YOUTUBE_MUSIC
        "DEEZER":
            return Track_Origins_enum.DEEZER
        "TIDAL":
            return Track_Origins_enum.TIDAL
        "QOBUZ":
            return Track_Origins_enum.QOBUZ
        "PANDORA":
            return Track_Origins_enum.PANDORA
        "IHEARTRADIO":
            return Track_Origins_enum.IHEARTRADIO
        "NAPSTER":
            return Track_Origins_enum.NAPSTER
        "ITUNES STORE":
            return Track_Origins_enum.ITUNES_STORE
        "ONEDRIVE":
            return Track_Origins_enum.ONEDRIVE
        "GOOGLE DRIVE":
            return Track_Origins_enum.GOOGLE_DRIVE
        "DROPBOX":
            return Track_Origins_enum.DROPBOX
        "ICLOUD DRIVE":
            return Track_Origins_enum.ICLOUD_DRIVE
        "MEGA":
            return Track_Origins_enum.MEGA
        "NEXTCLOUD":
            return Track_Origins_enum.NEXTCLOUD
        "SOUNDCLOUD":
            return Track_Origins_enum.SOUNDCLOUD
        "BANDCAMP":
            return Track_Origins_enum.BANDCAMP
        "YOUTUBE":
            return Track_Origins_enum.YOUTUBE
        "TIKTOK":
            return Track_Origins_enum.TIKTOK
        "INSTAGRAM (MUSIC)":
            return Track_Origins_enum.INSTAGRAM_MUSIC
        "MIXCLOUD":
            return Track_Origins_enum.MIXCLOUD
        "AUDIOMACK":
            return Track_Origins_enum.AUDIOMACK
        "HEARTHIS.AT":
            return Track_Origins_enum.HEARTHIS_AT
        "REVERB NATION":
            return Track_Origins_enum.REVERB_NATION
        "BEATPORT":
            return Track_Origins_enum.BEATPORT
        "BEATSOURCE":
            return Track_Origins_enum.BEATSOURCE
        "TRAXSOURCE":
            return Track_Origins_enum.TRAXSOURCE
        "JUNO DOWNLOAD":
            return Track_Origins_enum.JUNO_DOWNLOAD
        "7-DIGITAL":
            return Track_Origins_enum.DIGITAL7
        "HDTRACKS":
            return Track_Origins_enum.HDTRACKS
        "BLEEP":
            return Track_Origins_enum.BLEEP
        "BOOMKAT":
            return Track_Origins_enum.BOOMKAT
        "BPM SUPREME":
            return Track_Origins_enum.BPM_SUPREME
        "DJCITY":
            return Track_Origins_enum.DJCITY
        "ZIPDJ":
            return Track_Origins_enum.ZIPDJ
        "DIGITAL DJ POOL":
            return Track_Origins_enum.DIGITAL_DJ_POOL
        "DIRECT MUSIC SERVICE (DMS)":
            return Track_Origins_enum.DIRECT_MUSIC_SERVICE_DMS
        "YANDEX MUSIC":
            return Track_Origins_enum.YANDEX_MUSIC
        "VK MUSIC":
            return Track_Origins_enum.VK_MUSIC
        "ZVUK":
            return Track_Origins_enum.ZVUK
        "ODNOKLASSNIKI MUSIC":
            return Track_Origins_enum.ODNOKLASSNIKI_MUSIC
        "MTS MUSIC":
            return Track_Origins_enum.MTS_MUSIC
        "BOOM (VK/UMA)":
            return Track_Origins_enum.BOOM_VK_UMA
        "QQ MUSIC":
            return Track_Origins_enum.QQ_MUSIC
        "NETEASE CLOUD MUSIC":
            return Track_Origins_enum.NETEASE_CLOUD_MUSIC
        "KUGOU MUSIC":
            return Track_Origins_enum.KUGOU_MUSIC
        "KUWO MUSIC":
            return Track_Origins_enum.KUWO_MUSIC
        "MIGU MUSIC":
            return Track_Origins_enum.MIGU_MUSIC
        "XIAMI (LEGACY)":
            return Track_Origins_enum.XIAMI_LEGACY
        "LINE MUSIC":
            return Track_Origins_enum.LINE_MUSIC
        "AWA":
            return Track_Origins_enum.AWA
        "RECOCHOKU":
            return Track_Origins_enum.RECOCHOKU
        "KKBOX":
            return Track_Origins_enum.KKBOX
        "MELON":
            return Track_Origins_enum.MELON
        "GENIE MUSIC":
            return Track_Origins_enum.GENIE_MUSIC
        "FLO":
            return Track_Origins_enum.FLO
        "JIOSAAVN":
            return Track_Origins_enum.JIOSAAVN
        "GAANA":
            return Track_Origins_enum.GAANA
        "WYNK MUSIC":
            return Track_Origins_enum.WYNK_MUSIC
        "HUNGAMA MUSIC":
            return Track_Origins_enum.HUNGAMA_MUSIC
        "MOOV":
            return Track_Origins_enum.MOOV
        "JOOX":
            return Track_Origins_enum.JOOX
        "ZING MP3":
            return Track_Origins_enum.ZING_MP3
        "NHACCUATUI":
            return Track_Origins_enum.NHACCUATUI
        "LANGIT MUSIK":
            return Track_Origins_enum.LANGIT_MUSIK
        "ANGHAMI":
            return Track_Origins_enum.ANGHAMI
        "BOOMPLAY":
            return Track_Origins_enum.BOOMPLAY
        "MDUNDO":
            return Track_Origins_enum.MDUNDO
        "NAXOS MUSIC LIBRARY":
            return Track_Origins_enum.NAXOS_MUSIC_LIBRARY
        _:
            return Track_Origins_enum.OTHER
