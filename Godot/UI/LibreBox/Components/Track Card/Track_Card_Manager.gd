extends Node
class_name Track_Card

@export var Song_Resource : Song

@onready var Origin_Platform_Logo : TextureRect = %"Origin Platform Logo"

@onready var Album_Art_Texture_Holder : TextureRect = %Album_Thumbnail
const Default_Album_art = preload("res://Art/Splash/Light Splash.png")

@onready var Track_Name_Label : Label = %Title
@onready var Artist_Name_Label : Label = %Artist
@onready var Album_Name_Label : Label = %Album

@onready var Track_Duration_Label : Label = %"Time var Label"

@onready var Track_BPM_Label : Label = %"BPM var Label"
@onready var Track_Key_Label : Label = %"Key var Label"

@onready var Track_Genres_Containers : FlowContainer = %"Genres Container"

@onready var Note_Text_Container_Parent : Container = %"Note Container"
@onready var Note_Text_Label : Label = %"Note var Label"

@onready var Info_Genre_Seperator : VSeparator = %"Separator Info-Genre"
@onready var Genre_Note_Seperator : VSeparator = %"Separator Genre-Note"

@onready var Remove_Track_Button: Button = %RemoveTrackButton


signal Card_Clicked(Song_Resource)
signal Remove_Requested(target_song: Song)

@onready var Card_Button_ref : Button = $"."

func Set_New_Song(New_Song: Song) -> bool:
    if New_Song == Song_Resource:
        return false
    Song_Resource = New_Song
    if Song_Resource == null:
        _clear_card_visuals()
        return true
    Refresh_Details()
    return true

func Refresh_Details() -> bool:
    if Song_Resource == null:
        return false

    for genre_child in Track_Genres_Containers.get_children():
        genre_child.free()
    
    #print("Song Platform: " + str(Song_Resource.Song_Origin_Platform) + " == " + ETrackOrigins.Track_Origin_toString(Song_Resource.Song_Origin_Platform))        
    Origin_Platform_Logo.texture = load(Utility.Return_Valid(
        ETrackOrigins.Get_Origin_Platform_Logo(Song_Resource.Song_Origin_Platform),
        ETrackOrigins.Get_Origin_Platform_Logo(ETrackOrigins.Track_Origins_enum.OTHER))) # If we can't find it, just say "Other"
    
    var album_artwork_texture: Texture2D = Default_Album_art
    if Song_Resource.Song_Album and Song_Resource.Song_Album.Album_Artwork != null:
        album_artwork_texture = Song_Resource.Song_Album.Album_Artwork
    Album_Art_Texture_Holder.texture = album_artwork_texture
    
    
    Track_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Title, "Untitled")
    Artist_Name_Label.text = Utility.Return_Valid(Song_Resource.Main_Artist.Artist_Name if Song_Resource.Main_Artist else null, "Untitled")
    Album_Name_Label.text = Utility.Return_Valid(Song_Resource.Song_Album.Album_Name if Song_Resource.Song_Album else null, "Untitled")
    
    #print("Total: " + str(Song_Resource.Audio_File.get_length()))
    #print("Minutes: " + str(int(Song_Resource.Audio_File.get_length() / 60)))
    #print("Seconds: " + str(int(Song_Resource.Audio_File.get_length()) % 60))
    #var mins = int(Song_Resource.Audio_File.get_length() / 60)
    #var secs = int(Song_Resource.Audio_File.get_length()) % 60
    #var duration_text = ""
    #if mins >= 1:
        #duration_text += str(mins) + "m "
#
    #duration_text += str(secs) + "s "   
    var stream : AudioStream = Song_Resource.get_audio_stream()
    Track_Duration_Label.text = Utility.Seconds_to_MM_SS_MS(stream.get_length() if stream else 0.0)
    
    Track_BPM_Label.text = Utility.Return_Valid(str(int(Song_Resource.Track_BPM)), "N/A")
    
    # Safety measure because Music Key wont get updated sometimes
    if Song_Resource.Track_Key.to_string() == "C Unknown":
        Song_Resource.Refresh_Music_Key()
    
    #print("Song key is " + Song_Resource.Track_Key.to_string())
    Track_Key_Label.text = Utility.Return_Valid(Song_Resource.Track_Key.to_string(), "N/A")
    
    var expand_others = true
    
    if Utility.is_Valid(Song_Resource.Song_Genres):
        Info_Genre_Seperator.show()
        Track_Genres_Containers.show()
        for genre in Song_Resource.Song_Genres:
            var new_genre = Button.new()
            new_genre.text = Song.Id3_to_DisplayTitle(genre)
            Track_Genres_Containers.add_child(new_genre)
            expand_others = false
    else:
        if Info_Genre_Seperator != null:
            Info_Genre_Seperator.hide()
            Track_Genres_Containers.hide()
        #print("NO GENRES")
    
    if Utility.is_Valid(Song_Resource.User_Sidenote) and Utility.is_Valid(Note_Text_Label) and Song_Resource.User_Sidenote != "N/A":
        Genre_Note_Seperator.show()
        Note_Text_Label.show()
        Note_Text_Container_Parent.show()
        Note_Text_Label.text = Song_Resource.User_Sidenote
        expand_others = false
        #print("Track " + Song_Resource.Song_Title + " has a sidenote: " + Song_Resource.User_Sidenote)
        
    else:
        if Genre_Note_Seperator != null:
            Genre_Note_Seperator.hide()
            Note_Text_Label.hide()
            Note_Text_Container_Parent.hide()
        #print("Track " + Song_Resource.Song_Title + " NO SIDENOTE!")
    
    if expand_others and %"Name Container" != null:
        %"Name Container".size_flags_horizontal = Control.SIZE_EXPAND_FILL

    _update_remove_button_visibility()
    return true


func _clear_card_visuals() -> void:
    for genre_child in Track_Genres_Containers.get_children():
        genre_child.free()
    Track_Name_Label.text = "No track"
    Artist_Name_Label.text = ""
    Album_Name_Label.text = ""
    Track_Duration_Label.text = "--:--"
    Track_BPM_Label.text = "N/A"
    Track_Key_Label.text = "N/A"
    Album_Art_Texture_Holder.texture = Default_Album_art
    if Remove_Track_Button != null:
        Remove_Track_Button.hide()


func _update_remove_button_visibility() -> void:
    if Remove_Track_Button == null:
        return
    var path: String = Song_Resource.resource_path
    var can_delete: bool = path.begins_with("user://") and path.ends_with(".tres")
    Remove_Track_Button.visible = can_delete


func _ready() -> void:
    if Remove_Track_Button != null:
        Remove_Track_Button.pressed.connect(_on_remove_track_pressed)
    if Song_Resource != null:
        Refresh_Details()


func _on_remove_track_pressed() -> void:
    if Song_Resource == null:
        return
    Remove_Requested.emit(Song_Resource)


func _on_pressed() -> void:
    if Song_Resource:
        print("CARD was pressed with song: " + Utility.Return_Valid(Song_Resource.Song_Title, "N/A"))
        Card_Clicked.emit(Song_Resource)
