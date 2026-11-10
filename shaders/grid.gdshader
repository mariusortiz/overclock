// Tiled floor with a glowing world-space grid. Everything follows the XZ plane,
// so the pattern stays aligned whatever the mesh size.
shader_type spatial;

uniform sampler2D floor_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float texture_size = 4.0; // world meters covered by one texture repeat
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
	vec3 base = texture(floor_texture, world_position.xz / texture_size).rgb;
	ALBEDO = mix(base, line_color.rgb, line);
	EMISSION = line_color.rgb * line * glow;
	ROUGHNESS = 0.7;
}
