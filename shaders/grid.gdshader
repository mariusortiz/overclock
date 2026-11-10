// Glowing world-space grid for floors. Grid lines follow the XZ plane.
shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.05, 0.05, 0.09, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 0.9, 1.0, 1.0);
uniform float cell_size = 2.0;
uniform float glow = 1.5;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_position.xz / cell_size;
	vec2 g = abs(fract(p - 0.5) - 0.5) / fwidth(p);
	float line = 1.0 - min(min(g.x, g.y), 1.0);
	ALBEDO = mix(base_color.rgb, line_color.rgb, line);
	EMISSION = line_color.rgb * line * glow;
	ROUGHNESS = 0.7;
}
