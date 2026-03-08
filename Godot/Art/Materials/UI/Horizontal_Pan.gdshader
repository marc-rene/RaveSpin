shader_type canvas_item;

// 0..1: pan position — center of the rect shows this point on the texture
uniform float alpha : hint_range(0.0, 1.0) = 0.0;

// Whatever image we have, force this one instead (set alpha to 0 if you want to use texture instead
uniform vec4 force_colour : source_color = vec4(1.0,1.0,1.0,1.0);

//uniform sampler2D source_texture : hint_default_white;
//uniform bool use_source_texture = false;

// Skinny line down the middle (center = playhead)
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float line_width : hint_range(0.0, 0.01) = 0.002; // in UV (0.5 = half the rect)

void fragment() {
    // Map rect UV so that center (0.5) == alpha on the texture
    vec2 uv = UV;
    uv.x = clamp(uv.x - 0.5 + alpha, 0.0, 1.0);

    vec4 final_colour;
    if (force_colour.a > 0.01)
    {
        final_colour = force_colour;
        final_colour.a = texture(TEXTURE, uv).a;
    }
    else
    {
        final_colour = texture(TEXTURE, uv);
    }
    
    //COLOR.a = texture(TEXTURE, uv).a;

    // Draw a skinny vertical line down the middle
    float dist_from_center = abs(UV.x - 0.5);
    if (dist_from_center < line_width) 
    {
        COLOR.r = line_color.r * final_colour.r;
        COLOR.g = line_color.g * final_colour.g;
        COLOR.b = line_color.b * final_colour.b;
        COLOR.a = 1.0 - final_colour.a;
    }
    else
    {
        COLOR = final_colour;
    }
}
