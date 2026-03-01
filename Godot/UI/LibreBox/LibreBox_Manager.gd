extends Node
class_name LibreBox

@export var Track_1_Song : Song
@export var Track_2_Song : Song

@export var Track_3_Song : Song
@export var Track_4_Song : Song


@onready var HUB_Menu_ref : LibreBox_HUB = $HUB.get_scene_instance()
@onready var Track_1_Selection_ref : LibreBox_TrackSelection = $"Track 1 Selection".get_scene_instance()
@onready var Track_2_Selection_ref : LibreBox_TrackSelection = $"Track 2 Selection".get_scene_instance()

static var LibreBox_instance : LibreBox


# where is track X playback position? 
static func Get_Track_Playback_Position(which_track : int) -> float:
    return DJ_Controller.Get_Instance().Get_Track_Playback_Position(which_track)

# How far into the song are we on Track X ?
static func Get_Track_Playback_Alpha(which_track : int) -> float:
    return DJ_Controller.Get_Instance().Get_Track_Playback_Alpha(which_track)
    
# Just get the whole bloody player
static func Get_Track_Playback_Player(which_track : int) -> AudioStreamPlayer:
    return DJ_Controller.Get_Instance().Get_Track_Playback_Player(which_track)
    
    
# Get BPM of whatever track we're on
static func Get_Track_BPM(which_track : int) -> float:
    which_track = Utility.Clamp_to_Valid_TrackID(which_track)
    
    match which_track:
        0: 
            if LibreBox_instance.Track_1_Song:
                return Utility.Return_Valid(LibreBox_instance.Track_1_Song.Track_BPM, -1.0)
        1: 
            if LibreBox_instance.Track_2_Song:
                return Utility.Return_Valid(LibreBox_instance.Track_2_Song.Track_BPM, -1.0)
        2: 
            if LibreBox_instance.Track_3_Song:
                return Utility.Return_Valid(LibreBox_instance.Track_3_Song.Track_BPM, -1.0)
        3: 
            if LibreBox_instance.Track_4_Song:
                return Utility.Return_Valid(LibreBox_instance.Track_4_Song.Track_BPM, -1.0)
    #push_warning("HEY! Track " + str(which_track) + " hasn't been initialised yet... wtf?")
    return -1.0

# pause the song... true if pausing happened, false if it was already paused
static func Pause_Track(p_which_track : int) -> bool:
    p_which_track = Utility.Clamp_to_Valid_TrackID(p_which_track)
    if DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].stream_paused:
        return false # already paused
    else:
        DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].stream_paused = true
        return true    
    


# Play the song... true if playing resumes, false if it was already playing
static func Play_Track(p_which_track : int, reset_from_start : bool = false) -> bool:
    p_which_track = Utility.Clamp_to_Valid_TrackID(p_which_track)
    if DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].stream_paused == false:
        return false # already playing
    else:
        if reset_from_start: 
            DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].play(0)
            
        DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].stream_paused = false
        return true   
    
    
# toggle between playing / pausing
func Play_Pause(p_which_track : int):
    p_which_track = Utility.Clamp_to_Valid_TrackID(p_which_track)
    if(DJ_Controller.Get_Instance().AudioPlayerList[p_which_track].stream_paused == true):
        print("Resuming playback ", p_which_track, " now @ ", str(Get_Track_Playback_Position(p_which_track)) )
        Play_Track(p_which_track)
        #AudioPlayerList[p_which_track].stream_paused = false
        #AudioPlayerList[p_which_track].play(AudioPlayerList[p_which_track].get_playback_position())
    
    else:
        print("Pausing Track ", p_which_track)
        Pause_Track(p_which_track)

    
func Update_Controller_and_Hub(Which_Track: int, New_Song: Song):
    print("MAIN MANAGER CALLED TO CHANGE TRACK #" + str(Which_Track) + " TO SONG: " + New_Song.Song_Title)       
    
    DJ_Controller.Get_Instance().LoadTrackIntoMemory(Which_Track, New_Song)
    
    match Which_Track:
        0:
            HUB_Menu_ref.Track_1 = New_Song
            HUB_Menu_ref.Refresh(true)
        1:
            HUB_Menu_ref.Track_2 = New_Song
            HUB_Menu_ref.Refresh(false)


func On_Song_Change_Track_1(New_Song: Song):
    Update_Controller_and_Hub(0, New_Song)


func On_Song_Change_Track_2(New_Song: Song):
    Update_Controller_and_Hub(1, New_Song)


# Get the BPM of source track (eg: 144) and set the BPM of target track (eg: 95) to 144
# and SHOULD we make sure that target_track will seek back to the last time there was
# a beat at the same time our source track has a beat...
# so that the 2 tracks have the same bpm and seek from the same beat position
func Sync_Track_BPMs(Track_we_want_to_Match: int, Track_we_want_change : int, match_beat : bool) -> bool:
    Track_we_want_to_Match = Utility.Clamp_to_Valid_TrackID(Track_we_want_to_Match)
    Track_we_want_change = Utility.Clamp_to_Valid_TrackID(Track_we_want_change)
    if Track_we_want_to_Match == Track_we_want_change:
        push_error("You want a track bpm to be in sync.... with itself??? wtf?")
        return false

    var source_bpm : float = -1.0
    var target_bpm : float = -1.0

    match Track_we_want_to_Match:
        0: source_bpm = Track_1_Song.Track_BPM
        1: source_bpm = Track_2_Song.Track_BPM
        2: source_bpm = Track_3_Song.Track_BPM
        3: source_bpm = Track_4_Song.Track_BPM
    match Track_we_want_change:
        0: target_bpm = Track_1_Song.Track_BPM
        1: target_bpm = Track_2_Song.Track_BPM
        2: target_bpm = Track_3_Song.Track_BPM
        3: target_bpm = Track_4_Song.Track_BPM

    if source_bpm < 0 or target_bpm < 0:
        push_error("WE COULDN'T FIND THE BPM OF A SONG!!! FAILURE")
        return false

    # Pitch scale so target track plays at source BPM: target_bpm * pitch = source_bpm => pitch = source_bpm / target_bpm
    var required_pitch : float = source_bpm / target_bpm
    DJ_Controller.Get_Instance().Set_Channel_Tempo(Track_we_want_change, required_pitch)
    # Sliders are updated inside Set_Channel_Tempo via Update_Channel_Tempo_Adjusts()
    
    # TODO: seek target to align beats with source
    return true



#func Set_Sync_Track_1_BPM_to_Track_2() -> void:
    #Sync_Track_BPMs()  # match track 1 to track 2's BPM
    

func Refresh():
    HUB_Menu_ref.Refresh(true)
    HUB_Menu_ref.Refresh(false)
    
func _ready() -> void:
    HUB_Menu_ref.Track_1 = Track_1_Song
    HUB_Menu_ref.Track_2 = Track_2_Song
    Track_1_Selection_ref.track_selected.connect(On_Song_Change_Track_1)
    Track_2_Selection_ref.track_selected.connect(On_Song_Change_Track_2)
    LibreBox_instance = self
    Refresh()
    
    await DJ_Controller.Get_Instance_await()
    if Track_1_Song:
        DJ_Controller.Get_Instance().LoadTrackIntoMemory(0, Track_1_Song)
    if Track_2_Song:
        DJ_Controller.Get_Instance().LoadTrackIntoMemory(1, Track_2_Song)
    #DJ_Controller.Get_Instance().Sync_LeftTrackBPM_to_RightTrackBPM.connect()
    #JANK... but works
    await get_tree().create_timer(0.1).timeout
    Utility.set_all_is_ready(true)
    
