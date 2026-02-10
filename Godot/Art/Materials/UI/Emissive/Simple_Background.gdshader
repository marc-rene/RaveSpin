shader_type canvas_item;

uniform vec4 Force_Background_Colour : source_color = vec4(0.4, 0.4, 0.4, 1);

// If enabled, everything will get wonky if the Alpha_Cutoff_Point is >= 0.5
uniform bool Enable_Cheap_Blend = false;

uniform float Alpha_Cutoff_Point : hint_range(0.01, 0.99, 0.01) = 0.0001f;

void fragment() {
    if (texture(TEXTURE, UV).a <= Alpha_Cutoff_Point)
    {
        COLOR.r = Force_Background_Colour.r;
        COLOR.g = Force_Background_Colour.g;
        COLOR.b = Force_Background_Colour.b;
    }
    else if (Enable_Cheap_Blend && (texture(TEXTURE, UV).a <= (Alpha_Cutoff_Point * 2.0f)))
    {
        COLOR.r = Force_Background_Colour.r * texture(TEXTURE, UV).r ;
        COLOR.g = Force_Background_Colour.g * texture(TEXTURE, UV).g;
        COLOR.b = Force_Background_Colour.b * texture(TEXTURE, UV).b;
    }
    else
    {
        COLOR.r = texture(TEXTURE, UV).r;
        COLOR.g = texture(TEXTURE, UV).g;
        COLOR.b = texture(TEXTURE, UV).b;
    }    
    
    
    COLOR.a = Force_Background_Colour.a;
}

