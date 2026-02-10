extends Node
class_name Track_Card

@export var Song_Resource : Song

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





    
func Refresh_Details() -> bool:
    if Song_Resource == null:
        return false
    
    print("Song Platform: " + str(Song_Resource.Song_Origin_Platform) + " == " + ETrackOrigins.Track_Origin_toString(Song_Resource.Song_Origin_Platform))        
    Origin_Platform_Logo.texture = load(Utility.Return_Valid(
        ETrackOrigins.Get_Origin_Platform_Logo(Song_Resource.Song_Origin_Platform),
        ETrackOrigins.Get_Origin_Platform_Logo(ETrackOrigins.Track_Origins_enum.OTHER))) # If we can't find it, just say "Other"
    
    Album_Art_Texture_Holder.texture = Utility.Return_Valid(Song_Resource.Song_Album.Album_Artwork, 
    "res://Art/Icon/T_RaveSpinHeader_Light.png")
    
    Track_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Title, "Untitled")
    Artist_Name_Label.text = Utility.Return_Valid(Song_Resource.Main_Artist.Artist_Name, "Untitled")
    Album_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Album.Album_Name, "Untitled")
    
    print("Total: " + str(Song_Resource.Audio_File.get_length()))
    print("Minutes: " + str(int(Song_Resource.Audio_File.get_length() / 60)))
    print("Seconds: " + str(int(Song_Resource.Audio_File.get_length()) % 60))
    var mins = int(Song_Resource.Audio_File.get_length() / 60)
    var secs = int(Song_Resource.Audio_File.get_length()) % 60
    var duration_text = ""
    if mins >= 1:
        duration_text += str(mins) + "m "

    duration_text += str(secs) + "s "   
    Track_Duration_Label.text = Utility.Return_Valid(duration_text, "N/A")
    
    Track_BPM_Label.text = Utility.Return_Valid(str(int(Song_Resource.Track_BPM)), "N/A")
    
    # Safety measure because Music Key wont get updated sometimes
    if Song_Resource.Track_Key.to_string() == "C Unknown":
        Song_Resource.Refresh_Music_Key()
    
    print("Song key is " + Song_Resource.Track_Key.to_string())
    Track_Key_Label.text = Utility.Return_Valid(Song_Resource.Track_Key.to_string(), "N/A")
    
    var expand_others = true
    
    if Utility.is_Valid(Song_Resource.Song_Genres):
        for genre in Song_Resource.Song_Genres:
            var new_genre = Button.new()
            new_genre.text = EGenre.m_MusicGenres_str[genre]
            Track_Genres_Containers.add_child(new_genre)
            expand_others = false
    else:
        $"VBoxContainer/Main Container/Separator Info-Genre".free()
        Track_Genres_Containers.queue_free()
        print("NO GENRES")
    
    if Utility.is_Valid(Song_Resource.User_Sidenote) and Song_Resource.User_Sidenote != "N/A":
        Note_Text_Label.text = Song_Resource.User_Sidenote
        expand_others = false
        print("Track " + Song_Resource.Song_Title + " has a sidenote: " + Song_Resource.User_Sidenote)
        
    else:
        $"VBoxContainer/Main Container/Separator Genre-Note".free()
        Note_Text_Label.free()
        Note_Text_Container_Parent.free()
        print("Track " + Song_Resource.Song_Title + " NO SIDENOTE!")
    
    if expand_others:
        print("GET BIGGIE WITH IT")
        $"VBoxContainer/Main Container/Name Container".size_flags_horizontal = Control.SIZE_EXPAND_FILL
        #$"VBoxContainer/Main Container/Time Container".size_flags_horizontal = Control.SIZE_EXPAND_FILL
        #$"VBoxContainer/Main Container/BPM Container".size_flags_horizontal = Control.SIZE_EXPAND_FILL
        #$"VBoxContainer/Main Container/Key Container".size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    return true
            
            
func _ready() -> void:
    #print("Song Resource: " + Utility.Return_Valid(Song_Resource.resource_path, "null"))        
    print("Song details are valid?: " + str(Song_Resource == null))
    if Song_Resource != null:
        Refresh_Details()
    
    
