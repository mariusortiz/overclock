class_name AnimeDirector
extends Node
## The toolkit of the "Overclock" anime: two-minute anime-style episodes
## played by the engine with the game's models, with cel shading (flat light
## bands and black outlines), manga speech bubbles, speed lines and impact
## frames. Each episode is a script of scripts/anime/ that extends this one
## and writes its story in _story(), with a scene in scenes/tools/anime/.
##
## Rendered by .github/workflows/anime.yml with Godot's movie mode:
##   godot --write-movie ep.avi --fixed-fps 30 res://scenes/tools/anime/ep02.tscn

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
const RED := Color(1.0, 0.2, 0.15)
## Each hero's gun in the story (Loadout ids).
const GUNS := {
	"soldier": "heavy", "kunoichi": "laser", "captain": "plasma", "ronin": "railgun",
	"sand_ghost": "flechette", "viking": "shotgun_1", "witch": "smg_2", "cowboy": "revolver_1",
	"cowgirl": "revolver_3", "paladin": "minigun", "godfather": "pistol_6", "golden_knight": "rifle_6",
	"knight": "heavy", "elf": "sniper", "wizard": "smg", "pirate": "bazooka", "soldier_female": "rifle_2",
	"kimono": "railgun", "ninja": "smg_4",
}

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


## Set by each episode (see scripts/anime/).
var episode_number := 1
var episode_title := ""
## Seconds: the film ends there.
var duration := 120.0

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
## Space episodes: the circuit, and the ships flying it: [ship, target offset].
var _track: RaceTrack
var _flyers: Array[Array] = []
## The camera can ride along with a node (a ship): offsets in its frame.
var _follow_node: Node3D
var _follow_offset := Vector3.ZERO
var _follow_look := Vector3.ZERO

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
	await _story()
	await _until(duration)
	get_tree().quit()


## The episode itself: each episode script overrides it.
func _story() -> void:
	pass


func _until(time: float) -> void:
	while _clock < time:
		await get_tree().process_frame
	print("ANIME %.1f s" % time)


# --- Sets and actors ------------------------------------------------------------

func _clear_set() -> void:
	for bubble in _bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_bubbles.clear()
	_held.clear()
	_movers.clear()
	_cast.clear()
	_flyers.clear()
	_track = null
	_follow_node = null
	for child in _set.get_children():
		child.queue_free()


func _load_arena(index: int) -> void:
	for bubble in _bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_bubbles.clear()
	_clear_set()
	var arena: Node3D = load("res://scenes/arenas/%s.tscn" % ARENAS[index]).instantiate()
	_set.add_child(arena)
	_toon(arena)


## A hero of Loadout.CHARACTERS by id, standing at `at`, gun in hand.
func _hero(id: String, at: Vector3, facing: float, gun := "") -> CharacterModel:
	var item: Dictionary = Loadout.find(id).item
	var hero := _actor(load(Loadout.CHARACTER_DIR + str(item.model)), HERO_HEIGHT, at, facing)
	if gun == "":
		gun = GUNS.get(id, "heavy")
	if gun == "none":
		_cast[id] = hero
		return hero
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


## `grow` scales the whole model on top of `height` (some monster models
## stay small whatever their target height).
func _spawn_boss(kind: Boss.Kind, at: Vector3, height: float, grow := 1.0) -> CharacterModel:
	var info: Dictionary = Boss.INFO[kind]
	var boss := _actor(load(Boss.MODEL_DIR + str(info.model)), height, at, 0.0)
	(boss.get_parent() as Node3D).scale = Vector3.ONE * grow
	return boss


## Moves `node` from `from` to `to` in `seconds`, nose first (ships off the
## circuit: arriving, circling...).
func _fly_to(node: Node3D, from: Vector3, to: Vector3, seconds: float) -> void:
	node.global_position = from
	if not from.is_equal_approx(to):
		node.look_at(to)
	create_tween().tween_property(node, "global_position", to, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## A loose ship, not on a circuit, at `at`.
func _parked_ship(color: Color, at: Vector3, facing: float) -> RaceShip:
	var ship := RaceShip.new()
	ship.color = color
	_set.add_child(ship)
	ship.global_position = at
	ship.rotation.y = facing
	_toon(ship)
	return ship


## Rockets falling from the sky onto `at`, one after the other.
func _airstrike(at: Vector3, count: int, spread: float) -> void:
	for i in count:
		var target := at + Vector3(randf_range(-spread, spread), 0, randf_range(-spread, spread))
		get_tree().create_timer(0.18 * i).timeout.connect(_rocket.bind(target + Vector3(randf_range(-8, 8), 30, 10), target))


## Raises `model` (its pivot) from `depth` meters under where it stands.
func _rise(model: Node3D, depth: float, seconds: float) -> void:
	var pivot := model.get_parent() as Node3D
	var ground := pivot.position.y
	pivot.position.y = ground - depth
	create_tween().tween_property(pivot, "position:y", ground, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Slides a zone's control to `control` over `seconds` (its colors follow).
func _turn_zone(zone: CaptureZone, control: float, seconds: float) -> void:
	create_tween().tween_method(func(value: float) -> void:
		zone.control = value
		zone.update(0.0, 0, 0), zone.control, control, seconds)


func _spawn_titan(at: Vector3, height := TITAN_HEIGHT, tint := Color.WHITE) -> CharacterModel:
	var titan := _spawn_boss(Boss.Kind.TITAN, at, height)
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(Boss.TITAN_TEXTURE)
	for mesh: MeshInstance3D in titan.find_children("*", "MeshInstance3D", true, false):
		var toon := _toon_material(material)
		toon.set_shader_parameter("albedo", tint)
		mesh.material_override = toon
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


# --- Other sets ---------------------------------------------------------------

## Space: the race circuit of the game (seeded), stars and a planet.
func _load_space(seed_value: int) -> RaceTrack:
	_clear_set()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.01, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.6, 0.8)
	environment.ambient_light_energy = 0.9
	environment.glow_enabled = true
	var world := WorldEnvironment.new()
	world.environment = environment
	_set.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 40, 0)
	_set.add_child(sun)
	_track = RaceTrack.new()
	_track.build(seed_value)
	_set.add_child(_track)
	_camera.far = 2500.0
	return _track


