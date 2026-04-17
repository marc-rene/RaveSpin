shader_type canvas_item;

uniform vec4 Force_Foreground_Colour : source_color = vec4(1.0);

void fragment() 
{
    COLOR.r = Force_Foreground_Colour.r;
    COLOR.g = Force_Foreground_Colour.g;
    COLOR.b = Force_Foreground_Colour.b;
    COLOR.a = texture(TEXTURE, UV).a * Force_Foreground_Colour.a;
}

