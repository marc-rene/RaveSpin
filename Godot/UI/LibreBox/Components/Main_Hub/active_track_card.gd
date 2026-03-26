extends Panel
class_name Active_Track_Card

@export var Track_ID : int = 0
@onready var AudioPlayer_ref : AudioStreamPlayer

@onready var BPM_Spinner_ref : BPM_Spinner = $VBoxContainer/HBoxContainer/BpmSpinner

@export var Song_Resource : Song

@onready var Album_Art_Texture_Holder : TextureRect = $"VBoxContainer/HBoxContainer/AspectRatioContainer/Album Art Holder"
const Default_album_art_T = preload("res://Art/Splash/Light Splash.png")
@onready var Track_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Title"
@onready var Artist_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Artist"
@onready var Album_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Album"

@onready var Track_BPM_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/BPM Container/HBoxContainer/BPM var Label"
@onready var Track_Key_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Key Container/HBoxContainer/Key var Label"

@onready var Note_Text_Label : Label = $"VBoxContainer/HBoxContainer/Note Container/Note SubContainer/Note var Label"
@onready var Note_Text_Container_Parent : Container = $"VBoxContainer/HBoxContainer/Note Container"

@onready var _active_fx_container: HFlowContainer = $"VBoxContainer/Active Effects Container"
@onready var _active_fx_title_label: Label = $"VBoxContainer/Active Effects Container/Active FX Title Label"

var ACTIVE_FX_TITLE_DEFAULT: String = tr("KEY_ACTIVE_FX")
const HEADING_2_LABEL_SETTINGS: LabelSettings = preload("res://Art/Themes/Heading_2.tres")

var CheckFX_thread : Thread

var prev_beat_alpha : float = -1.0

var position_sec : float
var beats_elapsed : float
var alpha : float

func _process(delta: float) -> void:
    if AudioPlayer_ref == null:
        AudioPlayer_ref = DJ_Controller.Get_Track_Playback_Player(Track_ID)
    Update_runtime_text()
    BPM_Spinner_ref.Refresh_BPM(DJ_Controller.Get_Track_Current_BPM(Track_ID))

    # Drive BPM spinner alpha from track beat: alpha 0 = beat just started, alpha 0.99999 = beat just happened
    # Use base BPM (metadata): get_playback_position() is in stream seconds, and beat boundaries in the file are fixed by base BPM
    if AudioPlayer_ref and DJ_Controller.Get_Track_Current_BPM(Track_ID) > 1.0:
        var base_bpm : float = LibreBox.Get_Track_BPM(Track_ID)
        if base_bpm > 0.0:
            position_sec  = AudioPlayer_ref.get_playback_position()
            beats_elapsed  = position_sec * (base_bpm / 60.0)
            alpha = fmod(beats_elapsed, 1.0)
            BPM_Spinner_ref.Alpha = alpha
            BPM_Spinner_ref.rotate_spinny(alpha)
            # Detect beat boundary (alpha wrapped from ~1 to ~0) and fire _on_beat
            if prev_beat_alpha >= 0.0 and prev_beat_alpha > 0.5 and alpha < 0.5:
                BPM_Spinner_ref.On_Beat()
                _on_beat()
            prev_beat_alpha = alpha
        else:
            BPM_Spinner_ref.Alpha = 0.0
            prev_beat_alpha = -1.0
    else:
        BPM_Spinner_ref.Alpha = 0.0
        prev_beat_alpha = -1.0
    

# when our track has a BEAT
func _on_beat():
    pass

func _ready():
    
    Track_ID = Utility.Clamp_to_Valid_TrackID(Track_ID)
    # Use controller's player so we work regardless of scene tree / path
    await DJ_Controller.Get_Instance_await()
    AudioPlayer_ref = DJ_Controller.Get_Track_Playback_Player(Track_ID)
    
    CheckFX_thread = Thread.new()
    

var fx_labels : Dictionary[BUS_MANAGER.E_BEAT_FX_TYPE, Label]

var wait_t : int = 0
func _physics_process(_delta: float) -> void:
    if wait_t % 4 == 0:
        if _active_fx_container == null or _active_fx_title_label == null:
            return
        var channel: int = Utility.Clamp_to_Valid_TrackID(Track_ID)
        var can_take_fx: bool = (channel == 0 and BUS_MANAGER.Can_Track_1_Take_FX()) or (channel == 1 and BUS_MANAGER.Can_Track_2_Take_FX())
        if not can_take_fx:
            var set_string_1 : String = tr("KEY_NO_FX_ALLOWED_1")
            var set_string_2 : String = tr("KEY_NO_FX_ALLOWED_2")
            _active_fx_title_label.text = set_string_1 if channel == 0 else set_string_2
            _clear_dynamic_fx_labels()
            return

        _active_fx_title_label.text = ACTIVE_FX_TITLE_DEFAULT
        var active_dict: Dictionary = BUS_MANAGER.active_effects_Channel_1 if channel == 0 else BUS_MANAGER.active_effects_Channel_2
        _sync_active_fx_labels(active_dict)
    
    wait_t += 1


