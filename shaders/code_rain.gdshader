shader_type spatial;
// The Matrice arena's surfaces, in world space so that every box matches:
// on walls and towers, columns of green glyphs falling at their own pace;
// on floors and roofs, a dark tile with a glowing green grid.

uniform vec4 code_color : source_color = vec4(0.2, 1.0, 0.45, 1.0);
uniform vec4 base_color : source_color = vec4(0.01, 0.04, 0.02, 1.0);
// Size of a glyph, in meters.
uniform float cell = 0.3;
uniform float speed = 1.0;
// Grid spacing on the floor, in meters.
uniform float grid = 2.0;

varying vec3 world_position;
varying vec3 world_normal;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(world_normal);
	ALBEDO = base_color.rgb;
	ROUGHNESS = 0.6;
	if (world_normal.y < -0.7) {
		// Undersides (bridges, platforms): plain dark.
		EMISSION = code_color.rgb * 0.03;
	} else if (n.y > 0.7) {
		vec2 g = abs(fract(world_position.xz / grid) - 0.5) * 2.0;
		float line = smoothstep(0.92, 0.985, max(g.x, g.y));
		float pulse = 0.6 + 0.4 * sin(TIME * 1.5 + (world_position.x + world_position.z) * 0.15);
		EMISSION = code_color.rgb * line * pulse * 0.9;
	} else {
		vec2 uv = vec2(n.x > n.z ? world_position.z : world_position.x, world_position.y);
		vec2 c = floor(uv / cell);
		// Each column falls at its own speed, its bright head leaving a trail.
		float rows = 36.0;
		float head = fract(-TIME * speed * (0.15 + 0.2 * hash(vec2(c.x, 3.0))) + hash(vec2(c.x, 9.0)));
		float trail = fract(mod(c.y, rows) / rows - head);
		float bright = pow(1.0 - trail, 5.0);
		// A glyph: a few lit pixels of a 3 x 5 grid, changing now and then.
		vec2 f = fract(uv / cell);
		vec2 pixel = floor(vec2(f.x * 3.0, f.y * 5.0));
		float change = floor(TIME * (1.0 + 4.0 * hash(c)));
		float lit = step(0.45, hash(c * 7.0 + pixel + change));
		float inside = step(0.1, f.x) * step(f.x, 0.9) * step(0.08, f.y) * step(f.y, 0.92);
		EMISSION = code_color.rgb * lit * inside * (0.08 + bright * 1.6);
	}
}
