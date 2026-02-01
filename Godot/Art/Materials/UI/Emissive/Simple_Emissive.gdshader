shader_type canvas_item;

uniform vec4 Unlit_Colour : source_color = vec4(1.0);

void fragment() {
	COLOR.r = Unlit_Colour.r;
	COLOR.g = Unlit_Colour.g;
	COLOR.b = Unlit_Colour.b;
    COLOR.a = texture(TEXTURE, UV).a * Unlit_Colour.a;
}

