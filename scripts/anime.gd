extends Node
## Directs "Overclock, épisode 1 : L'escouade", a two-minute anime-style short
## played by the engine with the game's models: cel shading (flat light bands
## and black outlines), manga speech bubbles, speed lines and impact frames.
##
## The Soldier meets the Kunoichi in the station, the Captain in the desert
## and the Ronin in the jungle; the four of them bring down the Titan.
##
## Rendered by .github/workflows/anime.yml with Godot's movie mode, like the
## trailer:
##   godot --write-movie anime.avi --fixed-fps 30 res://scenes/tools/anime.tscn

const DURATION := 122.0
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const URL := "mariusortiz.github.io/overclock-builds"
const WORLD_LAYER := 1
const BAR_HEIGHT := 0.085
const ARENAS := ["station", "desert", "jungle", "volcano", "city"]
## Where everything happens: the clear ground around the player's spawn.
const STAGE := Vector3(0, 0.1, 16)
const HERO_HEIGHT := 1.75
const TITAN_HEIGHT := 9.0
const CYAN := Color(0.16, 0.9, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)

## Two-tone lighting, a rim of light on the edges, the material's color or
## texture (UV or, like the arena boxes, triplanar).
const TOON_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform bool use_texture = false;
uniform bool triplanar = false;
uniform float uv_scale = 1.0;
uniform vec3 emission : source_color = vec3(0.0);
varying vec3 local_position;
varying vec3 local_normal;
void vertex() {
	local_position = VERTEX * uv_scale;
	local_normal = abs(NORMAL);
}
void fragment() {
	vec4 color = albedo;
	if (use_texture) {
		if (triplanar) {
			vec3 w = local_normal / max(local_normal.x + local_normal.y + local_normal.z, 0.001);
			color *= texture(albedo_texture, local_position.zy) * w.x
					+ texture(albedo_texture, local_position.xz) * w.y
					+ texture(albedo_texture, local_position.xy) * w.z;
		} else {
			color *= texture(albedo_texture, UV);
		}
	}
	ALBEDO = color.rgb;
	float rim = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	EMISSION = emission + color.rgb * step(0.75, rim) * 0.3;
}
void light() {
	float lit = smoothstep(0.0, 0.05, dot(NORMAL, LIGHT) * ATTENUATION);
	DIFFUSE_LIGHT += LIGHT_COLOR / PI * lit;
}
"""
## Drawn behind the model, pushed out along the normals by a few pixels
## whatever the distance: the ink line around every shape.
const OUTLINE_SHADER := """
shader_type spatial;
render_mode unshaded, cull_front;
uniform float width = 4.0;
uniform vec4 color : source_color = vec4(0.03, 0.02, 0.06, 1.0);
void vertex() {
	vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 normal = mat3(MODELVIEW_MATRIX) * NORMAL;
	vec2 direction = (PROJECTION_MATRIX * vec4(normal, 0.0)).xy;
	if (length(direction) > 0.0001) {
		direction = normalize(direction);
	}
	clip.xy += direction / VIEWPORT_SIZE * width * 2.0 * clip.w;
	POSITION = clip;
}
void fragment() {
	ALBEDO = color.rgb;
}
"""
## The impact frame: for a few frames the picture turns to black and white
## ink, negative.
const IMPACT_SHADER := """
shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_linear;
void fragment() {
	vec3 color = texture(screen, SCREEN_UV).rgb;
	float light = dot(color, vec3(0.3, 0.59, 0.11));
	float ink = 1.0 - step(0.42, light);
	COLOR = vec4(mix(vec3(0.05, 0.02, 0.08), vec3(1.0, 0.97, 0.92), ink), 1.0);
}
"""


## A manga speech bubble that follows the head of its speaker on screen. A
## line that ends with "!" is shouted: the bubble is spiky.
class Bubble extends Control:
	const PADDING := Vector2(34, 22)
	const BARS := 0.085
	const MAX_WIDTH := 430.0
	var speaker: Node3D
	var head := 1.9
	var side := 1.0
	var shout := false
	var label := Label.new()

	func _init(text: String, font: Font) -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		shout = text.ends_with("!")
		label.text = text
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 30 if shout else 27)
		label.add_theme_color_override("font_color", Color.BLACK)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
		if width > MAX_WIDTH:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.custom_minimum_size.x = MAX_WIDTH
		add_child(label)

	func _ready() -> void:
		size = label.get_combined_minimum_size() + PADDING * 2.0 * (1.25 if shout else 1.0)
		label.position = (size - label.get_combined_minimum_size()) / 2.0
		label.size = label.get_combined_minimum_size()
		pivot_offset = size / 2.0

	## Places the bubble beside the speaker's head on screen.
	func follow(camera: Camera3D, screen: Vector2) -> void:
		var tip := Vector2(screen.x * 0.5, screen.y * 0.2)
		if is_instance_valid(speaker):
			var at := speaker.global_position + Vector3.UP * head
			if not camera.is_position_behind(at):
				tip = camera.unproject_position(at)
		var center := tip + Vector2(side * (size.x * 0.5 + 60.0), -size.y * 0.5 - 70.0)
		var margin := Vector2(30, screen.y * BARS + 20)
		center.x = clampf(center.x, margin.x + size.x / 2.0, screen.x - margin.x - size.x / 2.0)
		center.y = clampf(center.y, margin.y + size.y / 2.0, screen.y - margin.y - size.y / 2.0)
		position = center - size / 2.0
		set_meta("tip", tip - position)
		queue_redraw()

	func _draw() -> void:
		var middle := size / 2.0
		var radius := size / 2.0
		var outline := PackedVector2Array()
		var points := 48 if shout else 40
		for i in points:
			var angle := TAU * i / points
			var r := radius * (1.18 if shout and i % 2 == 0 else 1.0)
			outline.append(middle + Vector2(cos(angle) * r.x, sin(angle) * r.y))
		# The tail: from the bubble's edge, a third of the way to the head.
		var tip: Vector2 = get_meta("tip", middle + Vector2(0, radius.y * 2.0))
		var toward := middle.direction_to(tip)
		var base := middle + toward * radius * 0.8
		var across := Vector2(-toward.y, toward.x) * 16.0
		var end := base + (tip - base) * 0.45
		var tail := PackedVector2Array([base + across, end, base - across])
		draw_colored_polygon(tail, Color.WHITE)
		draw_polyline(tail, Color.BLACK, 4.0, true)
		draw_colored_polygon(outline, Color.WHITE)
		outline.append(outline[0])
		draw_polyline(outline, Color.BLACK, 4.0, true)


var _clock := 0.0
var _set := Node3D.new()
var _camera := Camera3D.new()
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _look_from := Vector3.ZERO
var _look_to := Vector3.ZERO
var _shot_start := 0.0
var _shot_length := 1.0
var _guarded := false
var _shake := 0.0
## Original material -> its cel-shaded version.
var _toon_materials := {}
var _toon_shader := Shader.new()
var _outline := ShaderMaterial.new()
## [character, holder]: items kept in a right hand.
var _held: Array[Array] = []
## [pivot, velocity]: actors moving on their own.
var _movers: Array[Array] = []
var _bubbles: Array[Bubble] = []
var _cast := {}
var _titan: CharacterModel

var _layer := CanvasLayer.new()
var _speed_lines := Control.new()
var _speed_left := 0.0
var _impact := ColorRect.new()
var _impact_left := 0.0
var _shade := ColorRect.new()
var _narration := Label.new()
var _narration_box := PanelContainer.new()
var _card := Control.new()


func _ready() -> void:
	Music.stop()
	add_child(_set)
	add_child(_camera)
	_camera.far = 400.0
	_camera.make_current()
	_toon_shader.code = TOON_SHADER
	var outline_shader := Shader.new()
	outline_shader.code = OUTLINE_SHADER
	_outline.shader = outline_shader
	_build_overlay()
	_run.call_deferred()


# --- Story --------------------------------------------------------------------

func _run() -> void:
	# 0 s: cold open. The city has fallen; the Titan walks in it.
	_load_arena(4)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -6))
	_titan.play(&"walk")
	_dolly(STAGE + Vector3(-4, 0.6, 9), STAGE + Vector3(-2.5, 1.2, 7), STAGE + Vector3(0, 2, -6),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.85, -6), 8.5)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La ville est tombée.", 3.0)
	await _until(4.8)
	_narrate("Il ne reste qu'une escouade... qui n'existe pas encore.", 3.6)
	await _until(6.5)
	_stomp(_titan.get_parent().position, 1.0)
	await _until(8.6)

	# 8.6 s: title card.
	await _title_card(5.0)

	# 13.6 s: the station. The Soldier, alone, against the guards.
	_load_arena(0)
	var soldier := _hero("soldier", STAGE, 0.0)
	soldier.play(&"aim")
	var guards: Array[Enemy] = []
	for index in 5:
		var spot := STAGE + Vector3(-4.0 + 2.0 * index, 0, -9.0 - 1.4 * (index % 2))
		guards.append(_enemy(spot, PI, &"walk"))
		_move(guards[index].get_parent() as Node3D, Vector3(0, 0, 0.45))
	_dolly(STAGE + Vector3(1.6, 1.5, 2.6), STAGE + Vector3(1.2, 1.7, 2.0), STAGE + Vector3(0, 1.4, -6),
			STAGE + Vector3(0, 1.3, -6), 4.0, true)
	await _until(14.6)
	_say(soldier, "Encore une vague.", 2.4, -1.0)
	await _until(17.6)
	_dolly(STAGE + Vector3(-5, 1.0, -1), STAGE + Vector3(-4.2, 1.2, -2.5), STAGE + Vector3(0, 1.2, -6),
			STAGE + Vector3(0, 1.2, -6), 3.5, true)
	for index in 2:
		await _until(17.8 + 0.6 * index)
		_shoot(soldier, guards[index], &"knockback", CYAN)
	await _until(19.4)
	# One of them gets behind him...
	var sneaky := _enemy(STAGE + Vector3(1.5, 0, 2.8), 0.0, &"aim")
	_dolly(STAGE + Vector3(4, 1.2, 4.5), STAGE + Vector3(3.4, 1.3, 4.0), STAGE + Vector3(0.6, 1.3, 1.2),
			STAGE + Vector3(0.6, 1.3, 1.2), 2.4, true)
	_say(soldier, "...!", 1.2, 1.0)
	await _until(20.6)
	# ...and the Kunoichi drops on him.
	var kunoichi := _hero("kunoichi", STAGE + Vector3(2.2, 6.0, 2.2), PI * 0.75)
	_drop(kunoichi.get_parent() as Node3D, STAGE.y, 0.35)
	await _until(21.0)
	kunoichi.play(&"melee", true)
	_impact_frame()
	_speed(0.6)
	_kill(sneaky, &"petals", Color(1.0, 0.5, 0.8))
	_shake = 0.15
	await _until(21.8)
	_face(soldier, kunoichi)
	_face(kunoichi, soldier)
	_dolly(STAGE + Vector3(4.2, 1.6, -1.0), STAGE + Vector3(3.6, 1.5, -0.6), STAGE + Vector3(1.1, 1.4, 1.1),
			STAGE + Vector3(1.1, 1.4, 1.1), 6.0, true)
	_say(kunoichi, "Besoin d'aide, soldat ?", 2.4, 1.0)
	await _until(24.5)
	_say(soldier, "Je travaille seul.", 2.0, -1.0)
	await _until(26.8)
	_say(kunoichi, "Plus maintenant.", 2.0, 1.0)
	await _until(28.0)
	# Her ultimate: two clones, and the rest of the guards fall.
	kunoichi.play(&"victory", true)
	_face(soldier, guards[3])
	_face(kunoichi, guards[3])
	for side: float in [-1.0, 1.0]:
		var clone := _hero("kunoichi", STAGE + Vector3(2.2 + side * 1.5, 0, 1.0), 0.0)
		_tint(clone, Color(0.4, 0.9, 1.0))
		Effects.burst(_set, clone.global_position + Vector3.UP, CYAN, 30)
	_dolly(STAGE + Vector3(0, 2.5, 7.5), STAGE + Vector3(0, 2.0, 6.0), STAGE + Vector3(0, 1.0, -4),
			STAGE + Vector3(0, 1.0, -5), 4.0, true)
	_speed(1.4)
	for index in range(2, guards.size()):
		await _until(28.6 + 0.3 * (index - 2))
		_slash(guards[index], &"vanish", CYAN)
	await _until(31.6)
	_say(soldier, "...Pas mal.", 1.8, -1.0)
	await _until(33.6)

	# 33.6 s: the desert. A giant skeleton, and the Captain.
	_wipe()
	_load_arena(1)
	soldier = _hero("soldier", STAGE + Vector3(-1.0, 0, 2), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(1.0, 0, 2), 0.0)
	soldier.play(&"aim")
	var brute := _spawn_boss(Boss.Kind.BRUTE, STAGE + Vector3(0, 0, -5), 3.6)
	# Twice the size it has in the game: the heroes look up at it.
	(brute.get_parent() as Node3D).scale = Vector3.ONE * 2.2
	_dolly(STAGE + Vector3(-4.5, 0.5, 6), STAGE + Vector3(-3.5, 0.6, 5), STAGE + Vector3(0, 3.5, -5),
			STAGE + Vector3(0, 4.5, -5), 3.0, true)
	_stomp(STAGE + Vector3(0, 0, -5), 0.7)
	_impact_frame()
	await _until(35.4)
	_say(soldier, "Il est énorme !", 1.8, -1.0)
	await _until(37.4)
	_say(kunoichi, "Mes lames ne passent pas !", 2.0, 1.0)
	kunoichi.play(&"melee", true)
	await _until(39.6)
	var captain := _hero("captain", STAGE + Vector3(5.0, 0, -1.0), 0.0)
	_face(captain, soldier)
	captain.play(&"aim")
	_dolly(STAGE + Vector3(1.6, 1.3, 1.6), STAGE + Vector3(2.2, 1.4, 1.0), STAGE + Vector3(5.0, 1.5, -1.0),
			STAGE + Vector3(5.0, 1.6, -1.0), 3.4, true)
	_say(captain, "Écartez-vous, moussaillons !", 2.6, -1.0)
	await _until(42.8)
	# Broadside: rockets from all sides.
	_face(captain, brute)
	_dolly(STAGE + Vector3(0, 4.0, 9), STAGE + Vector3(0, 5.0, 8), STAGE + Vector3(0, 2.0, -5),
			STAGE + Vector3(0, 2.5, -5), 3.0, true)
	_speed(1.6)
	for index in 8:
		var from := captain.global_position + Vector3(0, 1.4, 0)
		var target := brute.global_position + Vector3(randf_range(-1.5, 1.5), randf_range(1.0, 4.0), 0)
		get_tree().create_timer(0.12 * index).timeout.connect(_rocket.bind(from, target))
	await _until(44.2)
	_impact_frame()
	_shake = 0.3
	_fall(brute, 1.2)
	await _until(46.0)
	_face(soldier, captain)
	_face(captain, soldier)
	_dolly(STAGE + Vector3(2.0, 1.6, 6.5), STAGE + Vector3(2.4, 1.6, 6.0), STAGE + Vector3(2.0, 1.4, 0.5),
			STAGE + Vector3(2.0, 1.4, 0.5), 6.0, true)
	_say(soldier, "Pas mal, pour une pirate.", 2.4, -1.0)
	await _until(48.8)
	_say(captain, "Pas mal, pour un soldat !", 2.4, 1.0)
	await _until(51.6)

	# 51.6 s: the jungle. The Ronin, and the goblins.
	_wipe()
	_load_arena(2)
	var ronin := _hero("ronin", STAGE + Vector3(0, 0, -1), 0.0)
	soldier = _hero("soldier", STAGE + Vector3(-1.5, 0, 4), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(0, 0, 4.4), 0.0)
	captain = _hero("captain", STAGE + Vector3(1.5, 0, 4), 0.0)
	_dolly(STAGE + Vector3(-1.2, 1.4, -4.2), STAGE + Vector3(-0.6, 1.5, -3.6), STAGE + Vector3(0, 1.4, -1),
			STAGE + Vector3(0, 1.5, -1), 4.0, true)
	_say(ronin, "Vous faites trop de bruit.", 2.4, 1.0)
	var goblins: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0
		var spot := STAGE + Vector3(0, 0, -1) + Vector3(cos(angle), 0, sin(angle)) * 5.5
		var goblin := _enemy(spot, 0.0, &"walk")
		(goblin.get_parent() as Node3D).look_at(STAGE + Vector3(0, 0.1, -1))
		var inward := (STAGE + Vector3(0, 0, -1) - spot).normalized() * 0.7
		_move(goblin.get_parent() as Node3D, Vector3(inward.x, 0, inward.z))
		goblins.append(goblin)
	await _until(55.6)
	_dolly(STAGE + Vector3(0, 7.5, 6.0), STAGE + Vector3(0, 6.5, 4.0), STAGE + Vector3(0, 0, -1),
			STAGE + Vector3(0, 0, -1), 3.6, true)
	_say(soldier, "Attention, derrière toi !", 1.8, -1.0)
	await _until(57.4)
	# Whirlwind.
	ronin.play(&"melee", true)
	_ring(STAGE + Vector3(0, 0, -1), Color(1.0, 0.85, 0.9), 13.0, 0.5)
	_speed(1.2)
	_impact_frame()
	for goblin in goblins:
		_kill(goblin, &"leaves", Color(0.6, 1.0, 0.4))
	await _until(59.0)
	ronin.get_parent().rotation.y = PI
	_dolly(STAGE + Vector3(-6.5, 1.6, 1.5), STAGE + Vector3(-6.0, 1.6, 1.8), STAGE + Vector3(0, 1.3, 1.5),
			STAGE + Vector3(0, 1.3, 1.5), 5.0, true)
	_say(kunoichi, "On le garde.", 1.8, 1.0)
	await _until(61.2)
	_say(captain, "Bienvenue à bord !", 2.0, 1.0)
	await _until(63.6)

	# 63.6 s: the volcano. Four of them now, walking toward the city.
	_wipe()
	_load_arena(3)
	var squad := ["soldier", "kunoichi", "captain", "ronin"]
	for index in squad.size():
		var hero := _hero(squad[index], STAGE + Vector3(-3.0 + 2.0 * index, 0, -4), PI)
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, 0.6))
	_dolly(STAGE + Vector3(0, 0.3, 4.5), STAGE + Vector3(0, 0.35, 5.0), STAGE + Vector3(0, 2.4, -3),
			STAGE + Vector3(0, 2.4, -1), 8.0, false)
	_embers(true)
	_narrate("Quatre héros. Une seule cible.", 3.6)
	await _until(68.0)
	_narrate("Le Titan.", 2.6)
	await _until(71.6)
	_embers(false)

	# 71.6 s: the city. The Titan.
	_wipe()
	_load_arena(4)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -8))
	soldier = _hero("soldier", STAGE + Vector3(-1.5, 0, 3), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(-0.5, 0, 3.6), 0.0)
	captain = _hero("captain", STAGE + Vector3(0.5, 0, 3.4), 0.0)
	ronin = _hero("ronin", STAGE + Vector3(1.5, 0, 3.2), 0.0)
	# Tilt up from its feet to its head.
	_dolly(STAGE + Vector3(-1, 0.4, 1.5), STAGE + Vector3(-1, 0.6, 1.0), STAGE + Vector3(0, 0.5, -8),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.9, -8), 4.2, true)
	await _until(74.0)
	_say(soldier, "C'est... énorme.", 2.0, -1.0)
	await _until(76.2)
	_titan.play(&"shoot", true)
	await _until(76.8)
	_stomp(STAGE + Vector3(0, 0, -8), 1.4)
	_impact_frame()
	_speed(1.0)
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.play(&"die", true)
	_dolly(STAGE + Vector3(4, 2.5, 8), STAGE + Vector3(3, 2.0, 7), STAGE + Vector3(0, 0.5, 3),
			STAGE + Vector3(0, 0.6, 3), 3.0, true)
	await _until(78.8)
	# Knocked down: they stay on their knees until they get up again.
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.freeze(&"die", 1.0)
	await _until(79.6)
	_dolly(STAGE + Vector3(-2.2, 0.6, 4.2), STAGE + Vector3(-2.0, 0.7, 3.9), STAGE + Vector3(-1.5, 0.5, 3),
			STAGE + Vector3(-1.5, 0.5, 3), 4.0, true)
	_say(soldier, "Je... je ne peux pas.", 2.4, 1.0)
	await _until(82.4)
	kunoichi.play(&"idle")
	_face(kunoichi, soldier)
	_dolly(STAGE + Vector3(-0.2, 1.4, 6.0), STAGE + Vector3(-0.4, 1.4, 5.2), STAGE + Vector3(-0.5, 1.3, 3.6),
			STAGE + Vector3(-0.5, 1.3, 3.6), 3.0, true)
	_say(kunoichi, "Debout ! On est une escouade !", 2.6, 1.0)
	await _until(85.4)
	captain.play(&"idle")
	ronin.play(&"idle")
	_say(captain, "Tous ensemble !", 1.8, -1.0)
	await _until(87.4)
	_say(ronin, "Maintenant.", 1.6, 1.0)
	await _until(89.2)
	soldier.play(&"idle")
	_face(kunoichi, _titan)
	_dolly(STAGE + Vector3(-1.5, 1.6, 0.9), STAGE + Vector3(-1.5, 1.6, 1.3), STAGE + Vector3(-1.5, 1.5, 3),
			STAGE + Vector3(-1.5, 1.6, 3), 2.6, false)
	_speed(2.6)
	_say(soldier, "OVERCLOCK !", 2.2, 1.0)
	await _until(91.8)

	# 91.8 s: all together.
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.play(&"aim")
	_dolly(STAGE + Vector3(0, 1.0, 8), STAGE + Vector3(0, 2.5, 6), STAGE + Vector3(0, 3, -8),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.6, -8), 6.0, true)
	_speed(6.0)
	var colors := [CYAN, MAGENTA, GOLD, Color(1.0, 0.5, 0.8)]
	var heroes: Array[CharacterModel] = [soldier, kunoichi, captain, ronin]
	for beat in 14:
		await _until(92.0 + 0.32 * beat)
		var hero := heroes[beat % 4]
		hero.play(&"shoot", true)
		var target := _titan.global_position + Vector3(randf_range(-1.5, 1.5), randf_range(3.0, 8.0), 0)
		_beam(hero.global_position + Vector3(0, 1.3, -0.4), target, colors[beat % 4], 0.12)
		Effects.burst(_set, target, colors[beat % 4], 16)
	await _until(96.8)
	_impact_frame()
	_shake = 0.4
	Effects.flash(_set, _titan.global_position + Vector3.UP * 5, Color.WHITE, 30.0, 0.8)
	for index in 6:
		var at := _titan.global_position + Vector3(randf_range(-2, 2), randf_range(1, 8), randf_range(-1, 1))
		get_tree().create_timer(0.15 * index).timeout.connect(Effects.burst.bind(_set, at, GOLD, 50))
	await _until(97.8)
	_impact_frame()
	_fall(_titan, 2.4)
	_dolly(STAGE + Vector3(-6, 1.5, 6), STAGE + Vector3(-5, 2.5, 4), STAGE + Vector3(0, 4, -8),
			STAGE + Vector3(0, 1, -8), 3.6, true)
	await _until(101.4)

	# 101.4 s: victory.
	_wipe()
	var trophy := Trophy.new()
	_set.add_child(trophy)
	trophy.position = STAGE + Vector3(0, 0, -3)
	_ring(trophy.position, GOLD, 10.0, 0.9)
	for hero in heroes:
		hero.play(&"victory", true)
		hero.get_parent().rotation.y = PI
	_dolly(STAGE + Vector3(0, 1.3, 9.0), STAGE + Vector3(0, 1.6, 7.0), STAGE + Vector3(0, 1.4, 0),
			STAGE + Vector3(0, 1.6, -1), 7.0, true)
	await _until(102.6)
	_say(captain, "On a réussi !", 1.8, 1.0)
	await _until(104.6)
	_say(soldier, "Prochaine vague ?", 2.0, -1.0)
	await _until(106.8)
	for index in heroes.size():
		_say(heroes[index], "PROCHAINE VAGUE !", 2.2, -1.0 if index < 2 else 1.0)
	_speed(2.2)
	await _until(109.4)

	# 109.4 s: to be continued, then the end card.
	_shade.color = Color(0, 0, 0, 0)
	_fade_shade(0.85, 0.4)
	_narrate("À SUIVRE...", 3.0, true)
	await _until(112.8)
	_fade_shade(1.0, 0.5)
	await _until(113.4)
	_end_card()
	await _until(DURATION)
	get_tree().quit()


func _until(time: float) -> void:
	while _clock < time:
		await get_tree().process_frame
	print("ANIME %.1f s" % time)


# --- Sets and actors ------------------------------------------------------------

func _load_arena(index: int) -> void:
	for bubble in _bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_bubbles.clear()
	_held.clear()
	_movers.clear()
	_cast.clear()
	for child in _set.get_children():
		child.queue_free()
	var arena: Node3D = load("res://scenes/arenas/%s.tscn" % ARENAS[index]).instantiate()
	_set.add_child(arena)
	_toon(arena)


## A hero of Loadout.CHARACTERS by id, standing at `at`, gun in hand.
func _hero(id: String, at: Vector3, facing: float) -> CharacterModel:
	var item: Dictionary = Loadout.find(id).item
	var hero := _actor(load(Loadout.CHARACTER_DIR + str(item.model)), HERO_HEIGHT, at, facing)
	var gun: String = {"soldier": "heavy", "kunoichi": "laser", "captain": "plasma", "ronin": "railgun"}.get(id, "blaster")
	var weapon := Loadout.instantiate_weapon(Loadout.find(gun).item, Loadout.SKINS[0])
	var holder := Node3D.new()
	hero.get_parent().add_child(holder)
	holder.add_child(weapon)
	_toon(weapon)
	_held.append([hero, holder])
	_cast[id] = hero
	return hero


func _actor(scene: PackedScene, height: float, at: Vector3, facing: float) -> CharacterModel:
	var pivot := Node3D.new()
	_set.add_child(pivot)
	pivot.position = at
	pivot.rotation.y = facing
	var model: Node3D = scene.instantiate()
	model.set_script(CharacterModel)
	var character := model as CharacterModel
	character.target_height = height
	pivot.add_child(character)
	character.play(&"idle")
	_toon(character)
	return character


## A guard-like enemy of the game, standing still where it is put: only the
## way it dies is borrowed.
func _enemy(at: Vector3, facing: float, action: StringName) -> Enemy:
	var pivot := Node3D.new()
	_set.add_child(pivot)
	pivot.position = at
	pivot.rotation.y = facing
	var enemy: Enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.model_scene = _arena_enemy_model()
	enemy.weapon_id = ""
	enemy.drop_chance = 0.0
	enemy.show_hit_info = false
	pivot.add_child(enemy)
	enemy.set_physics_process(false)
	enemy._model.play(action)
	_toon(enemy)
	return enemy


func _arena_enemy_model() -> PackedScene:
	for child in _set.get_children():
		if child is Arena and not child.is_queued_for_deletion():
			return (child as Arena).enemy_model
	return load("res://assets/models/quaternius/characters/BlueSoldier_Male.fbx")


func _spawn_boss(kind: Boss.Kind, at: Vector3, height: float) -> CharacterModel:
	var info: Dictionary = Boss.INFO[kind]
	var boss := _actor(load(Boss.MODEL_DIR + str(info.model)), height, at, 0.0)
	return boss


func _spawn_titan(at: Vector3) -> CharacterModel:
	var titan := _spawn_boss(Boss.Kind.TITAN, at, TITAN_HEIGHT)
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(Boss.TITAN_TEXTURE)
	for mesh: MeshInstance3D in titan.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = _toon_material(material)
		mesh.material_override.next_pass = _outline
	return titan


## Turns `model` toward `target` (a node), on the ground.
func _face(model: Node3D, target: Node3D) -> void:
	var pivot := model.get_parent() as Node3D
	var at := target.global_position
	if Vector2(at.x - pivot.global_position.x, at.z - pivot.global_position.z).length() > 0.01:
		pivot.look_at(Vector3(at.x, pivot.global_position.y, at.z))


## Makes `pivot` walk on its own at `velocity` meters per second.
func _move(pivot: Node3D, velocity: Vector3) -> void:
	_movers.append([pivot, velocity])


## Drops `pivot` from where it is to the height `ground`.
func _drop(pivot: Node3D, ground: float, seconds: float) -> void:
	create_tween().tween_property(pivot, "position:y", ground, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


## Topples a big model backward and sinks it, in a cloud of dust.
func _fall(model: CharacterModel, seconds: float) -> void:
	var pivot := model.get_parent() as Node3D
	model.play(&"die", true)
	var tween := create_tween()
	tween.tween_property(pivot, "rotation:x", -PI / 2.2, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		_shake = 0.35
		_ring(pivot.position, Color(0.85, 0.75, 0.6), 14.0, 0.8)
		Effects.burst(_set, pivot.position + Vector3.UP, Color(0.85, 0.75, 0.6), 80))
	tween.tween_property(pivot, "position:y", pivot.position.y - 3.0, 1.5).set_delay(0.6)


## A heavy step: a ring along the ground and a jolt.
func _stomp(at: Vector3, strength: float) -> void:
	_ring(at, Color(1.0, 0.9, 0.7), 12.0 * strength, 0.7)
	Effects.burst(_set, at + Vector3.UP * 0.3, Color(0.85, 0.75, 0.6), int(50 * strength))
	_shake = 0.2 * strength


## Gives the model a see-through glow of `color` (the clones).
func _tint(model: CharacterModel, color: Color) -> void:
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = Color(color, 0.55)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = glow


# --- Action -------------------------------------------------------------------

## `hero` fires at `enemy`, which falls the way a skin kills.
func _shoot(hero: CharacterModel, enemy: Enemy, style: StringName, color: Color) -> void:
	hero.play(&"shoot", true)
	var from := hero.global_position + Vector3(0, 1.3, 0) - (hero.get_parent() as Node3D).global_basis.z * 0.4
	_beam(from, enemy.global_position + Vector3.UP * 1.1, color, 0.06)
	_kill(enemy, style, color)


## A blade's arc through `enemy`.
func _slash(enemy: Enemy, style: StringName, color: Color) -> void:
	var at := enemy.global_position + Vector3.UP * 1.0
	_beam(at + Vector3(-0.9, 0.7, 0), at + Vector3(0.9, -0.5, 0), Color.WHITE, 0.05)
	_kill(enemy, style, color)


func _kill(enemy: Enemy, style: StringName, color: Color) -> void:
	if is_instance_valid(enemy):
		enemy.set_kill_effect(style, color)
		enemy.take_damage(9999)


## A glowing line that fades out fast.
func _beam(from: Vector3, to: Vector3, color: Color, thickness: float) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color.lerp(Color.WHITE, 0.4)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 3.0
	var box := BoxMesh.new()
	box.size = Vector3(thickness, thickness, from.distance_to(to))
	box.material = material
	var beam := MeshInstance3D.new()
	beam.mesh = box
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_set.add_child(beam)
	var up := Vector3.RIGHT if absf(from.direction_to(to).y) > 0.99 else Vector3.UP
	beam.look_at_from_position((from + to) * 0.5, to, up)
	var tween := beam.create_tween()
	tween.tween_property(beam, "scale", Vector3(0.1, 0.1, 1.0), 0.25)
	tween.tween_callback(beam.queue_free)
	Effects.flash(_set, from, color, 4.0, 0.15)


## A rocket of the Captain's broadside: a short smoky arc, then a blast.
func _rocket(from: Vector3, to: Vector3) -> void:
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.6, 0.2)
	sphere.material = material
	ball.mesh = sphere
	_set.add_child(ball)
	ball.position = from
	var tween := ball.create_tween()
	var middle := (from + to) * 0.5 + Vector3.UP * 3.0
	tween.tween_method(func(t: float) -> void:
		ball.position = from.lerp(middle, t).lerp(middle.lerp(to, t), t)
		if randf() < 0.5:
			Effects.burst(_set, ball.position, Color(0.8, 0.8, 0.8), 2), 0.0, 1.0, 0.7)
	tween.tween_callback(func() -> void:
		Effects.burst(_set, to, Color(1.0, 0.55, 0.15), 60)
		Effects.flash(_set, to, Color(1.0, 0.6, 0.2), 10.0, 0.4)
		_shake = maxf(_shake, 0.15)
		ball.queue_free())


## A ring that sweeps out along the ground from `at`, to `size` meters across.
func _ring(at: Vector3, color: Color, size: float, seconds: float) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color, 0.8)
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.42
	mesh.outer_radius = 0.5
	mesh.material = material
	var ring := MeshInstance3D.new()
	ring.mesh = mesh
	ring.position = at + Vector3.UP * 0.15
	ring.scale = Vector3(0.2, 0.3, 0.2)
	_set.add_child(ring)
	var tween := ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(size, 0.3, size), seconds).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, seconds)
	tween.tween_callback(ring.queue_free)


var _ember_particles: CPUParticles3D


## Embers drifting up in front of the lens (the volcano).
func _embers(on: bool) -> void:
	if _ember_particles == null:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(1.0, 0.55, 0.15)
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		var quad := QuadMesh.new()
		quad.size = Vector2.ONE * 0.03
		quad.material = material
		_ember_particles = CPUParticles3D.new()
		_ember_particles.mesh = quad
		_ember_particles.amount = 80
		_ember_particles.lifetime = 3.0
		_ember_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		_ember_particles.emission_box_extents = Vector3(2.5, 1.2, 0.8)
		_ember_particles.position = Vector3(0, 0, -2.5)
		_ember_particles.direction = Vector3.UP
		_ember_particles.gravity = Vector3.ZERO
		_ember_particles.initial_velocity_min = 0.2
		_ember_particles.initial_velocity_max = 0.6
		_camera.add_child(_ember_particles)
	_ember_particles.emitting = on


# --- Cel shading ----------------------------------------------------------------

## Swaps every plain material under `root` for its cel-shaded version with an
## ink outline. Effects (unshaded or see-through) keep theirs.
func _toon(root: Node) -> void:
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null:
			continue
		if mesh.material_override:
			var swapped := _toon_material(mesh.material_override)
			if swapped:
				mesh.material_override = swapped
			continue
		for surface in mesh.mesh.get_surface_count():
			var original := mesh.get_surface_override_material(surface)
			if original == null:
				original = mesh.mesh.surface_get_material(surface)
			var swapped := _toon_material(original)
			if swapped:
				mesh.set_surface_override_material(surface, swapped)


func _toon_material(original: Material) -> ShaderMaterial:
	if original == null or not original is StandardMaterial3D:
		return null
	if _toon_materials.has(original):
		return _toon_materials[original]
	var standard := original as StandardMaterial3D
	if standard.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED \
			or standard.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return null
	var toon := ShaderMaterial.new()
	toon.shader = _toon_shader
	toon.set_shader_parameter("albedo", standard.albedo_color)
	if standard.albedo_texture:
		toon.set_shader_parameter("albedo_texture", standard.albedo_texture)
		toon.set_shader_parameter("use_texture", true)
		toon.set_shader_parameter("triplanar", standard.uv1_triplanar)
		toon.set_shader_parameter("uv_scale", standard.uv1_scale.x)
	if standard.emission_enabled:
		toon.set_shader_parameter("emission", standard.emission * standard.emission_energy_multiplier)
	toon.next_pass = _outline
	_toon_materials[original] = toon
	return toon


# --- Camera ---------------------------------------------------------------------

## Travels in a straight line while its aim moves from `look_from` to `look_to`.
## `guarded`: steps in front of any wall that would hide the subject.
func _dolly(from: Vector3, to: Vector3, look_from: Vector3, look_to: Vector3, seconds: float,
		guarded := false) -> void:
	_from = from
	_to = to
	_look_from = look_from
	_look_to = look_to
	_shot_start = _clock
	_shot_length = seconds
	_guarded = guarded
	_place_camera()


func _place_camera() -> void:
	var progress := clampf((_clock - _shot_start) / _shot_length, 0.0, 1.0)
	progress = smoothstep(0.0, 1.0, progress)
	var at := _from.lerp(_to, progress)
	var look := _look_from.lerp(_look_to, progress)
	if _guarded:
		var query := PhysicsRayQueryParameters3D.create(look, at, WORLD_LAYER)
		var hit := _camera.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			at = look + look.direction_to(at) * maxf(look.distance_to(hit.position) - 0.6, 1.5)
	at += Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * _shake
	_camera.look_at_from_position(at, look)


func _process(delta: float) -> void:
	_clock += delta
	_shake = move_toward(_shake, 0.0, (_shake * 3.0 + 0.05) * delta)
	for entry: Array in _movers:
		var pivot := entry[0] as Node3D
		if is_instance_valid(pivot):
			pivot.position += (entry[1] as Vector3) * delta
	for entry: Array in _held:
		var character := entry[0] as CharacterModel
		if is_instance_valid(character):
			character.place_in_hand(entry[1] as Node3D, "R", false)
	_place_camera()
	var screen := get_viewport().get_visible_rect().size
	for bubble in _bubbles:
		if is_instance_valid(bubble):
			bubble.follow(_camera, screen)
	_speed_left = maxf(_speed_left - delta, 0.0)
	_speed_lines.visible = _speed_left > 0.0
	if _speed_lines.visible:
		_speed_lines.queue_redraw()
	_impact_left -= delta
	_impact.visible = _impact_left > 0.0


# --- Overlay --------------------------------------------------------------------

func _build_overlay() -> void:
	_layer.layer = 100
	add_child(_layer)
	_impact.anchor_right = 1.0
	_impact.anchor_bottom = 1.0
	_impact.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var impact_shader := Shader.new()
	impact_shader.code = IMPACT_SHADER
	var impact_material := ShaderMaterial.new()
	impact_material.shader = impact_shader
	_impact.material = impact_material
	_impact.visible = false
	_layer.add_child(_impact)
	_speed_lines.anchor_right = 1.0
	_speed_lines.anchor_bottom = 1.0
	_speed_lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speed_lines.draw.connect(_draw_speed_lines)
	_speed_lines.visible = false
	_layer.add_child(_speed_lines)
	for top: bool in [true, false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.anchor_right = 1.0
		bar.anchor_top = 0.0 if top else 1.0 - BAR_HEIGHT
		bar.anchor_bottom = BAR_HEIGHT if top else 1.0
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(bar)
	# Narration: a pale box at the top left, as in a manga panel.
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.82)
	style.border_color = Color.BLACK
	style.set_border_width_all(4)
	style.set_content_margin_all(18)
	_narration_box.add_theme_stylebox_override("panel", style)
	_narration_box.position = Vector2(60, 110)
	_narration_box.modulate.a = 0.0
	_narration.add_theme_font_override("font", FONT)
	_narration.add_theme_font_size_override("font_size", 28)
	_narration.add_theme_color_override("font_color", Color.BLACK)
	_narration_box.add_child(_narration)
	_layer.add_child(_narration_box)
	_card.anchor_right = 1.0
	_card.anchor_bottom = 1.0
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_card)
	_shade.color = Color.BLACK
	_shade.anchor_right = 1.0
	_shade.anchor_bottom = 1.0
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_shade)


## Lines rushing in from the edges of the frame toward its middle.
func _draw_speed_lines() -> void:
	var screen := _speed_lines.size
	var middle := screen / 2.0
	var reach := screen.length() / 2.0
	for i in 70:
		var angle := randf() * TAU
		var direction := Vector2(cos(angle), sin(angle))
		var inner := reach * randf_range(0.45, 0.7)
		var width := randf_range(1.5, 5.0)
		var color := Color(1, 1, 1, randf_range(0.35, 0.8)) if i % 3 else Color(0, 0, 0, 0.5)
		_speed_lines.draw_line(middle + direction * inner, middle + direction * reach * 1.1, color, width)


func _speed(seconds: float) -> void:
	_speed_left = maxf(_speed_left, seconds)


## Three frames of ink-negative picture, on a big hit.
func _impact_frame() -> void:
	_impact_left = 0.1
	_impact.visible = true


func _say(speaker: CharacterModel, text: String, seconds: float, side: float) -> void:
	var bubble := Bubble.new(text, FONT)
	bubble.speaker = speaker
	bubble.head = HERO_HEIGHT + 0.15
	bubble.side = side
	_layer.add_child(bubble)
	_layer.move_child(bubble, _card.get_index())
	_bubbles.append(bubble)
	bubble.follow(_camera, get_viewport().get_visible_rect().size)
	bubble.scale = Vector2.ONE * 0.4
	var tween := bubble.create_tween()
	tween.tween_property(bubble, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(maxf(seconds - 0.45, 0.1))
	tween.tween_property(bubble, "modulate:a", 0.0, 0.2)
	tween.tween_callback(bubble.queue_free)


func _narrate(text: String, seconds: float, big := false) -> void:
	_narration.text = text
	_narration.add_theme_font_size_override("font_size", 56 if big else 28)
	_narration_box.reset_size()
	_layer.move_child(_narration_box, -1)
	var screen := get_viewport().get_visible_rect().size
	_narration_box.position = (screen - _narration_box.get_combined_minimum_size()) / 2.0 if big else Vector2(60, 110)
	var tween := create_tween()
	tween.tween_property(_narration_box, "modulate:a", 1.0, 0.25)
	tween.tween_interval(seconds - 0.5)
	tween.tween_property(_narration_box, "modulate:a", 0.0, 0.25)


func _fade_shade(alpha: float, seconds: float) -> void:
	create_tween().tween_property(_shade, "color:a", alpha, seconds)


## A manga-style change of scene: a black slash crosses the frame.
func _wipe() -> void:
	var slash := Polygon2D.new()
	var screen := get_viewport().get_visible_rect().size
	slash.polygon = PackedVector2Array([Vector2(-200, 0), Vector2(screen.x * 0.6, 0),
			Vector2(screen.x * 0.4, screen.y), Vector2(-400, screen.y)])
	slash.color = Color(0.02, 0.01, 0.05)
	slash.position.x = -screen.x
	_card.add_child(slash)
	var tween := create_tween()
	tween.tween_property(slash, "position:x", screen.x * 1.4, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(slash.queue_free)


## Black frame, a magenta slash, the logo and the episode's name.
func _title_card(seconds: float) -> void:
	var screen := get_viewport().get_visible_rect().size
	var back := ColorRect.new()
	back.color = Color(0.02, 0.01, 0.05)
	back.size = screen
	_card.add_child(back)
	var slash := Polygon2D.new()
	slash.polygon = PackedVector2Array([Vector2(0, screen.y * 0.58), Vector2(screen.x, screen.y * 0.42),
			Vector2(screen.x, screen.y * 0.5), Vector2(0, screen.y * 0.66)])
	slash.color = MAGENTA
	slash.scale.x = 0.0
	_card.add_child(slash)
	var logo := Logo.new()
	logo.size = Vector2(760, 160)
	logo.position = Vector2((screen.x - 760) / 2.0, screen.y * 0.22)
	logo.modulate.a = 0.0
	_card.add_child(logo)
	var episode := Label.new()
	episode.text = "ÉPISODE 1\nL'ESCOUADE"
	episode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	episode.add_theme_font_override("font", FONT)
	episode.add_theme_font_size_override("font_size", 54)
	episode.add_theme_color_override("font_color", Color.WHITE)
	episode.add_theme_color_override("font_outline_color", Color.BLACK)
	episode.add_theme_constant_override("outline_size", 14)
	episode.size = Vector2(screen.x, 160)
	episode.position = Vector2(0, screen.y * 0.6)
	episode.modulate.a = 0.0
	_card.add_child(episode)
	var tween := create_tween()
	tween.tween_property(slash, "scale:x", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo, "modulate:a", 1.0, 0.2)
	tween.tween_callback(_impact_frame)
	tween.tween_callback(func() -> void: _speed(0.8))
	tween.tween_property(episode, "modulate:a", 1.0, 0.4).set_delay(0.3)
	await _until(_clock + seconds)
	for node in [back, slash, logo, episode]:
		node.queue_free()


## The last card: the logo, the address, an invitation.
func _end_card() -> void:
	var screen := get_viewport().get_visible_rect().size
	var logo := Logo.new()
	logo.size = Vector2(760, 160)
	logo.position = Vector2((screen.x - 760) / 2.0, screen.y * 0.25)
	logo.modulate.a = 0.0
	_card.add_child(logo)
	_layer.move_child(_card, -1)
	var text := Label.new()
	text.text = "JOUE À OVERCLOCK\n%s\nSUR ANDROID ET DANS LE NAVIGATEUR" % URL
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_override("font", FONT)
	text.add_theme_font_size_override("font_size", 34)
	text.add_theme_color_override("font_color", CYAN)
	text.size = Vector2(screen.x, 200)
	text.position = Vector2(0, screen.y * 0.55)
	text.modulate.a = 0.0
	_card.add_child(text)
	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(text, "modulate:a", 1.0, 0.8).set_delay(0.4)
