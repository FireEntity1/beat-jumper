shader_type canvas_item;

// filter_linear_mipmap is critical here to enable LOD sampling
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float blur_strength : hint_range(0.0, 5.0) = 2.0;
uniform float darken : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_strength);
    COLOR = mix(color, vec4(0.0, 0.0, 0.0, 1.0), darken);
}