func _clear_dynamic_fx_labels() -> void:
    var to_drop: Array = fx_labels.keys().duplicate()
    for fx_type in to_drop:
        var lab: Label = fx_labels[fx_type]
        fx_labels.erase(fx_type)
        if is_instance_valid(lab):
            lab.queue_free()


func _sync_active_fx_labels(active_dict: Dictionary) -> void:
    var remove_keys: Array = []
    for fx_type in fx_labels.keys():
        if not active_dict.has(fx_type):
            remove_keys.append(fx_type)
    for fx_type in remove_keys:
        var lab: Label = fx_labels[fx_type]
        fx_labels.erase(fx_type)
        if is_instance_valid(lab):
            lab.queue_free()

    for fx_type in active_dict.keys():
        var slot: int = int(active_dict[fx_type])
        if slot < 0:
            continue
        if fx_labels.has(fx_type):
            continue
        var new_label := Label.new()
        new_label.label_settings = HEADING_2_LABEL_SETTINGS
        new_label.text = tr(BUS_MANAGER.beat_fx_translation_key(fx_type))
        _active_fx_container.add_child(new_label)
        fx_labels[fx_type] = new_label


func Set_New_Song(New_Song: Song) -> bool:
    if New_Song == null or New_Song == Song_Resource:
        return false
    else:
        Song_Resource = New_Song
        Refresh_Details()
        return true
        

func Refresh_Details() -> bool:
    if Song_Resource == null:
        return false
    
    var album_artwork_texture: Texture2D = Default_album_art_T
    if Song_Resource.Song_Album and Song_Resource.Song_Album.Album_Artwork != null:
        album_artwork_texture = Song_Resource.Song_Album.Album_Artwork
    Album_Art_Texture_Holder.texture = album_artwork_texture
    
    
    Track_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Title, tr("KEY_UNTITLED"))
    Artist_Name_Label.text = Utility.Return_Valid(Song_Resource.Main_Artist.Artist_Name, tr("KEY_UNTITLED"))
    Album_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Album.Album_Name, tr("KEY_UNTITLED"))
    
    Track_BPM_Label.text = Utility.Return_Valid(str(int(Song_Resource.Track_BPM)), "N/A")
    
    # Safety measure because Music Key wont get updated sometimes
    if Song_Resource.Track_Key.to_string() == "C Unknown":
        Song_Resource.Refresh_Music_Key()
    
    #print("Song key is " + Song_Resource.Track_Key.to_string())
    Track_Key_Label.text = Utility.Return_Valid(Song_Resource.Track_Key.to_string(), "N/A")
   
    if Utility.is_Valid(Song_Resource.User_Sidenote) and Utility.is_Valid(Note_Text_Label) and Song_Resource.User_Sidenote != "N/A":
        Note_Text_Label.show()
        Note_Text_Container_Parent.show()
        Note_Text_Label.text = Song_Resource.User_Sidenote
        
    else:
        Note_Text_Label.hide()
        Note_Text_Container_Parent.hide()
            
    BPM_Spinner_ref.Set_Base_BPM(Song_Resource.Track_BPM)
    BPM_Spinner_ref.Refresh_BPM(DJ_Controller.Get_Track_Current_BPM(Track_ID))
    return true
    


func Update_runtime_text():
    if AudioPlayer_ref and AudioPlayer_ref.stream:
        $"VBoxContainer/Time Remaining Container/Current Runtime".text = Utility.Seconds_to_MM_SS_MS(AudioPlayer_ref.get_playback_position(), false, true)
        $"VBoxContainer/Time Remaining Container/Max Runtime".text = Utility.Seconds_to_MM_SS_MS( AudioPlayer_ref.stream.get_length(), false, true)
    
    
    #$"VBoxContainer/Time Remaining Container/Max Runtime".text = Utility.Seconds_to_MM_SS_MS( (Song_Resource.Audio_File.get_length() * DJ_Controller.Get_Track_Speed_Mult(Track_ID)) , false, true)
