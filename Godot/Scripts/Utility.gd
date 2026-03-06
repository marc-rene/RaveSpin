extends Object
class_name Utility

# Just a handy collection of helper functions

# Only return object if it's valid... otherwise use the backup
static func Return_Valid(object, backup):
    if object == null:
        return backup
    return object

static var all_is_ready : bool = false : set = set_all_is_ready

static func set_all_is_ready(all_ready : bool):
    if all_is_ready == false:
        all_is_ready = all_ready
        print("All ready to start!!!")


# instead of doing clamp(value, 0 , 3) a hundred times, just use this
static func Clamp_to_Valid_TrackID(which_track : int) -> int:
    return clampi(which_track , 0, 3)


static func is_all_ready() -> bool:
    return all_is_ready



static func Seconds_to_MM_SS_MS(seconds : float, truncate_zero_value : bool = true, include_ms : bool = false) -> String:
    if seconds:
        var temp_str : String = ""
        if seconds < 60 and truncate_zero_value:
            pass
        else:
            temp_str += str(int(floor(seconds / 60))) + "m "
        if seconds < 1 and truncate_zero_value:
            pass
        else:
            temp_str += str(int(floor(fmod(seconds, 60)))) + "s "
        if include_ms:
            temp_str += "%.4fms" % fmod(seconds, 1)
        return temp_str
    else:
        return "NaN"
    
         


static func is_Valid(object) -> bool:
    match typeof(object):
        TYPE_STRING:
            return object != null and object != "" and object != " "
        TYPE_ARRAY:
            return object != null and object.size() >= 1
        
    
    return object != null and is_instance_valid(object)
