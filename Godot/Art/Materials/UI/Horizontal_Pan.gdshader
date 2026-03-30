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

// Loop markers (absolute position in the waveform texture 0..1).
// They are rendered relative to the current `alpha` (playhead at center).
uniform float loop_start_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float loop_end_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float loop_start_visible : hint_range(0.0, 1.0) = 0.0; // 0/1
uniform float loop_end_visible : hint_range(0.0, 1.0) = 0.0;   // 0/1
uniform vec4 loop_start_color : source_color = vec4(0.2, 0.8, 0.4, 1.0);
uniform vec4 loop_end_color : source_color = vec4(0.9, 0.3, 0.2, 1.0);
uniform float loop_marker_width : hint_range(0.0, 0.02) = 0.003;
uniform float hot_cue_marker_width : hint_range(0.0, 0.02) = 0.002;
uniform vec4 hot_cue_1_color : source_color = vec4(0.99, 0.46, 0.24, 1.0);
uniform vec4 hot_cue_2_color : source_color = vec4(0.99, 0.73, 0.21, 1.0);
uniform vec4 hot_cue_3_color : source_color = vec4(0.98, 0.93, 0.31, 1.0);
uniform vec4 hot_cue_4_color : source_color = vec4(0.53, 0.91, 0.35, 1.0);
uniform vec4 hot_cue_5_color : source_color = vec4(0.30, 0.86, 0.78, 1.0);
uniform vec4 hot_cue_6_color : source_color = vec4(0.35, 0.64, 0.98, 1.0);
uniform vec4 hot_cue_7_color : source_color = vec4(0.66, 0.47, 0.96, 1.0);
uniform vec4 hot_cue_8_color : source_color = vec4(0.94, 0.37, 0.72, 1.0);
uniform float hot_cue_1_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_2_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_3_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_4_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_5_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_6_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_7_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_8_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_1_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_2_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_3_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_4_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_5_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_6_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_7_visible : hint_range(0.0, 1.0) = 0.0;
uniform float hot_cue_8_visible : hint_range(0.0, 1.0) = 0.0;
uniform float cue_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float cue_visible : hint_range(0.0, 1.0) = 0.0;
uniform vec4 cue_color : source_color = vec4(0.15, 0.75, 1.0, 1.0);
uniform float cue_marker_width : hint_range(0.0, 0.02) = 0.0025;

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

    // Default output
    COLOR = final_colour;

    // Loop markers are at screen-x where the sampled waveform u == marker_alpha.
    // Since u = UV.x - 0.5 + alpha, we solve for UV.x:
    // UV.x = marker_alpha - alpha + 0.5
    float loop_start_x = loop_start_alpha - alpha + 0.5;
    float loop_end_x = loop_end_alpha - alpha + 0.5;

    bool should_continue = true;
    
    if (loop_start_visible > 0.5 && loop_start_x >= 0.0 && loop_start_x <= 1.0) {
        float d = abs(UV.x - loop_start_x);
        if (d < loop_marker_width) {
            COLOR.rgb = loop_start_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue)
    {
        if (loop_end_visible > 0.5 && loop_end_x >= 0.0 && loop_end_x <= 1.0) {
            float d = abs(UV.x - loop_end_x);
            if (d < loop_marker_width) {
                COLOR.rgb = loop_end_color.rgb * final_colour.rgb;
                COLOR.a = 1.0 - final_colour.a;
                should_continue = false;
            }
        }
    }

    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_1_alpha - alpha + 0.5;
        if (hot_cue_1_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_1_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_2_alpha - alpha + 0.5;
        if (hot_cue_2_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_2_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_3_alpha - alpha + 0.5;
        if (hot_cue_3_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_3_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_4_alpha - alpha + 0.5;
        if (hot_cue_4_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_4_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_5_alpha - alpha + 0.5;
        if (hot_cue_5_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_5_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_6_alpha - alpha + 0.5;
        if (hot_cue_6_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_6_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_7_alpha - alpha + 0.5;
        if (hot_cue_7_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_7_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }
    if (should_continue && UV.y >= 0.75) {
        float hot_cue_x = hot_cue_8_alpha - alpha + 0.5;
        if (hot_cue_8_visible > 0.5 && hot_cue_x >= 0.0 && hot_cue_x <= 1.0 && abs(UV.x - hot_cue_x) < hot_cue_marker_width) {
            COLOR.rgb = hot_cue_8_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }

    if (should_continue) {
        float cue_x = cue_alpha - alpha + 0.5;
        if (cue_visible > 0.5 && cue_x >= 0.0 && cue_x <= 1.0 && abs(UV.x - cue_x) < cue_marker_width) {
            COLOR.rgb = cue_color.rgb * final_colour.rgb;
            COLOR.a = 1.0 - final_colour.a;
            should_continue = false;
        }
    }

        
    if (should_continue)
    {
        // Draw a skinny vertical line down the middle (playhead). Render on top.
        float dist_from_center = abs(UV.x - 0.5);
        if (dist_from_center < line_width) {
            COLOR.r = line_color.r * final_colour.r;
            COLOR.g = line_color.g * final_colour.g;
            COLOR.b = line_color.b * final_colour.b;
            COLOR.a = 1.0 - final_colour.a;
        }
    }
}
