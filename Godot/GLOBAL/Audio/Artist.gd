@tool
class_name Artist
extends Resource


# What's the name of the artist??
@export var Artist_Name: StringName
static var All_Artists: Array[Artist]


# Does this artist have a photo we could use?
@export var Artist_Profile_Picture: CompressedTexture2D = load("res://Art/Icon/T_RaveSpinHeader_Light.png")

# Check out this example https://musicbrainz.org/release-group/f1f6c7e2-7848-4554-b36c-2190e1d6bfb0/details
# This will make future Metadata retrieval easier
@export var MusicBrainz_ID: StringName


func _init():
    self.set_name(Artist_Name)
    if All_Artists.has(self) == false:
        All_Artists.append(self)


static func Get_Artist_Resource_By_Name(Artist_Name: StringName) -> Artist:
    for artist in All_Artists:
        if artist.Artist_Name.matchn(Artist_Name):
            return artist
    
    return null
    
