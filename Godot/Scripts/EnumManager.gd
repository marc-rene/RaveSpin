extends Object

# use_music_rules just means will '#' become an 's' instead
# Convert String from "7 digital music" to "DIGITAL_MUSIC_7"
static func Convert_String_to_Enum(string_version : String, use_music_rules = true) -> String:
    var enum_str = string_version.to_upper().strip_edges()
    var is_letter = RegEx.new()
    var is_number = RegEx.new()
    var is_not_alphanumeric = RegEx.new()
    var is_music = RegEx.new()
    is_letter.compile("[^A-Z]+")
    is_number.compile("[^0-9]+")
    is_not_alphanumeric.compile("[^A-Za-z0-9]+")
    is_music.compile("#")
    
    # Can't have anything starting with a number 
    if is_letter.search(enum_str, 0, 1) == null and enum_str.length() >= 2:
        print("%s got a dodgy enum conversion" % enum_str)
        
        if is_number.search(enum_str, 0, 1) != null:
            enum_str += enum_str[0] # add the number at the end... fine if there's one number but the order WILL get reversed... shouldn't have
        
        enum_str = enum_str.substr(1)
        enum_str = Convert_String_to_Enum(enum_str)
    elif enum_str[0] in "0123456789" and enum_str.length() < 2:
        printerr("HEY! the string %s makes a terrible enum" % enum_str)
        return ""
    
    if use_music_rules:
        enum_str = is_music.sub(enum_str, "s")
    enum_str = is_not_alphanumeric.sub(enum_str, "_")  # all spaces, punctuation, become '_'
    
    return enum_str.strip('_')
        
