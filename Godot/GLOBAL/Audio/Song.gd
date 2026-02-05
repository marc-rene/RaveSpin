class_name Song
extends Resource

# Who 'owns' this song? Even if it was a collab
@export var Main_Artist : Artist

# Who was featured on this song too?
@export var Guest_Artist : Array[Artist]

# Which Album does this song belong to? 
# Singles will still have an Album of the same name
@export var Song_Album : Album


@