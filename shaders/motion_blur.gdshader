shader_type canvas_item;

uniform vec2 dir = vec2(0.1, 0.0); // Direction and magnitude of blur
uniform int quality : hint_range(1, 64) = 4;

void vertex() {
    vec2 blurSize = dir * 2.0;
    VERTEX *= abs(blurSize) + 1.0;                    // always expand
    UV = (UV - 0.5) * (abs(blurSize) + 1.0) + 0.5;  // match UV expansion
    // shift so expansion only goes in dir's direction
    VERTEX += blurSize * abs(blurSize) * 0.5;
}

void fragment() {
    vec4 acc = vec4(0.0);
    float total_weight = 0.0;

    // Calculate the step based on quality
    vec2 stepSize = dir / float(quality);

    //for(int i = -quality; i <= quality; i++) {
	for(int i = 0; i <= quality; i++) {
        vec2 offset_uv = UV - (stepSize * float(i));

        // Only sample if the UV is within the [0, 1] range to avoid edge bleeding
        if (offset_uv.x >= 0.0 && offset_uv.x <= 1.0 && offset_uv.y >= 0.0 && offset_uv.y <= 1.0) {
            vec4 samp = texture(TEXTURE, offset_uv);
            acc += samp;
            total_weight += 1.0;
        }
    }

    // Use max() to prevent division by zero, which causes the HDR "flash"
    if (total_weight > 0.0) {
        COLOR = acc / total_weight;
    } else {
        COLOR = vec4(0.0);
    }
}