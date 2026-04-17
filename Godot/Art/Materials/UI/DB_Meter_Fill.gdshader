shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 0.0;
uniform float warning_alpha : hint_range(0.0, 1.0) = 0.9;

// godot does NOT let us just do either "RGB_from_hex" or "vec4(65/255, 57/255, 11/255)"... I hate gdshader
// btw im getting these from our swatches
// 57, 62, 65
uniform vec4 background_color : source_color = vec4( 0.22, 0.24, 0.25, 1.0);

// 68, 187, 164
uniform vec4 fill_color : source_color = vec4( 0.26, 0.73, 0.64, 1.0);

// 233, 79, 55
uniform vec4 warning_color : source_color = vec4(0.91, 0.3, 0.21, 1.0);

// 237, 174, 73
uniform vec4 border_color : source_color = vec4(0.93, 0.68, 0.29, 0.5);

const float border_width = 0.02;

void fragment() 
{
    float clamped_alpha = clamp(alpha, 0.0, 1.0);
    float fill_start = 1.0 - clamped_alpha;
    float fill_mask = step(fill_start, UV.y);
    float border_mask = step(UV.x, border_width)
        + step(1.0 - border_width, UV.x)
        + step(UV.y, border_width)
        + step(1.0 - border_width, UV.y);

    vec4 active_fill_color = fill_color;
    if (clamped_alpha >= warning_alpha) {
        active_fill_color = warning_color;
        }

    vec4 color = mix(background_color, active_fill_color, fill_mask);
    color = mix(color, border_color, clamp(border_mask, 0.0, 1.0));
    COLOR = color;
}
