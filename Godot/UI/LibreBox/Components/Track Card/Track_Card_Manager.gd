extends Node

@onready var Track_UID : int

@export var Origin_Platform_Logo : TextureRect

@export var Album_Art_Texture_Holder : TextureRect

@export var Track_Name_Label : Label
@export var Artist_Name_Label : Label
@export var Album_Name_Label : Label

@export var Track_Duration_Label : Label

@export var Track_BPM_Label : Label
@export var Track_Key_Label : Label

@export var Track_Genres_Containers : FlowContainer

@export var Note_Text_Container_Parent : Container  # Delete this if we dont have a note
@export var Note_Text_Label : Label 



func _ready() -> void:
    Origin_Platform_Logo.texture = load(Utility.Return_Valid(
        ETrackOrigins.Get_Origin_Platform_Logo(AudioTrack.All_Track_Origin_Platforms[Track_UID]), # Try get the Origin of this track
        ETrackOrigins.Get_Origin_Platform_Logo(ETrackOrigins.Track_Origins_enum.OTHER))) # If we can't find it, just say "Other"
    
    Album_Art_Texture_Holder.texture = Utility.Return_Valid(AudioTrack.Album_Arts[AudioTrack.All_Track_Albums[Track_UID]], "res://Art/Icon/T_RaveSpinHeader_Light.png")
    
    Track_Name_Label.text = Utility.Return_Valid(AudioTrack.All_Track_Titles[Track_UID], "Untitled")
    Artist_Name_Label.text = Utility.Return_Valid(AudioTrack.All_Track_Artists[Track_UID], "Untitled")
    Album_Name_Label.text = Utility.Return_Valid(AudioTrack.All_Track_Albums[Track_UID], "Untitled")
    
    var duration_text = "%02dm %02ds" % [AudioTrack.All_Audio_Files[Track_UID].get_length() / 60, int((AudioTrack.All_Audio_Files[Track_UID].get_length() / 60)) % 60 ]
    Track_Duration_Label.text = Utility.Return_Valid(duration_text, "N/A")
    
    Track_BPM_Label.text = Utility.Return_Valid(int(AudioTrack.All_Track_BPMs[Track_UID]), "N/A")
    
    Track_Key_Label.text = Utility.Return_Valid(AudioTrack.All_Track_Keys[Track_UID].to_string(), "N/A")
    
    if Utility.is_Valid(AudioTrack.All_Track_Genres):
        for genre in AudioTrack.All_Track_Genres:
            if Track_UID in AudioTrack.All_Track_Genres[genre]:
                var new_genre = Button.new()
                new_genre.text = genre
                Track_Genres_Containers.add_child(new_genre)
    
    if Utility.is_Valid(AudioTrack.All_User_Sidenotes[Track_UID]) and AudioTrack.All_User_Sidenotes[Track_UID] != "N/A":
        Note_Text_Label.text = AudioTrack.All_User_Sidenotes[Track_UID]
    
    else:
        Note_Text_Label.free()
        Note_Text_Container_Parent.queue_free()
    
