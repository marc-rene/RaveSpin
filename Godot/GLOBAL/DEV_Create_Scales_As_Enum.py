import re

if __name__ == "__main__":
    with open("MusicKey.gd", "r+") as gd_file:
        all_contents = gd_file.read()
        
        key_phrase = "const m_scales_str : Array[StringName] = ["
        insertion_phrase = "### INSERT ENUM VERSION HERE ###"
        
        if all_contents.count(key_phrase) <= 0 or all_contents.count(insertion_phrase) <= 0:
            print("Key/insertion phrase is wrong!")
            exit()
            
        snippet_start = all_contents.find(key_phrase) + len(key_phrase)
        
        snippet_end = all_contents.find("]", snippet_start)
        
        scales_raw = all_contents[snippet_start:snippet_end]
        
        
        print(scales_raw)
        
        
        items = re.findall(r'"([^"]+)"', scales_raw)

        def to_const(s: str) -> str:
            s = s.upper()
            s = re.sub(r'[^A-Z0-9]+', '_', s)  # all spaces, punctuation, become '_'
            return s.strip('_')

        scales_enum = [to_const(x) for x in items]
        
        insertion_point = all_contents.rfind("### INSERT ENUM VERSION HERE ###")
        
        gd_file.seek(insertion_point + len(insertion_phrase))
        
        gd_file.write("\nenum m_scales_enum {")
        
        index = 0
        for scale in scales_enum:
            gd_file.write(f"{scale},     ")
            index += 1
            if index % 4 == 0:
                gd_file.write('\n')
        
        gd_file.write('}')
        
        gd_file.close()