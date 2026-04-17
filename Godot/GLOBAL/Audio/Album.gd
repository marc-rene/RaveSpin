@tool
class_name Album 
extends Resource

## Album metadata resource linked to songs and artists
## Album title. Singles usually use a matching title/album name
@export var Album_Name : StringName
static var All_Albums: Array[Album]

## Main artist for this album
@export var Album_Artist : Artist

@export var Album_Artwork: Texture2D

## Optional MusicBrainz ID for metadata linking
@export var MusicBrainz_ID : StringName


## Registers this resource in `All_Albums` for runtime lookup
func _init():
    self.set_name(Album_Name)
    if All_Albums.has(self) == false:
        All_Albums.append(self)


## Finds an existing album resource by name (case-insensitive)
static func Get_Album_Resource_By_Name(Album_Name: StringName) -> Album:
    for album in All_Albums:
        if album.Album_Name.matchn(Album_Name):
            return album
    
    return null
