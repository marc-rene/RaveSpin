"""
The purpose of this is to take any .gd file that has a huge StringName array of values,
Because enums are awesome, but there's no easy compile-time string->enum functionality in Godot,
This python monstrisity gets that array, and converts the whole thing into a huge massive enum 

I apologise for the mess that is this haphazzard barely working code

SAVE
YOUR
GD-SCRIPT
FIRST
BEFORE
RUNNING

"""
import re



# What will we start looking for our array from? like 'const String_Array : Array[StringName] = ['
START_SEARCH_PHRASE = "const m_MusicGenres_str : Array[StringName] = ["
ORIGINAL_VAR_NAME = "m_MusicGenres_str"

# Where will we insert our Enum and String -> Enum function??
INJECTION_POINT_PHRASE = "### INSERT ENUM VERSION HERE ###"

# Name of the enum version of our string array
ENUM_VARIABLE_NAME = "m_MusicGenres_enum"

# MAKE SURE YOU'VE SAVED THIS FILE FIRST!
TARGET_GD_FILE = "E_Genre.gd"


if __name__ == "__main__":
    with open(TARGET_GD_FILE, "rb+") as gd_file:
        try:
            all_contents = gd_file.read()
            
        except UnicodeDecodeError:
            print("HEY! Weird Unicode Nonsense!")
            exit(1)
                
        if all_contents.decode().count(START_SEARCH_PHRASE) <= 0 or all_contents.decode().count(INJECTION_POINT_PHRASE) <= 0:
            print("Key/insertion phrase is wrong!")
            gd_file.close()
            exit(1)
            
        snippet_start = all_contents.decode().find(START_SEARCH_PHRASE) + len(START_SEARCH_PHRASE)
        
        snippet_end = all_contents.decode().find("]", snippet_start)
        
        scales_raw = all_contents.decode()[snippet_start:snippet_end]
        
        #print(scales_raw)
        
        items = re.findall(r'"([^"]+)"', scales_raw)

        #print(f"{items.join(", ")}")
        
        def to_const(s: str) -> str:
            s = s.upper()
            
            # Can't have anything starting with a number 
            if s[0].isalpha() == False and len(s) >= 2:
                
                print(f"{s} got a dodgy enum convert")
                
                if s[0].isdecimal():
                    s += s[0] # add the number at the end... fine if there's one number but the order WILL get reversed... shouldn't have
                s = s[1 : ]
                s = to_const(s)
            elif s[0] in "0123456789" and len(s) < 2:
                print(f"HEY! the string {s} makes a terrible enum because it's just a number... \
                      skipping this one but your enum version of {ORIGINAL_VAR_NAME} wont be 1-to-1")
                return ""
            
            #s = re.sub(r"${1:+a:}", "${2:+e:}", s)  # replace all é with e
            s = re.sub(r"&", "_AND_", s)    # NO '&'
            s = re.sub(r'#', 's', s)        # all '#' becomes 's' becuase 'Sharp'
            s = re.sub(r'[^A-Za-z0-9]+', '_', s)    # all spaces, punctuation, become '_'
            
            
            
            return s.strip('_')

        enum_version = [to_const(x) for x in items]
        
        insertion_point = all_contents.decode().find(INJECTION_POINT_PHRASE)
        
        # Static function if we want to make a String -> Enum function
        translate_str_to_enum = f"""
static func {ORIGINAL_VAR_NAME}_to_{ENUM_VARIABLE_NAME}(string_version : String):
    match string_version:\n"""
        
        TAB = "    "
        
        for string_version in items:
            translate_str_to_enum += f"{TAB}{TAB}\"{string_version.upper()}\":\n{TAB}{TAB}{TAB}return {ENUM_VARIABLE_NAME}.{to_const(string_version)}\n"
        
        translate_str_to_enum += f"{TAB}{TAB}_:\n{TAB}{TAB}{TAB}return {ENUM_VARIABLE_NAME}.{enum_version[0]}"
        
        
        gd_file.seek(insertion_point + len(INJECTION_POINT_PHRASE))
        
        first_comment = f"\n\n# An Enum version of the {ORIGINAL_VAR_NAME} Array"
        gd_file.write(first_comment.encode())
        new_enum_var = f"\nenum {ENUM_VARIABLE_NAME} " + '{'
        gd_file.write(new_enum_var.encode())
        
        index = 0
        for scale in enum_version:
            new_entry = f"{scale}, "
            
            gd_file.write(f"{new_entry:<24}".encode())
            
            index += 1
            if index % 3 == 0:
                gd_file.write("\n".encode())
        
        gd_file.write("}\n".encode())
        
        gd_file.write(f"# A function to translate any {ORIGINAL_VAR_NAME} StringNames to {ENUM_VARIABLE_NAME} Enums\n".encode())
        gd_file.write(f"# NOTE: You must supply the UPPERCASE version...\n".encode())
        gd_file.write(translate_str_to_enum.encode())
        
        gd_file.close()
        
        print("Great success!")