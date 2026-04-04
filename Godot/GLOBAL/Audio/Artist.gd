@tool
class_name Artist
extends Resource

## Artist metadata resource used by songs and album lookups.

## Display name for this artist.
@export var Artist_Name: StringName
static var All_Artists: Array[Artist]


## Optional profile image used by UI cards.
@export var Artist_Profile_Picture: CompressedTexture2D = load("res://Art/Icon/T_RaveSpinHeader_Light.png")

## Optional MusicBrainz identifier for metadata linking.
@export var MusicBrainz_ID: StringName


## Registers this resource in `All_Artists` for runtime lookup.
func _init():
    self.set_name(Artist_Name)
    if All_Artists.has(self) == false:
        All_Artists.append(self)


## Finds an existing artist resource by name (case-insensitive).
static func Get_Artist_Resource_By_Name(Artist_Name: StringName) -> Artist:
    for artist in All_Artists:
        if artist.Artist_Name.matchn(Artist_Name):
            return artist
    
    return null
    
