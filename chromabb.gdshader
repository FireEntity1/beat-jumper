shader_type canvas_item;

uniform float intensity : hint_range(0.0, 10.0) = 1.0; // Strength of the chromatic aberration effect

void fragment() {
    // Base UV coordinates
    vec2 uv = UV;

    // Offset amount for the color channels
    vec2 offset = vec2(intensity) * 0.001;

    // Sample red channel with a positive offset
    vec4 red_channel = texture(TEXTURE, uv + vec2(offset.x, -offset.y));

    // Sample green channel at the base UV
    vec4 green_channel = texture(TEXTURE, uv);

    // Sample blue channel with a negative offset
    vec4 blue_channel = texture(TEXTURE, uv - vec2(offset.x, offset.y));

    // Combine the RGB channels with their respective samples
    COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, green_channel.a);
}
