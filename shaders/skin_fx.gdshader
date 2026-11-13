shader_type spatial;
render_mode cull_disabled;
// Animated weapon finishes of the shop skins (Loadout.SKINS, key "fx").
// The pattern follows the model (object space), so it stays on the gun.
// mode 0: hologram scanlines, 1: twinkling galaxy, 2: flowing plasma,
// 3: glitch blocks, 4: rainbow prism, 5: lightning, 6: black hole,
// 7: digital rain, 8: candy cane stripes, 9: snowflakes, 10: Christmas lights.

uniform int mode = 0;
uniform vec3 color_a : source_color = vec3(0.0, 0.9, 1.0);
uniform vec3 color_b : source_color = vec3(0.05, 0.15, 0.35);
uniform float scale = 2.4;

varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

void fragment() {
	vec3 p = local_position * scale;
	float t = TIME;
	vec3 color;
	vec3 glow;
	if (mode == 0) {
		float line = smoothstep(0.35, 0.5, fract(p.y * 3.0 - t * 1.2));
		float pulse = 0.5 + 0.5 * sin(t * 3.0 + p.x);
		color = mix(color_b, color_a, line * 0.7);
		glow = color_a * (0.25 + 0.6 * line * pulse);
	} else if (mode == 1) {
		vec3 cell = floor(p * 3.0);
		float star = step(0.93, hash(cell));
		float twinkle = 0.5 + 0.5 * sin(t * 4.0 + hash(cell + 7.0) * 40.0);
		float nebula = 0.5 + 0.5 * sin(p.x * 1.3 + p.z * 0.7 + t * 0.3);
		color = mix(color_b, vec3(0.35, 0.1, 0.55), nebula * 0.6);
		glow = color_a * star * twinkle * 1.5 + vec3(0.15, 0.05, 0.3) * nebula;
	} else if (mode == 2) {
		float wave = sin(p.x * 2.0 + t * 2.0) + sin(p.y * 3.0 - t * 1.5) + sin((p.x + p.z) * 1.5 + t);
		float k = 0.5 + 0.5 * sin(wave * 1.5);
		color = mix(color_a, color_b, k);
		glow = color * 0.7;
	} else if (mode == 3) {
		vec3 block = floor(p * 1.5) + vec3(0.0, floor(t * 8.0), 0.0);
		float r = hash(block);
		color = r > 0.8 ? color_b : (r > 0.6 ? color_a : vec3(0.04));
		float flash = step(0.97, hash(block + 3.0));
		glow = color * 0.6 + vec3(flash);
	} else if (mode == 5) {
		// Lightning: dark storm, thin bright veins that flicker and move.
		float veins = abs(sin(p.x * 3.1 + sin(p.y * 4.3 + t * 2.0) * 1.6 + sin(p.z * 2.7 - t * 1.3)));
		float bolt = smoothstep(0.08, 0.0, veins);
		float flicker = step(0.35, fract(sin(floor(t * 12.0)) * 43758.5));
		color = mix(color_b, color_a * 0.4, 0.2);
		glow = color_a * bolt * (1.2 + 2.0 * flicker) + color_a * 0.04;
	} else if (mode == 7) {
		// Digital rain: columns of glowing glyph blocks falling, each at its
		// own speed, a bright head and a fading trail.
		float column = floor(p.x * 4.0 + p.z * 4.0);
		float speed = 1.5 + hash(vec3(column, 1.0, 7.0)) * 2.5;
		float fall = fract(-p.y * 0.6 + t * speed * 0.25 + hash(vec3(column, 3.0, 1.0)));
		vec3 cell = floor(vec3(p.x * 4.0, p.y * 6.0 + floor(t * 6.0), p.z * 4.0));
		float glyph = step(0.35, hash(cell));
		float trail = pow(fall, 3.0) * glyph;
		color = color_b;
		glow = color_a * trail * 1.4 + vec3(0.8, 1.0, 0.85) * step(0.97, fall) * glyph;
	} else if (mode == 8) {
		// Candy cane: diagonal red and white stripes sliding along.
		float stripe = step(0.5, fract((p.x + p.y) * 1.2 - t * 0.4));
		color = mix(color_a, color_b, stripe);
		glow = color * 0.15;
	} else if (mode == 9) {
		// Snowflakes: icy blue, white crystals twinkling.
		vec3 cell = floor(p * 3.5);
		vec3 f = fract(p * 3.5) - 0.5;
		float arm = min(abs(f.x), min(abs(f.y), abs(f.x - f.y)));
		float flake = step(0.85, hash(cell)) * smoothstep(0.06, 0.0, arm) * step(length(f), 0.45);
		float twinkle = 0.5 + 0.5 * sin(t * 3.0 + hash(cell + 2.0) * 30.0);
		color = mix(color_b, color_a, 0.25 + 0.15 * sin(p.y * 2.0 + t));
		glow = color_a * flake * (0.6 + twinkle);
	} else if (mode == 10) {
		// Christmas lights: a dark green cord with bulbs blinking in turn.
		vec3 cell = floor(p * 2.5);
		vec3 f = fract(p * 2.5) - 0.5;
		float bulb = smoothstep(0.22, 0.12, length(f));
		float h = hash(cell);
		vec3 bulb_color = h < 0.25 ? vec3(1.0, 0.15, 0.15) : (h < 0.5 ? vec3(0.2, 1.0, 0.35) : (h < 0.75 ? vec3(0.3, 0.55, 1.0) : color_a));
		float on = step(0.5, fract(t * 0.8 + h * 3.0));
		color = mix(color_b, bulb_color, bulb);
		glow = bulb_color * bulb * (0.3 + 1.6 * on);
	} else if (mode == 6) {
		// Black hole: pitch black, a glowing ring of fire that swirls in.
		float r = length(p.xy);
		float swirl = sin(atan(p.y, p.x) * 3.0 + r * 4.0 - t * 3.0);
		float ring = smoothstep(0.6, 1.0, swirl) * (0.5 + 0.5 * sin(r * 2.0 - t * 2.0));
		color = color_b;
		glow = color_a * ring * 1.6;
	} else {
		color = hue(fract((p.x + p.y) * 0.25 - t * 0.25));
		glow = color * 0.45;
	}
	ALBEDO = color;
	EMISSION = glow;
	METALLIC = 0.5;
	ROUGHNESS = 0.3;
}
