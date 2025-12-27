shader_type canvas_item;

uniform sampler2D texture_albedo : source_color;
uniform vec4 color_main : source_color = vec4(1.0, 0.0, 0.9, 1.0);
uniform vec4 color_accent : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 color_glow : source_color = vec4(0.5, 0.0, 1.0, 1.0);
uniform float scanline_speed : hint_range(0.0, 2.0) = 0.5;
uniform float scanline_density : hint_range(1.0, 100.0) = 50.0;
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.005;
uniform float brightness : hint_range(0.5, 2.0) = 1.2;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

uniform bool is_circle = true;
uniform float circle_softness : hint_range(0.0, 0.1) = 0.005;
uniform float edge_thickness : hint_range(0.01, 0.1) = 0.03;
uniform float edge_intensity : hint_range(1.0, 3.0) = 1.5;

void fragment() {
	vec2 uv = UV;
	
	float r = texture(texture_albedo, uv + vec2(chromatic_aberration, 0.0)).r;
	float g = texture(texture_albedo, uv).g;
	float b = texture(texture_albedo, uv - vec2(chromatic_aberration, 0.0)).b;
	float base_alpha = texture(texture_albedo, uv).a;
	
	float dist = distance(uv, vec2(0.5));
	vec3 added_edge_glow = vec3(0.0);
	
	if (is_circle) {
		base_alpha *= smoothstep(0.5, 0.5 - circle_softness, dist);
		
		float edge_factor = smoothstep(0.5 - edge_thickness, 0.5, dist);
		added_edge_glow = color_accent.rgb * edge_factor * edge_intensity;
	}
	
	vec3 tex_color = vec3(r, g, b);
	
	float gradient_weight = pow(uv.y, 2.0); 
	vec3 synth_grad = mix(color_main.rgb, color_accent.rgb, gradient_weight);
	
	float pulse = (sin(TIME * 2.0) * 0.1) + 0.9;
	synth_grad += color_glow.rgb * (1.0 - dist) * 0.4 * pulse;
	
	float scanline_mask = sin(uv.y * scanline_density - TIME * scanline_speed * 10.0);
	scanline_mask = smoothstep(-0.2, 0.2, scanline_mask);
	
	vec3 final_rgb = tex_color * synth_grad;
	final_rgb += added_edge_glow;
	final_rgb *= brightness;

	COLOR = vec4(final_rgb, base_alpha * scanline_mask * opacity);
}

//void light() {
    //LIGHT = vec4(0.0);
//}