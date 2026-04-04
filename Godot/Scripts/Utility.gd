extends Object
class_name Utility

## Shared helper methods used across runtime systems.
## This class keeps small static utilities so game scripts stay cleaner.

## Returns `object` unless it is null, then returns `backup`.
static func Return_Valid(object, backup):
    if object == null:
        return backup
    return object

## Global startup gate used by interaction scripts to avoid early node races.
static var all_is_ready : bool = false : set = set_all_is_ready

## Sets startup gate once and logs first successful transition.
static func set_all_is_ready(all_ready : bool):
    if all_is_ready == false:
        all_is_ready = all_ready
        print("All ready to start!!!")


## Clamps deck index to valid runtime range (0..3).
static func Clamp_to_Valid_TrackID(which_track : int) -> int:
    return clampi(which_track , 0, 3)


## Returns global startup gate.
static func is_all_ready() -> bool:
    return all_is_ready



## Formats seconds into a short human-readable time string.
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
    
         


## Generic validity check used by metadata/UI code.
## Strings must be non-empty, arrays must have at least one item, objects must be valid.
static func is_Valid(object) -> bool:
    match typeof(object):
        TYPE_STRING:
            return object != null and object != "" and object != " "
        TYPE_ARRAY:
            return object != null and object.size() >= 1
        
    
    return object != null and is_instance_valid(object)
