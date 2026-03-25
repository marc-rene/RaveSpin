@tool
class_name Album 
extends Resource

# Name of this album? - Singles will just have the same name as their album
@export var Album_Name : StringName
static var All_Albums: Array[Album]

# Who's the artist who made it?
@export var Album_Artist : Artist

@export var Album_Artwork: Texture2D

@export var MusicBrainz_ID : StringName


func _init():
    self.set_name(Album_Name)
    if All_Albums.has(self) == false:
        All_Albums.append(self)


static func Get_Album_Resource_By_Name(Album_Name: StringName) -> Album:
    for album in All_Albums:
        if album.Album_Name.matchn(Album_Name):
            return album
    
    return null
