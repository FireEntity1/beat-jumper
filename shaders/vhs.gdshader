//---CRT Shader---
shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0; // 0 = invisible, 1 = full effect

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

vec2 uv_curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.0;

    uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);

    uv = (uv / 2.0) + 0.5;
    return uv;
}

void fragment()
{    
    float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * 0.0), 0.0).r;
    float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * 3.0), 0.0).g;
    float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * -3.0), 0.0).b;

    float s = sin(uv_curve(SCREEN_UV).y * scanline_count * PI * 2.0);
    s = (s * 0.5 + 0.5) * 0.9 + 0.1;
    vec4 scan_line = vec4(vec3(pow(s, 0.55)), 1.0);

    vec4 crt_color = vec4(r, g, b, 1.0) * scan_line;
    COLOR = mix(vec4(0.0), crt_color, intensity);
}
