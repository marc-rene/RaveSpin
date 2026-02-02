import re

# What will we start looking for our array from? like 'const String_Array : Array[StringName] = ['
START_SEARCH_PHRASE = "const Track_Origins_str : Array[StringName] = ["
ORIGINAL_VAR_NAME = "Track_Origins_str"

# Where will we insert our Enum?
INJECTION_POINT_PHRASE = "### INSERT ENUM VERSION HERE ###"

# 'enum will be placed automatically before init
ENUM_VARIABLE_NAME = "Track_Origins_enum"

TARGET_GD_FILE = "E_Track_Origins.gd"


if __name__ == "__main__":
    with open(TARGET_GD_FILE, "r+") as gd_file:
        all_contents = gd_file.read()
                
        if all_contents.count(START_SEARCH_PHRASE) <= 0 or all_contents.count(INJECTION_POINT_PHRASE) <= 0:
            print("Key/insertion phrase is wrong!")
            gd_file.close()
            exit(1)
            
        snippet_start = all_contents.find(START_SEARCH_PHRASE) + len(START_SEARCH_PHRASE)
        
        snippet_end = all_contents.find("]", snippet_start)
        
        scales_raw = all_contents[snippet_start:snippet_end]
        
        #print(scales_raw)
        
        items = re.findall(r'"([^"]+)"', scales_raw)

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

            s = re.sub(r'#', 's', s)  # all # becomes 's' becuase 'Sharp'
            s = re.sub(r'[^A-Za-z0-9]+', '_', s)  # all spaces, punctuation, become '_'
            
            
            
            return s.strip('_')

        enum_version = [to_const(x) for x in items]
        
        insertion_point = all_contents.rfind("### INSERT ENUM VERSION HERE ###")
        
        # Static function if we want to make a String -> Enum function
        translate_str_to_enum = f"""
static func {ORIGINAL_VAR_NAME}_to_{ENUM_VARIABLE_NAME}(string_version : String):
    match string_version:\n"""
        
        for string_version in items:
            translate_str_to_enum += f"\t\t\"{string_version.upper()}\":\n\t\t\treturn {ENUM_VARIABLE_NAME}.{to_const(string_version)}\n"
        
        translate_str_to_enum += f"\t\t_:\n\t\t\treturn {ENUM_VARIABLE_NAME}.{enum_version[0]}"
        
        
        gd_file.seek(insertion_point + len(INJECTION_POINT_PHRASE))
        
        first_comment = f"\n\n# An Enum version of the {ORIGINAL_VAR_NAME} Array"
        gd_file.write(first_comment)
        new_enum_var = f"\nenum {ENUM_VARIABLE_NAME} " + '{'
        gd_file.write(new_enum_var)
        
        index = 0
        for scale in enum_version:
            new_entry = f"{scale}, "
            
            gd_file.write(f"{new_entry:<24}")
            
            index += 1
            if index % 3 == 0:
                gd_file.write('\n')
        
        gd_file.write('}\n\n')
        
        gd_file.write(f"# A function to translate any {ORIGINAL_VAR_NAME} StringNames to {ENUM_VARIABLE_NAME} Enums\n")
        gd_file.write(f"# NOTE: You must supply the UPPERCASE version...\n")
        gd_file.write(translate_str_to_enum)
        
        gd_file.close()
        
        print("Great success!")