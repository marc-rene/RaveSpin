extends Object
class_name Utility

# Just a handy collection of helper functions

# Only return object if it's valid... otherwise use the backup
static func Return_Valid(object, backup):
    if object == null:
        return backup
    return object


static func is_Valid(object) -> bool:
    return object == null
