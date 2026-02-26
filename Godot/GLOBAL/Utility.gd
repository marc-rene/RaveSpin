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


static func is_all_ready() -> bool:
    return all_is_ready



static func is_Valid(object) -> bool:
    match typeof(object):
        TYPE_STRING:
            return object != null and object != "" and object != " "
        TYPE_ARRAY:
            return object != null and object.size() >= 1
        
    
    return object != null and is_instance_valid(object)
