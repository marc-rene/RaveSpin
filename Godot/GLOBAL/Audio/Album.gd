class_name Album 
extends Resource

# Name of this album? - Singles will just have the same name as their album
@export var Album_Name : StringName

# Who's the artist who made it?
@export var Album_Artist : Artist

@export var Album_Artwork : CompressedTexture2D

@export var MusicBrainz_ID : StringName
