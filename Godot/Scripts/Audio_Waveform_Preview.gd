@tool
extends Control

var Track_UID : int
@export var TEST_Audio : AudioStreamWAV

@export var Start_Time = 0.0
@export var End_Time = 0.0
@export_range(32, 1024, 1) var Resolution := 512


var amps : PackedByteArray
var width = 5


@export_tool_button("Force Draw", "Callable") 
var redraw = _draw

#func _draw():
    #var sorted_amps = TEST_Audio.data
    #sorted_amps.sort()
    #if End_Time <= 0.01: 
        #End_Time = TEST_Audio.get_length()
    #var max_amp = sorted_amps[-1]
    #var min_amp = sorted_amps[0]
#
    #
    #print("Max = ", max_amp)
    #print("Min = ", min_amp)
    #print("Size = ", TEST_Audio.data.size())
    #
    #for i in range(Resolution):
        #var new_point = remap(amps[(amps.size() / Resolution) * i], min_amp, max_amp, 0.1, 10)
        #draw_line(Vector2(width * i, 0.0), Vector2(width * i, new_point), Color.WEB_GREEN, width)    
        
        
#func _draw():
    #if Start_Time == null:
        #Start_Time = 0.0
        #
    #if End_Time <= 0.01 or End_Time == null: 
        #End_Time = TEST_Audio.get_length()
    #
    #var rate = TEST_Audio.mix_rate
    #
    #width = $".".size.x / Resolution
    #var max_height = $".".custom_minimum_size.y
    #for i in range(Resolution):
        #var start_point = Vector2((width * i) + ( width / 2), 0) # change this to clone both sides later
        ## print("Endtime ", End_Time==null, ", Starttime ", Start_Time == null, ", Resolution ", Resolution == null)
        #var sound_byte = TEST_Audio.data[( ( ( ( (End_Time * rate) - (Start_Time * rate) ) / Resolution ) * i) + (Start_Time * rate) )]
        #print("Sound byte %s" % sound_byte)
        #var end_point = Vector2((width * i) + ( width / 2), remap(sound_byte, 0, 255, 0, max_height ))        
        #draw_line(start_point, end_point, Color.WEB_GREEN, width)
        
        
#func _draw():
    #width = $".".custom_minimum_size.x / (TEST_Audio.data.size() / 44100)
    #var max_height = $".".custom_minimum_size.y
    #
    #for i in range(TEST_Audio.data.size() / 44100):
        #var start_point = Vector2((width * i) + ( width / 2), 0)
        #
        #var sound_byte = TEST_Audio.data[(4 * i)]
        #var end_point = Vector2((width * i) + ( width / 2), remap(sound_byte, 0, 255, 0, max_height))        
        #draw_line(start_point, end_point, Color.WEB_GREEN, width)

#func _process(_delta):
    #queue_redraw()
    

func Update_Track(new_track : AudioTrack):
    if new_track.UID == Track_UID:
        print("This is the same track???")
    else:
        _draw()
