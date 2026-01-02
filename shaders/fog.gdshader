shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform vec3 color_a : source_color = vec3(0.5, 0.0, 0.8); // Left Color
uniform vec3 color_b : source_color = vec3(0.0, 0.2, 0.5); // Right Color
uniform float distortion_speed : hint_range(0.0, 5.0) = 0.2;
uniform float density : hint_range(0.0, 2.0) = 1.0;
uniform float bloom : hint_range(1.0, 10.0) = 1.0; 

void fragment() {
    // 1. Calculate the base horizontal gradient (0.0 on left, 1.0 on right)
    float grad = UV.x;
    
    // 2. Motion logic
    float time_offset_1 = TIME * distortion_speed * 0.1;
    float time_offset_2 = TIME * distortion_speed * 0.2;
    
    vec4 noise = texture(noise_texture, UV + time_offset_1);
    vec2 distorted_uv = UV + noise.rg * 0.1 - 0.05 + time_offset_2;
    float final_noise = texture(noise_texture, distorted_uv).r;
    
    // 3. Mix colors based on the horizontal gradient
    vec3 mixed_color = mix(color_a, color_b, grad);
    
    // 4. Combine with noise alpha and audio-reactive bloom
    float smoke_alpha = final_noise * density;
    COLOR = vec4(mixed_color * bloom, smoke_alpha);
}