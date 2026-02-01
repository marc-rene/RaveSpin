extends Node

@onready var Track : AudioTrack

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
    Album_Art_Texture_Holder.texture = Utility.Return_Valid(Track.Get_Album_Art(), "res://Art/Icon/T_RaveSpinHeader_Light.png")
    
    Track_Name_Label.text = Utility.Return_Valid(Track.Track_Title, "Untitled")
    Artist_Name_Label.text = Utility.Return_Valid(Track.Track_Artist, "Untitled")
    Album_Name_Label.text = Utility.Return_Valid(Track.Track_Album, "Untitled")
    
    var duration_text = "%02dm %02ds" % [Track.Audio_File.get_length() / 60, int((Track.Audio_File.get_length() / 60)) % 60 ]
    Track_Duration_Label.text = Utility.Return_Valid(duration_text, "N/A")
    
    Track_BPM_Label.text = Utility.Return_Valid(int(Track.Track_BPM), "N/A")
    
    Track_Key_Label.text = Utility.Return_Valid(Track.Track_Key_Note)
    
    
    
    
