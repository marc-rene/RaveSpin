extends Control
class_name LibreBox_HUB

@export var Track_1 : Song
@export var Track_2 : Song

@onready var Track_1_waveformVis : TextureRect = %"Track 1 Waveform preview"
@onready var Track_2_waveformVis : TextureRect = %"Track 2 Waveform preview"



func Refresh(Set_Track_1 : bool):
    if Set_Track_1:
        $"VBoxContainer/Track 1 Container/Track 1 Card".Set_New_Song(Track_1)
        _update_waveform_for_song_WAV(Track_1, Track_1_waveformVis)
    
    else:
        $"VBoxContainer/Track 2 Container/Track 2 Card".Set_New_Song(Track_2)
        _update_waveform_for_song_WAV(Track_2, Track_2_waveformVis)
    
func _ready():
    $"VBoxContainer/Track 1 Container/Track 1 Card".Song_Resource = Track_1
    $"VBoxContainer/Track 2 Container/Track 2 Card".Song_Resource = Track_2
    Refresh(true)
    Refresh(false)



func _update_waveform_for_song_WAV(song: Song, target_rect: TextureRect) -> void:
    if song == null or target_rect == null:
        return


    if song.Audio_File is not AudioStreamWAV:
        push_warning("WE DONT SUPPORT MP3.. or whatever this is")
        return
        
    var wav_stream : AudioStreamWAV = song.Audio_File
        
    if wav_stream == null:
        push_warning("Song does not provide an AudioStreamWAV; cannot generate waveform.")
        return

    var tex : ImageTexture = AudioWaveformGenerator.generate_waveform_from_wav(wav_stream, Vector2i(5120, 240), Color.WHITE)
    if tex:
        target_rect.texture = tex
