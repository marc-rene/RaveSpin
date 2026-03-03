extends Panel
class_name Active_Track_Card

@export var Track_ID : int = 0
@onready var AudioPlayer_ref : AudioStreamPlayer



@export var Song_Resource : Song

@onready var Album_Art_Texture_Holder : TextureRect = $"VBoxContainer/HBoxContainer/AspectRatioContainer/Album Art Holder"

@onready var Track_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Title"
@onready var Artist_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Artist"
@onready var Album_Name_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Album"

@onready var Track_BPM_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/BPM Container/HBoxContainer/BPM var Label"
@onready var Track_Key_Label : Label = $"VBoxContainer/HBoxContainer/Core Details Container/Key Container/HBoxContainer/Key var Label"

@onready var Note_Text_Label : Label = $"VBoxContainer/HBoxContainer/Note Container/Note SubContainer/Note var Label"
@onready var Note_Text_Container_Parent : Container = $"VBoxContainer/HBoxContainer/Note Container"


func _process(delta: float) -> void:
    Update_runtime_text()


func _ready():
    Track_ID = Utility.Clamp_to_Valid_TrackID(Track_ID)
    match Track_ID:
        0:
            AudioPlayer_ref = get_node("/root/Arena/Track Stream Player Left")
        1:
            AudioPlayer_ref = get_node("/root/Arena/Track Stream Player Right")
        2:
            AudioPlayer_ref = get_node("/root/Arena/Track Stream Player Left ALT")
        3:
            AudioPlayer_ref = get_node("/root/Arena/Track Stream Player Right ALT")



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
    
    Album_Art_Texture_Holder.texture = Utility.Return_Valid(Song_Resource.Song_Album.Album_Artwork, 
    "res://Art/Icon/T_RaveSpinHeader_Light.png")
    
    Track_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Title, "Untitled")
    Artist_Name_Label.text = Utility.Return_Valid(Song_Resource.Main_Artist.Artist_Name, "Untitled")
    Album_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Album.Album_Name, "Untitled")
    
    Track_BPM_Label.text = Utility.Return_Valid(str(int(Song_Resource.Track_BPM)), "N/A")
    
    # Safety measure because Music Key wont get updated sometimes
    if Song_Resource.Track_Key.to_string() == "C Unknown":
        Song_Resource.Refresh_Music_Key()
    
    #print("Song key is " + Song_Resource.Track_Key.to_string())
    Track_Key_Label.text = Utility.Return_Valid(Song_Resource.Track_Key.to_string(), "N/A")
    
    var expand_others = true
    
   
    if Utility.is_Valid(Song_Resource.User_Sidenote) and Utility.is_Valid(Note_Text_Label) and Song_Resource.User_Sidenote != "N/A":
        Note_Text_Label.show()
        Note_Text_Container_Parent.show()
        Note_Text_Label.text = Song_Resource.User_Sidenote
        
    else:
        Note_Text_Label.hide()
        Note_Text_Container_Parent.hide()
            
    return true
    


func Update_runtime_text():
    if AudioPlayer_ref and AudioPlayer_ref.stream:
        $"VBoxContainer/Time Remaining Container/Current Runtime".text = Utility.Seconds_to_MM_SS_MS(AudioPlayer_ref.get_playback_position(), false, true)
        $"VBoxContainer/Time Remaining Container/Max Runtime".text = Utility.Seconds_to_MM_SS_MS( AudioPlayer_ref.stream.get_length(), false, true)
    #$"VBoxContainer/Time Remaining Container/Max Runtime".text = Utility.Seconds_to_MM_SS_MS( (Song_Resource.Audio_File.get_length() * DJ_Controller.Get_Track_Speed_Mult(Track_ID)) , false, true)
