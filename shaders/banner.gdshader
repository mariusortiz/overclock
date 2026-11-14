shader_type canvas_item;
// Profile banners (Titles.BANNERS): a moving pattern in two colors.
// mode 0: gradient, 1: grid, 2: stars, 3: waves, 4: fire, 5: code rain,
// 6: stripes, 7: aurora, 8: hexagons, 9: gold, 10: ice, 11: sunset.

uniform int mode = 0;
uniform vec3 color_a : source_color = vec3(0.16, 0.83, 1.0);
uniform vec3 color_b : source_color = vec3(1.0, 0.24, 0.95);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	// Banners are wide: work in a space about 4 units across.
	vec2 p = vec2(uv.x * 4.0, uv.y);
	float t = TIME;
	vec3 color;
	if (mode == 0) {
		color = mix(color_a, color_b, clamp(uv.x + 0.15 * sin(t + uv.y * 3.0), 0.0, 1.0));
	} else if (mode == 1) {
		vec2 g = abs(fract(vec2(p.x * 3.0 - t * 0.2, p.y * 3.0)) - 0.5);
		float line = smoothstep(0.46, 0.5, max(g.x, g.y));
		color = mix(color_b, color_a, line + 0.15 * uv.y);
	} else if (mode == 2) {
		vec2 cell = floor(p * vec2(10.0, 6.0));
		float star = step(0.92, hash(cell)) * (0.5 + 0.5 * sin(t * 3.0 + hash(cell + 1.0) * 20.0));
		color = mix(color_b, color_b * 1.8, uv.y) + color_a * star;
	} else if (mode == 3) {
		float wave = sin(p.x * 3.0 + t * 1.5 + sin(p.y * 6.0)) * 0.5 + 0.5;
		color = mix(color_b, color_a, wave * uv.y + 0.2);
	} else if (mode == 4) {
		float n = hash(floor(vec2(p.x * 8.0, p.y * 4.0 + t * 3.0)));
		float flame = smoothstep(0.1, 1.0, (1.0 - uv.y) * (0.6 + 0.6 * n));
		color = mix(color_b * 0.4, color_a, flame);
	} else if (mode == 5) {
		float column = floor(p.x * 12.0);
		float drop = fract(uv.y * 2.0 - t * (0.4 + hash(vec2(column)) * 0.6) - hash(vec2(column, 3.0)));
		float glyph = step(0.5, hash(floor(vec2(p.x * 12.0, uv.y * 14.0 + floor(t * 6.0)))));
		color = color_b + color_a * pow(drop, 3.0) * glyph;
	} else if (mode == 6) {
		float stripe = step(0.5, fract(p.x * 2.0 + uv.y - t * 0.3));
		color = mix(color_b, color_a, stripe * 0.85);
	} else if (mode == 7) {
		float band = sin(p.x * 1.5 + t * 0.6) * 0.25 + 0.5;
		float glow = smoothstep(0.3, 0.0, abs(uv.y - band));
		color = mix(vec3(0.01, 0.02, 0.06), mix(color_a, color_b, fract(p.x * 0.25 + t * 0.05)), glow);
	} else if (mode == 8) {
		vec2 q = p * vec2(5.0, 6.0);
		q.x += step(1.0, mod(q.y, 2.0)) * 0.5;
		vec2 f = abs(fract(q) - 0.5);
		float edge = smoothstep(0.38, 0.45, max(f.x * 1.15 + f.y * 0.6, f.y * 1.2));
		color = mix(color_b, color_a, edge * (0.6 + 0.4 * sin(t * 2.0 + q.x)));
	} else if (mode == 9) {
		float sheen = smoothstep(0.2, 0.0, abs(fract(p.x * 0.3 - t * 0.25) - 0.5));
		color = mix(color_b, color_a, 0.5 + 0.4 * sin(p.x * 2.0 + uv.y * 4.0)) + color_a * sheen * 0.6;
	} else if (mode == 10) {
		vec2 cell = floor(p * vec2(8.0, 5.0));
		float crystal = hash(cell);
		color = mix(color_b, color_a, 0.4 + 0.5 * crystal * (0.7 + 0.3 * sin(t + crystal * 10.0)));
	} else {
		color = mix(color_a, color_b, smoothstep(0.0, 1.0, uv.y + 0.08 * sin(p.x * 2.0 + t)));
		float sun = smoothstep(0.32, 0.28, length((uv - vec2(0.8, 0.75)) * vec2(4.0, 1.0)));
		color = mix(color, vec3(1.0, 0.9, 0.5), sun);
	}
	COLOR = vec4(color, 1.0);
}
