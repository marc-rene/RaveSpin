shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform vec4 start_colour : source_color = vec4(0.0, 0.0, 0.0, 0.85); // colour + max alpha
uniform float fade_start = 0.0; // 0 = top, 1 = bottom (after flip)
uniform float fade_end   = 1.0; // where it reaches fully transparent
uniform bool flip = false;           // false == top->bottom, true == bottom->top




void fragment() {
    float temp_y = UV.y;
    
    if (flip == true)
    {
      temp_y = 1.0 - temp_y;  
    } 

    float denom = max(0.00001, fade_end - fade_start);
    float t = clamp((temp_y - fade_start) / denom, 0.0, 1.0);

    // eased fade: 1 at start, 0 at end
    float temp_alpha = 1.0 - smoothstep(0.0, 1.0, t);

    COLOR = vec4(start_colour.rgb, start_colour.a * temp_alpha);
}