## A ship on the current circuit, at `distance` along it and `offset` across.
func _ship(display_name: String, color: Color, distance: float, offset: Vector2, pace := 1.0) -> RaceShip:
	var ship := RaceShip.new()
	ship.display_name = display_name
	ship.color = color
	ship.skill = pace
	ship.distance = distance
	ship.offset = offset
	_set.add_child(ship)
	ship.speed = RaceShip.BASE_SPEED * pace
	ship.fly(0.0, Vector2.ZERO, _track)
	_toon(ship)
	_flyers.append([ship, offset])
	return ship


## Where a ship steers to, across the track.
func _steer(ship: RaceShip, offset: Vector2) -> void:
	for entry: Array in _flyers:
		if entry[0] == ship:
			entry[1] = offset


## A laser from one ship to another, which is hit.
func _ship_laser(from: RaceShip, to: RaceShip) -> void:
	_beam(from.global_position - from.global_basis.z * 2.0, to.global_position, from.color, 0.15)
	to.hit()


## A dark hall with neon lines, for line-ups and meetings.
func _load_showroom() -> void:
	_clear_set()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.03, 0.09)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.65, 0.85)
	environment.ambient_light_energy = 0.9
	environment.glow_enabled = true
	var world := WorldEnvironment.new()
	world.environment = environment
	_set.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 20, 0)
	_set.add_child(sun)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.06, 0.07, 0.16)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(200, 60)
	floor_mesh.material = floor_material
	var ground := MeshInstance3D.new()
	ground.mesh = floor_mesh
	_set.add_child(ground)
	for line: Array in [[CYAN, -3.0], [MAGENTA, -5.5]]:
		var material := StandardMaterial3D.new()
		material.albedo_color = line[0]
		material.emission_enabled = true
		material.emission = line[0]
		material.emission_energy_multiplier = 2.5
		var mesh := BoxMesh.new()
		mesh.size = Vector3(200, 0.05, 0.12)
		mesh.material = material
		var strip := MeshInstance3D.new()
		strip.mesh = mesh
		strip.position = Vector3(0, 0.03, line[1])
		_set.add_child(strip)
	_toon(_set)


## A capture zone of the game, held by `control` (-1 foes, 0 nobody, 1 us).
func _zone(letter: String, at: Vector3, control: float) -> CaptureZone:
	var zone := CaptureZone.new()
	zone.letter = letter
	_set.add_child(zone)
	zone.global_position = at
	zone.control = control
	zone.update(0.0, 0, 0)
	return zone


## A character of the pack that is not a hero of the game (Suit_Male...).
func _npc(model_file: String, at: Vector3, facing: float) -> CharacterModel:
	return _actor(load(Loadout.CHARACTER_DIR + model_file), HERO_HEIGHT, at, facing)


## "À SUIVRE..." over the last shot, then the end card.
func _to_be_continued(at: float) -> void:
	await _until(at)
	_shade.color = Color(0, 0, 0, 0)
	_fade_shade(0.85, 0.4)
	_narrate("À SUIVRE...", 3.0, true)
	await _until(at + 3.4)
	_fade_shade(1.0, 0.5)
	await _until(at + 4.0)
	_end_card()


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
	_follow_node = null
	_place_camera()


## Rides along with `node`: the camera at `offset` in its frame, looking at
## `look` (also in its frame).
func _follow(node: Node3D, offset: Vector3, look: Vector3) -> void:
	_follow_node = node
	_follow_offset = offset
	_follow_look = look
	_place_camera()


func _place_camera() -> void:
	if is_instance_valid(_follow_node):
		var frame := _follow_node.global_transform
		var ride := frame * _follow_offset + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_camera.look_at_from_position(ride, frame * _follow_look, frame.basis.y)
		return
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
	for entry: Array in _flyers:
		var ship := entry[0] as RaceShip
		if is_instance_valid(ship) and _track:
			ship.fly(delta, ((entry[1] as Vector2) - ship.offset).limit_length(1.0), _track)
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


## A speech bubble by `speaker` (a character, or a ship: `head` is how high
## above its origin the bubble points).
func _say(speaker: Node3D, text: String, seconds: float, side: float, head := HERO_HEIGHT + 0.15) -> void:
	var bubble := Bubble.new(text, FONT)
	bubble.speaker = speaker
	bubble.head = head
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
	episode.text = "ÉPISODE %d\n%s" % [episode_number, episode_title]
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
func _end_card(final := false) -> void:
	var screen := get_viewport().get_visible_rect().size
	var logo := Logo.new()
	logo.size = Vector2(760, 160)
	logo.position = Vector2((screen.x - 760) / 2.0, screen.y * 0.25)
	logo.modulate.a = 0.0
	_card.add_child(logo)
	_layer.move_child(_card, -1)
	var text := Label.new()
	text.text = "%sJOUE À OVERCLOCK\n%s\nSUR ANDROID ET DANS LE NAVIGATEUR" % ["FIN DE LA SAISON 1\n\n" if final else "", URL]
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
