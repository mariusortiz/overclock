extends Node
## Directs the two-minute trailer: a showcase, with no fighting. It visits the
## arenas, parades their enemies and bosses, then scrolls past every weapon and
## every hero, with title cards on top. Nothing of the game itself runs here:
## the director only borrows its scenes and models.
##
## Rendered by .github/workflows/trailer.yml with Godot's movie mode:
##   godot --write-movie trailer.avi --fixed-fps 30 res://scenes/tools/trailer.tscn
## The music is laid over the picture afterwards, by the same workflow.

const URL := "mariusortiz.github.io/overclock-builds"
const DURATION := 130.0
const TEXT_COLOR := Color(0.16, 0.9, 1.0)
const ACCENT := Color(1.0, 0.24, 0.95)
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const WORLD_LAYER := 1
## Share of the picture's height taken by each black bar.
const BAR_HEIGHT := 0.085

## The arenas in the order of the game, with the name of their enemies and the
## boss met there.
const ARENAS := [
	{"scene": "station", "enemies": "GARDES", "boss": Boss.Kind.COLOSSUS},
	{"scene": "desert", "enemies": "ASSASSINS DES SABLES", "boss": Boss.Kind.BRUTE},
	{"scene": "jungle", "enemies": "GOBELINS", "boss": Boss.Kind.ARTILLERY},
	{"scene": "volcano", "enemies": "ZOMBIES", "boss": Boss.Kind.SUMMONER},
	{"scene": "city", "enemies": "HOMMES EN COSTUME", "boss": Boss.Kind.TITAN},
]
const CITY := 4
## Bosses are shown twice the size of their model, as in the game.
const BOSS_SCALE := 2.0
## Where the parades take place: the clear ground around the player's spawn.
const PARADE := Vector3(0, 0.1, 15)
const BOSS_SPOT := Vector3(0, 0.1, 13)
## Enemies of a parade, relative to its leader (they walk toward +Z).
const FORMATION: Array[Vector3] = [
	Vector3(0, 0, 0), Vector3(-1.7, 0, -1.3), Vector3(1.7, 0, -1.3), Vector3(-3.4, 0, -2.6), Vector3(3.4, 0, -2.6),
]
const WALK_SPEED := 1.0

const GUN_SPACING := 2.3
const GUN_LENGTH := 1.3
const GUN_HEIGHT := 1.3
const HERO_SPACING := 2.1
const BLADE_SPACING := 2.3
const BLADE_HEIGHT := 1.35
## Size of the logo on the title cards, in the units of the 1280 x 720 screen.
const LOGO_SIZE := Vector2(860, 180)
## A narrow band of light, slanted, that moves along X: it makes each item it
## crosses gleam. Added on top of the item's own material.
const GLINT_SHADER := """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform float sweep_x = 0.0;
varying vec3 world_position;
void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	float band = 1.0 - smoothstep(0.0, 0.14, abs(world_position.x + world_position.y * 0.5 - sweep_x));
	ALBEDO = vec3(1.0, 0.97, 0.9) * band * 0.9;
	ALPHA = band;
}
"""
## The glint crosses this many meters of the hall, around the camera, per pass.
const GLINT_SPAN := 7.0
const GLINT_SPEED := 4.5
const EMBER_COLOR := Color(1.0, 0.55, 0.15)
const COUNT_TIME := 0.8
## The gun each hero holds in the line-up, in the order of Loadout.CHARACTERS.
const HERO_GUNS: Array[String] = [
	"heavy", "revolver_3", "smg", "pistol_4", "shotgun_5", "rifle_6", "sniper_2",
	"shotgun_2", "sniper_5", "revolver_1", "smg_3", "bullpup_1", "bazooka",
]

enum Shot { ORBIT, DOLLY }

var _clock := 0.0
## Everything on screen for the current chapter: freed when the next one starts.
var _set := Node3D.new()
var _camera := Camera3D.new()
var _shot := Shot.ORBIT
var _center := Vector3.ZERO
var _radius := 10.0
var _height := 4.0
var _angle := 0.0
var _speed := 0.0
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _look_from := Vector3.ZERO
var _look_to := Vector3.ZERO
var _shot_start := 0.0
var _shot_length := 1.0
var _guarded := false

## [character, holder, along_arm]: items kept in a hand, frame after frame.
var _held: Array[Array] = []
## Models on stage (their pivots), those of them that walk, and the guns on show.
var _actors: Array[Node3D] = []
var _walkers: Array[Node3D] = []
var _floaters: Array[Node3D] = []
## Blades on show: they turn on themselves.
var _spinners: Array[Node3D] = []
var _inspection := Inspection.new()
var _fov_tween: Tween
## Camera shake, in meters of offset; it settles by itself.
var _shake := 0.0
## Light rays behind the trophy, turned to face the camera every frame.
var _rays: Node3D
var _end_sparks := CPUParticles2D.new()
## Sparks drawn in to the middle of the screen, where the logo then appears.
var _logo_sparks := CPUParticles2D.new()
## Embers drifting in front of the lens during the boss shots.
var _embers := CPUParticles3D.new()
## Mirror world under the hall's floor: a copy of each item on show, flipped.
var _mirror: Node3D
## Item on show -> its reflection, which copies its movement every frame.
var _twins := {}
## Light band sweeping over the items on show (see GLINT_SHADER).
var _glint := ShaderMaterial.new()
var _wipe := Control.new()
var _cta := Label.new()
var _cta_tween: Tween
var _flock: Node3D

var _shade := ColorRect.new()
var _logo := Logo.new()
var _blink_rect := ColorRect.new()
var _subtitle := Label.new()
var _kicker := Label.new()
var _caption := Label.new()
var _caption_tween: Tween


func _ready() -> void:
	Music.stop()
	add_child(_set)
	add_child(_camera)
	_camera.fov = 60.0
	_camera.far = 400.0
	_camera.make_current()
	_camera.add_child(_inspection)
	var glint_shader := Shader.new()
	glint_shader.code = GLINT_SHADER
	_glint.shader = glint_shader
	_build_embers()
	_build_overlay()
	_run.call_deferred()


# --- Timeline ---------------------------------------------------------------
# The music starts quiet and kicks in 16 s into the film: the opening and the
# quick tour of the arenas fill the quiet part.

func _run() -> void:
	_load_arena(0)
	_orbit(Vector3(0, 1, 0), 34.0, 13.0, 0.6, 0.16)
	_fade_shade(0.0, 1.5)
	await _until(1.5)
	_show_title("SHOOTER D'ARÈNE · 3D LOW-POLY", 5.0)
	await _until(7.0)

	# Five arenas at a glance.
	for index in ARENAS.size():
		_load_arena(index)
		_orbit(Vector3(0, 1, 0), 30.0, 8.0 + index, 1.1 * index, 0.3)
		_blink()
		_show_caption("ARÈNE %d / %d" % [index + 1, ARENAS.size()], _arena().display_name, 1.5)
		await _until(7.0 + 1.8 * (index + 1))

	# Each arena again, slowly, with those who live there. The city keeps its
	# boss for the end.
	var start := 16.0
	for index in ARENAS.size():
		var info: Dictionary = ARENAS[index]
		_load_arena(index)
		_flash()
		_orbit(Vector3(0, 1.5, 0), 36.0, 12.0, 2.2 + index, 0.14)
		_show_caption("ARÈNE %d / %d" % [index + 1, ARENAS.size()], _arena().display_name, 3.0)
		await _until(start + 3.5)
		_parade(_arena())
		_blink()
		_show_caption("ENNEMIS", info.enemies, 3.5)
		await _until(start + 7.7)
		if index == CITY:
			start += 8.0
			await _until(start)
			break
		_clear_actors()
		var boss_kind: Boss.Kind = info.boss
		_present_boss(boss_kind, 4.3)
		_blink()
		_show_caption("BOSS", Boss.INFO[boss_kind].name, 3.6)
		start += 12.0
		await _until(start)

	# 72 s: they fly, too.
	_load_arena(1)
	_flash()
	_release_bats()
	_dolly(Vector3(-5, 1.2, 15), Vector3(5, 2.2, 12), Vector3(0, 6, 0), Vector3(0, 6.5, 0), 5.0)
	_show_caption("DANS LES AIRS AUSSI", "CHAUVES-SOURIS", 4.0)
	await _until(77.0)

	# 77 s: the armory.
	_build_showroom()
	_flash()
	_line_up_guns()
	var last_gun := (Loadout.WEAPONS.size() - 1) * GUN_SPACING
	_dolly(Vector3(-1.5, 1.2, 3.3), Vector3(last_gun + 1.5, 1.2, 3.3),
			Vector3(-1.5, 1.05, 0), Vector3(last_gun + 1.5, 1.05, 0), 15.0)
	_show_caption("ARSENAL", "%%d ARMES · %d SKINS" % Loadout.SKINS.size(), 13.5, Loadout.WEAPONS.size())
	await _until(92.0)

	# 92 s: the blades, then the butterfly knife flipping in the hand.
	_build_showroom()
	_flash()
	_line_up_blades()
	var last_blade := (Loadout.MELEE.size() - 1) * BLADE_SPACING
	_dolly(Vector3(-1.2, 1.25, 3.4), Vector3(last_blade + 1.2, 1.25, 3.4),
			Vector3(-1.2, 1.15, 0), Vector3(last_blade + 1.2, 1.15, 0), 7.0)
	_show_caption("CORPS À CORPS", "%%d LAMES · %d SKINS" % Loadout.SKINS.size(), 6.0, Loadout.MELEE.size())
	await _until(99.0)
	_build_showroom()
	_blink()
	_dolly(Vector3(0, 1.3, 3.0), Vector3(0, 1.3, 2.6), Vector3(0, 1.3, 0), Vector3(0, 1.3, 0), 3.6)
	_inspection.start_melee(Loadout.find("butterfly").item, Loadout.find("skin_neon").item)
	_show_caption("NOUVEAU", "INSPECTE TES ARMES", 3.0)
	await _until(102.6)
	_inspection.cancel()

	# 102.6 s: the heroes.
	_build_showroom()
	_flash()
	_line_up_heroes()
	var last_hero := (Loadout.CHARACTERS.size() - 1) * HERO_SPACING
	_dolly(Vector3(-1.0, 1.5, 4.9), Vector3(last_hero + 1.0, 1.5, 4.9),
			Vector3(-1.0, 1.45, 0), Vector3(last_hero + 1.0, 1.45, 0), 12.0)
	_show_caption("CHACUN SON ULTI", "%d HÉROS", 10.5, Loadout.CHARACTERS.size())
	await _until(114.6)

	# 114.6 s: the last boss, and what beating it earns.
	_load_arena(CITY)
	_flash()
	_present_boss(Boss.Kind.TITAN, 4.6)
	_show_caption("AU BOUT DE LA VILLE", "LE TITAN", 3.8)
	await _until(119.2)
	_clear_actors()
	_blink()
	_celebrate()
	_show_caption("BATS-LE", "GAGNE LE SKIN CHAMPION", 3.8)
	await _until(123.6)

	# End card.
	_fade_shade(1.0, 0.9)
	await _until(124.7)
	_end_sparks.emitting = true
	_show_title("%s\n\n5 ARÈNES · 5 BOSS · %d ARMES · %d LAMES · %d HÉROS" % [
			URL, Loadout.WEAPONS.size(), Loadout.MELEE.size(), Loadout.CHARACTERS.size()], 5.1, true)
	await _until(DURATION)
	get_tree().quit()


func _until(time: float) -> void:
	while _clock < time:
		await get_tree().process_frame
	# Marks the log, so that an error can be placed on the timeline.
	print("TRAILER %.1f s" % time)


# --- Sets -------------------------------------------------------------------

func _clear() -> void:
	_clear_actors()
	for child in _set.get_children():
		child.queue_free()


## Frees the models on stage and keeps the set.
func _clear_actors() -> void:
	for node in _actors + _floaters + _spinners:
		if is_instance_valid(node):
			node.queue_free()
	_actors.clear()
	_twins.clear()
	_floaters.clear()
	_spinners.clear()
	_walkers.clear()
	_held.clear()
	if is_instance_valid(_flock):
		_flock.queue_free()
	_flock = null


func _load_arena(index: int) -> void:
	_clear()
	var scene: PackedScene = load("res://scenes/arenas/%s.tscn" % ARENAS[index].scene)
	var arena := scene.instantiate()
	arena.name = "Arena"
	_set.add_child(arena)


## The arena on stage (the one just loaded: the previous one is on its way out).
func _arena() -> Arena:
	for child in _set.get_children():
		if child is Arena and not child.is_queued_for_deletion():
			return child as Arena
	return null


## A dark hall with two neon lines at the back, for the line-ups.
func _build_showroom() -> void:
	_clear()
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
	sun.light_energy = 1.1
	_set.add_child(sun)

	# The floor lets the mirror world under it show through, dimmed: a reflection.
	_mirror = Node3D.new()
	_mirror.scale = Vector3(1, -1, 1)
	_set.add_child(_mirror)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.05, 0.06, 0.15, 0.82)
	floor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	floor_material.metallic = 0.5
	floor_material.roughness = 0.35
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(400, 40)
	floor_mesh.material = floor_material
	var ground := MeshInstance3D.new()
	ground.mesh = floor_mesh
	_set.add_child(ground)

	for line: Array in [[TEXT_COLOR, -2.2], [ACCENT, -4.5]]:
		var color: Color = line[0]
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 2.5
		var mesh := BoxMesh.new()
		mesh.size = Vector3(400, 0.04, 0.1)
		mesh.material = material
		var strip := MeshInstance3D.new()
		strip.mesh = mesh
		strip.position = Vector3(0, 0.02, line[1])
		_set.add_child(strip)
	_add_sparks()


## Small lights rising through the hall.
func _add_sparks() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = TEXT_COLOR
	material.emission_enabled = true
	material.emission = TEXT_COLOR
	material.emission_energy_multiplier = 3.0
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * 0.035
	mesh.material = material
	var sparks := CPUParticles3D.new()
	sparks.mesh = mesh
	sparks.amount = 500
	sparks.lifetime = 5.0
	sparks.preprocess = 5.0
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	sparks.emission_box_extents = Vector3(60, 0.1, 3.5)
	sparks.position = Vector3(45, 0, -1.5)
	sparks.direction = Vector3.UP
	sparks.spread = 12.0
	sparks.gravity = Vector3.ZERO
	sparks.initial_velocity_min = 0.3
	sparks.initial_velocity_max = 0.9
	sparks.scale_amount_min = 0.4
	_set.add_child(sparks)


# --- Actors -----------------------------------------------------------------

## Puts an animated model on stage, feet at `at`, turned by `facing` (0 looks
## toward -Z). Returns the model; its parent is the node to move around.
func _actor(scene: PackedScene, height: float, hover: float, at: Vector3, facing: float,
		action: StringName, parent: Node3D = null) -> CharacterModel:
	var pivot := Node3D.new()
	if parent == null:
		parent = _set
	parent.add_child(pivot)
	_actors.append(pivot)
	pivot.position = at
	pivot.rotation.y = facing
	var model: Node3D = scene.instantiate()
	model.set_script(CharacterModel)
	var character := model as CharacterModel
	character.target_height = height
	character.hover_height = hover
	pivot.add_child(character)
	character.play(action)
	return character


## Gives `character` something to hold in its right hand.
func _hold(character: CharacterModel, item: Node3D, along_arm: bool) -> void:
	var holder := Node3D.new()
	character.get_parent().add_child(holder)
	holder.add_child(item)
	_held.append([character, holder, along_arm])


## The arena's enemies walk toward the camera, armed as in the game.
func _parade(arena: Arena) -> void:
	var found := Loadout.find(arena.enemy_weapon)
	for offset in FORMATION:
		var enemy := _actor(arena.enemy_model, 1.75, 0.0, PARADE + offset, PI, &"walk")
		_walkers.append(enemy.get_parent() as Node3D)
		if found.is_empty():
			continue
		var item: Dictionary = found.item
		if found.kind == "Arme":
			_hold(enemy, Loadout.instantiate_weapon(item, Loadout.SKINS[0]), false)
		else:
			_hold(enemy, Loadout.instantiate_melee(item), true)
	var travel := Vector3(0, 0, WALK_SPEED * 4.2)
	_dolly(PARADE + Vector3(-2.8, 1.5, 6.5), PARADE + Vector3(2.8, 1.25, 6.0) + travel,
			PARADE + Vector3(0, 1.1, -0.6), PARADE + Vector3(0, 1.1, -0.6) + travel, 4.2, true)


## A boss alone in front of the camera, seen from below; it strikes once.
func _present_boss(kind: Boss.Kind, seconds: float) -> void:
	var info: Dictionary = Boss.INFO[kind]
	var scene: PackedScene = load(Boss.MODEL_DIR + str(info.model))
	var height: float = float(info.height) * BOSS_SCALE
	var hover: float = float(info.hover) * BOSS_SCALE
	var boss := _actor(scene, height, hover, BOSS_SPOT, PI, &"idle")
	if kind == Boss.Kind.TITAN:
		var material := StandardMaterial3D.new()
		material.albedo_texture = load(Boss.TITAN_TEXTURE)
		for mesh: MeshInstance3D in boss.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = material
	var look := BOSS_SPOT + Vector3.UP * (hover + height * 0.55)
	_dolly(BOSS_SPOT + Vector3(-height * 1.1, height * 0.25, height * 2.1),
			BOSS_SPOT + Vector3(height * 1.0, height * 0.4, height * 1.7), look, look, seconds, true)
	# The lens closes in on the boss while it is on screen.
	_fov_tween = create_tween()
	_fov_tween.tween_property(_camera, "fov", 44.0, seconds).from(64.0)
	# It lands: a shock wave runs along the ground, and the frame jolts.
	_ground_ring(BOSS_SPOT, EMBER_COLOR, height * 3.0, 0.8)
	_shake = 0.1
	_set_embers(true)
	_strike_later(boss, seconds * 0.3)
	_strike_later(boss, seconds * 0.68)


func _strike_later(boss: CharacterModel, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(boss) and not boss.is_queued_for_deletion():
		boss.play(&"shoot", true)
		# The blow lands: a light jolt, and dust flies.
		await get_tree().create_timer(0.25).timeout
		_shake = 0.12
		Effects.burst(_set, BOSS_SPOT + Vector3.UP * 0.3, Color(0.85, 0.75, 0.6), 40)


## The trophy rises with everything a victory deserves: a flash, a ring
## sweeping the ground, golden rays turning behind it, confetti, sparkles,
## and the Champion skin on a rifle and a katana floating beside it.
func _celebrate() -> void:
	var trophy := Trophy.new()
	_set.add_child(trophy)
	trophy.position = BOSS_SPOT
	var top := BOSS_SPOT + Vector3.UP * 2.6
	_dolly(BOSS_SPOT + Vector3(-1.5, 1.2, 8.5), BOSS_SPOT + Vector3(1.2, 2.2, 5.6), top, top + Vector3.DOWN * 0.3, 4.4)
	_shake = 0.18
	_blink()

	var gold := Color(1.0, 0.8, 0.25)
	_rays = Node3D.new()
	_rays.position = top
	_set.add_child(_rays)
	# Turning, and growing in; _rays itself only faces the camera.
	var fan := Node3D.new()
	fan.position = Vector3.BACK * 0.6  # behind the trophy
	_rays.add_child(fan)
	create_tween().set_loops().tween_property(fan, "rotation:z", TAU, 10.0).from(0.0)
	var ray_material := StandardMaterial3D.new()
	ray_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ray_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	ray_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ray_material.albedo_color = Color(gold, 0.22)
	for index in 10:
		var ray := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.35 + 0.25 * (index % 3), 9.0, 0.01)
		mesh.material = ray_material
		ray.mesh = mesh
		var holder := Node3D.new()
		holder.rotation.z = TAU * index / 10.0
		ray.position = Vector3.UP * 4.5
		holder.add_child(ray)
		fan.add_child(holder)
	create_tween().tween_property(fan, "scale", Vector3.ONE, 0.8).from(Vector3.ONE * 0.01) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var light := OmniLight3D.new()
	light.light_color = gold
	light.light_energy = 6.0
	light.omni_range = 12.0
	light.position = top
	_set.add_child(light)

	_ground_ring(BOSS_SPOT, gold, 9.0, 0.9)

	_add_confetti(top + Vector3.UP * 2.5)
	_add_sparkles(BOSS_SPOT)

	# The Champion skin, on a rifle and a katana.
	var skin: Dictionary = Loadout.find(Loadout.CHAMPION_SKIN_ID).item
	var rifle := Loadout.instantiate_weapon(Loadout.find("heavy").item, skin)
	rifle.scale = Vector3.ONE * 3.0
	rifle.position.z = 1.1
	var katana := Loadout.instantiate_melee(Loadout.find("katana").item, skin)
	katana.scale = Vector3.ONE * 1.8
	katana.position.y = -1.2
	for pair: Array in [[rifle, -1.9], [katana, 1.9]]:
		_shine(pair[0])
		var holder := Node3D.new()
		holder.position = BOSS_SPOT + Vector3(pair[1], 2.4, 1.6)
		holder.add_child(pair[0])
		_set.add_child(holder)
		_spinners.append(holder)


## A ring that sweeps out along the ground from `at`, to `size` meters across.
func _ground_ring(at: Vector3, color: Color, size: float, seconds: float) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.0
	torus.material = material
	var ring := MeshInstance3D.new()
	ring.mesh = torus
	ring.position = at + Vector3.UP * 0.1
	_set.add_child(ring)
	var sweep := create_tween()
	sweep.tween_property(ring, "scale", Vector3(size, 1, size), seconds).from(Vector3(0.3, 1, 0.3)).set_ease(Tween.EASE_OUT)
	sweep.parallel().tween_property(material, "albedo_color:a", 0.0, seconds)
	sweep.tween_callback(ring.queue_free)


## Glowing embers floating just in front of the lens; they travel with it.
func _build_embers() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_color = EMBER_COLOR
	var mesh := QuadMesh.new()
	mesh.size = Vector2.ONE * 0.025
	mesh.material = material
	_embers.mesh = mesh
	_embers.local_coords = true
	_embers.amount = 45
	_embers.lifetime = 3.0
	_embers.preprocess = 3.0
	_embers.position = Vector3(0, -0.2, -1.4)
	_embers.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_embers.emission_box_extents = Vector3(1.6, 0.6, 0.8)
	_embers.direction = Vector3(0.3, 1, 0)
	_embers.spread = 30.0
	_embers.gravity = Vector3(0, 0.15, 0)
	_embers.initial_velocity_min = 0.1
	_embers.initial_velocity_max = 0.35
	_embers.scale_amount_min = 0.5
	_embers.scale_amount_max = 1.6
	_camera.add_child(_embers)
	_set_embers(false)


func _set_embers(on: bool) -> void:
	_embers.visible = on
	_embers.emitting = on


## Paper squares in the game's colors, raining down for a few seconds.
func _add_confetti(at: Vector3) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.12, 0.07)
	mesh.material = material
	var colors := Gradient.new()
	colors.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	colors.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75])
	colors.colors = PackedColorArray([TEXT_COLOR, ACCENT, Color(1.0, 0.85, 0.3), Color.WHITE])
	var confetti := CPUParticles3D.new()
	confetti.mesh = mesh
	confetti.amount = 260
	confetti.lifetime = 4.0
	confetti.explosiveness = 0.6
	confetti.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	confetti.emission_sphere_radius = 0.4
	confetti.direction = Vector3.UP
	confetti.spread = 70.0
	confetti.initial_velocity_min = 4.0
	confetti.initial_velocity_max = 8.0
	confetti.gravity = Vector3(0, -3.0, 0)
	confetti.damping_min = 1.5
	confetti.damping_max = 3.0
	confetti.angle_max = 360.0
	confetti.angular_velocity_min = -400.0
	confetti.angular_velocity_max = 400.0
	confetti.particle_flag_rotate_y = true
	confetti.color_initial_ramp = colors
	confetti.position = at
	_set.add_child(confetti)
	confetti.emitting = true


## Golden sparkles rising around the trophy.
func _add_sparkles(at: Vector3) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.9, 0.5)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var mesh := QuadMesh.new()
	mesh.size = Vector2.ONE * 0.06
	mesh.material = material
	var sparkles := CPUParticles3D.new()
	sparkles.mesh = mesh
	sparkles.amount = 120
	sparkles.lifetime = 2.5
	sparkles.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	sparkles.emission_ring_axis = Vector3.UP
	sparkles.emission_ring_radius = 1.8
	sparkles.emission_ring_inner_radius = 0.6
	sparkles.emission_ring_height = 0.2
	sparkles.direction = Vector3.UP
	sparkles.spread = 10.0
	sparkles.gravity = Vector3.ZERO
	sparkles.initial_velocity_min = 0.8
	sparkles.initial_velocity_max = 1.8
	sparkles.scale_amount_min = 0.5
	sparkles.scale_amount_max = 1.5
	sparkles.position = at
	_set.add_child(sparkles)


## A ring of bats turning in the sky.
func _release_bats() -> void:
	_flock = Node3D.new()
	_set.add_child(_flock)
	for index in 12:
		var angle := TAU * index / 12.0
		var radius := 4.5 + 2.5 * (index % 3)
		var at := Vector3(cos(angle) * radius, 5.0 + 1.2 * (index % 4), sin(angle) * radius)
		# Turned along the circle they fly on.
		_actor(WaveManager.FLYING_MODEL, 1.0, 0.0, at, -angle, &"idle", _flock)


## Every gun of the game in a row, each with a finish, turning slowly.
func _line_up_guns() -> void:
	for index in Loadout.WEAPONS.size():
		var item: Dictionary = Loadout.WEAPONS[index]
		var skin: Dictionary = Loadout.SKINS[index % Loadout.SKINS.size()]
		var holder := _gun_on_show(item, skin, index, _set)
		_shine(holder)
		_floaters.append(holder)
		_twins[holder] = _gun_on_show(item, skin, index, _mirror)
		var skin_color: Color = skin.shot
		_label(str(item.name).to_upper(), Vector3(index * GUN_SPACING, 0.78, 0), Color.WHITE, 26)
		_label(str(skin.name).to_upper(), Vector3(index * GUN_SPACING, 0.62, 0), skin_color, 22)


## One gun of the line-up, side-on, under `parent`.
func _gun_on_show(item: Dictionary, skin: Dictionary, index: int, parent: Node3D) -> Node3D:
	var gun := Loadout.instantiate_weapon(item, skin)
	var length: float = item.length
	gun.scale = Vector3.ONE * (GUN_LENGTH / length)
	# The grip is at the gun's origin: slide it back to turn around its middle.
	gun.position.z = GUN_LENGTH * 0.4
	var holder := Node3D.new()
	holder.position = Vector3(index * GUN_SPACING, GUN_HEIGHT, 0)
	holder.add_child(gun)
	parent.add_child(holder)
	return holder


## One blade of the line-up, under `parent`.
func _blade_on_show(item: Dictionary, skin: Dictionary, index: int, parent: Node3D) -> Node3D:
	var bounds := Loadout.melee_bounds(item)
	var size := minf(BLADE_HEIGHT / bounds.size.y, 2.6)
	var blade := Loadout.instantiate_melee(item, skin)
	blade.scale = Vector3.ONE * size
	# Held by the handle: lower it so that it turns around its middle.
	blade.position.y = -bounds.get_center().y * size
	var holder := Node3D.new()
	holder.position = Vector3(index * BLADE_SPACING, 1.3, 0)
	holder.add_child(blade)
	parent.add_child(holder)
	return holder


## Lets the glint pass over every mesh of `item`.
func _shine(item: Node) -> void:
	for mesh: MeshInstance3D in item.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = _glint


## Every melee weapon in a row, each with a finish, turning on itself.
func _line_up_blades() -> void:
	for index in Loadout.MELEE.size():
		var item: Dictionary = Loadout.MELEE[index]
		var skin: Dictionary = Loadout.SKINS[(index * 3 + 1) % Loadout.SKINS.size()]
		var holder := _blade_on_show(item, skin, index, _set)
		_shine(holder)
		_spinners.append(holder)
		_twins[holder] = _blade_on_show(item, skin, index, _mirror)
		var skin_color: Color = skin.shot
		_label(str(item.name).to_upper(), Vector3(index * BLADE_SPACING, 0.42, 0), Color.WHITE, 26)
		_label(str(skin.name).to_upper(), Vector3(index * BLADE_SPACING, 0.26, 0), skin_color, 22)


## Every hero side by side, gun in hand, with the name of their ultimate.
func _line_up_heroes() -> void:
	for index in Loadout.CHARACTERS.size():
		var item: Dictionary = Loadout.CHARACTERS[index]
		var at := Vector3(index * HERO_SPACING, 0, 0)
		var scene: PackedScene = load(Loadout.CHARACTER_DIR + str(item.model))
		var gun: Dictionary = Loadout.find(HERO_GUNS[index % HERO_GUNS.size()]).item
		var skin: Dictionary = Loadout.SKINS[(index + 1) % Loadout.SKINS.size()]
		for parent: Node3D in [_set, _mirror]:
			var hero := _actor(scene, 1.75, 0.0, at, PI, &"aim", parent)
			var held := Loadout.instantiate_weapon(gun, skin)
			if parent == _set:
				_shine(held)
			_hold(hero, held, false)
		var ultimate: Dictionary = Ultimate.INFO[item.ulti]
		_label(str(item.name).to_upper(), at + Vector3(0, 2.85, 0), Color.WHITE, 40)
		_label(str(ultimate.name).to_upper(), at + Vector3(0, 2.62, 0), ACCENT, 30)


func _label(text: String, at: Vector3, color: Color, font_size: int) -> void:
	var label := Label3D.new()
	label.text = text
	label.font = FONT
	label.font_size = font_size
	label.pixel_size = 0.005
	label.outline_size = 10
	label.modulate = color
	label.position = at
	_set.add_child(label)


# --- Camera -----------------------------------------------------------------

## Circles `center`, starting at `angle` (radians).
func _orbit(center: Vector3, radius: float, height: float, angle: float, speed: float) -> void:
	_shot = Shot.ORBIT
	_center = center
	_radius = radius
	_height = height
	_angle = angle
	_speed = speed
	_guarded = false
	_reset_lens()
	_place_camera()


## Travels in a straight line while its aim moves from `look_from` to `look_to`.
## `guarded`: steps in front of any wall that would hide the subject.
func _dolly(from: Vector3, to: Vector3, look_from: Vector3, look_to: Vector3, seconds: float,
		guarded := false) -> void:
	_shot = Shot.DOLLY
	_from = from
	_to = to
	_look_from = look_from
	_look_to = look_to
	_shot_start = _clock
	_shot_length = seconds
	_guarded = guarded
	_reset_lens()
	_place_camera()


func _reset_lens() -> void:
	_set_embers(false)
	if _fov_tween:
		_fov_tween.kill()
	_camera.fov = 60.0


func _place_camera() -> void:
	var at := Vector3.ZERO
	var look := _center
	if _shot == Shot.ORBIT:
		at = _center + Vector3(cos(_angle), 0, sin(_angle)) * _radius + Vector3.UP * _height
	else:
		var progress := clampf((_clock - _shot_start) / _shot_length, 0.0, 1.0)
		at = _from.lerp(_to, progress)
		look = _look_from.lerp(_look_to, progress)
		if _guarded:
			at = look + _clear_of_walls(look, at - look)
	at += Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * _shake
	_camera.look_at_from_position(at, look)


## Shortens the camera's offset so that no wall stands between it and its subject.
func _clear_of_walls(subject: Vector3, offset: Vector3) -> Vector3:
	var query := PhysicsRayQueryParameters3D.create(subject, subject + offset, WORLD_LAYER)
	var hit := _camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return offset
	var hit_position: Vector3 = hit.position
	var free := maxf(subject.distance_to(hit_position) - 0.6, 2.0)
	return offset.normalized() * free


# --- Every frame ------------------------------------------------------------

func _process(delta: float) -> void:
	_clock += delta
	_shake = move_toward(_shake, 0.0, (_shake * 3.0 + 0.05) * delta)
	if is_instance_valid(_rays):
		# +Z toward the camera, so that the fan behind it stays flat to the view.
		_rays.look_at(_camera.global_position, Vector3.UP, true)
	for pivot in _walkers:
		if is_instance_valid(pivot):
			pivot.position.z += WALK_SPEED * delta
	for index in _floaters.size():
		var floater := _floaters[index]
		if is_instance_valid(floater):
			# Guns: side-on to the camera, swaying, bobbing.
			floater.rotation.y = PI / 2.0 + sin(_clock * 1.3 + index * 0.8) * 0.6
			floater.position.y = GUN_HEIGHT + sin(_clock * 1.7 + index) * 0.05
	for index in _spinners.size():
		var spinner := _spinners[index]
		if is_instance_valid(spinner):
			spinner.rotation = Vector3(0.25, _clock * 1.5 + index * 0.9, 0)
	if is_instance_valid(_flock):
		_flock.rotation.y += 0.45 * delta
	for item: Node3D in _twins:
		var twin: Node3D = _twins[item]
		if is_instance_valid(item) and is_instance_valid(twin):
			twin.transform = item.transform
	_glint.set_shader_parameter("sweep_x",
			_camera.global_position.x - GLINT_SPAN / 2.0 + fmod(_clock * GLINT_SPEED, GLINT_SPAN))
	for entry: Array in _held:
		var character := entry[0] as CharacterModel
		if is_instance_valid(character):
			character.place_in_hand(entry[1] as Node3D, "R", entry[2] as bool)
	if _shot == Shot.ORBIT:
		_angle += _speed * delta
	_place_camera()


# --- Titles -----------------------------------------------------------------

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	# Cinema bars.
	for top: bool in [true, false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.anchor_right = 1.0
		bar.anchor_top = 0.0 if top else 1.0 - BAR_HEIGHT
		bar.anchor_bottom = BAR_HEIGHT if top else 1.0
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(bar)
	# Darker corners, to pull the eye to the middle of the picture.
	var falloff := Gradient.new()
	falloff.set_color(0, Color(0, 0, 0, 0))
	falloff.set_color(1, Color(0, 0, 0, 0.6))
	falloff.set_offset(0, 0.55)
	var vignette_texture := GradientTexture2D.new()
	vignette_texture.gradient = falloff
	vignette_texture.fill = GradientTexture2D.FILL_RADIAL
	vignette_texture.fill_from = Vector2(0.5, 0.5)
	vignette_texture.fill_to = Vector2(1.0, 1.0)
	var vignette := TextureRect.new()
	vignette.texture = vignette_texture
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(vignette)
	layer.move_child(vignette, 0)
	_blink_rect.color = Color(1, 1, 1, 0)
	_blink_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blink_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_blink_rect)
	_setup_label(layer, _kicker, 24, ACCENT, 0.745, HORIZONTAL_ALIGNMENT_LEFT)
	_setup_label(layer, _caption, 54, Color.WHITE, 0.815, HORIZONTAL_ALIGNMENT_LEFT)
	# The bar of the slide transitions: dark, with a cyan edge on its left.
	_wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wipe_body := ColorRect.new()
	wipe_body.color = Color(0.02, 0.04, 0.16)
	wipe_body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wipe_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe.add_child(wipe_body)
	var wipe_edge := ColorRect.new()
	wipe_edge.color = TEXT_COLOR
	wipe_edge.anchor_bottom = 1.0
	wipe_edge.offset_left = -18.0
	wipe_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe.add_child(wipe_edge)
	_wipe.position.x = 99999.0  # off screen until the first cut
	layer.add_child(_wipe)
	_shade.color = Color.BLACK
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_shade)
	var ramp := Gradient.new()
	ramp.set_color(0, TEXT_COLOR)
	ramp.set_color(1, ACCENT)
	_end_sparks.color_initial_ramp = ramp
	_end_sparks.emitting = false
	_end_sparks.amount = 140
	_end_sparks.lifetime = 4.5
	_end_sparks.position = Vector2(640, 760)
	_end_sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_end_sparks.emission_rect_extents = Vector2(700, 10)
	_end_sparks.direction = Vector2.UP
	_end_sparks.spread = 15.0
	_end_sparks.gravity = Vector2(0, -15)
	_end_sparks.initial_velocity_min = 60.0
	_end_sparks.initial_velocity_max = 170.0
	_end_sparks.scale_amount_min = 2.0
	_end_sparks.scale_amount_max = 5.0
	layer.add_child(_end_sparks)
	_logo_sparks.color_initial_ramp = ramp
	_logo_sparks.emitting = false
	_logo_sparks.one_shot = true
	_logo_sparks.explosiveness = 0.85
	_logo_sparks.amount = 220
	_logo_sparks.lifetime = 0.6
	_logo_sparks.position = Vector2(640, 245)
	_logo_sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_logo_sparks.emission_rect_extents = Vector2(680, 330)
	_logo_sparks.gravity = Vector2.ZERO
	_logo_sparks.radial_accel_min = -3400.0
	_logo_sparks.radial_accel_max = -2800.0
	_logo_sparks.scale_amount_min = 3.0
	_logo_sparks.scale_amount_max = 6.0
	layer.add_child(_logo_sparks)
	_logo.anchor_left = 0.5
	_logo.anchor_right = 0.5
	_logo.anchor_top = 0.34
	_logo.anchor_bottom = 0.34
	_logo.offset_left = -LOGO_SIZE.x / 2.0
	_logo.offset_right = LOGO_SIZE.x / 2.0
	_logo.offset_top = -LOGO_SIZE.y / 2.0
	_logo.offset_bottom = LOGO_SIZE.y / 2.0
	_logo.pivot_offset = LOGO_SIZE / 2.0
	_logo.modulate.a = 0.0
	layer.add_child(_logo)
	_setup_label(layer, _cta, 52, ACCENT, 0.56, HORIZONTAL_ALIGNMENT_CENTER)
	_cta.text = "JOUEZ MAINTENANT"
	_setup_label(layer, _subtitle, 30, Color.WHITE, 0.71, HORIZONTAL_ALIGNMENT_CENTER)


func _setup_label(layer: CanvasLayer, label: Label, font_size: int, color: Color, anchor_y: float,
		alignment: HorizontalAlignment) -> void:
	label.anchor_left = 0.055 if alignment == HORIZONTAL_ALIGNMENT_LEFT else 0.0
	label.anchor_right = 1.0
	label.anchor_top = anchor_y
	label.anchor_bottom = anchor_y
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 12)
	label.modulate.a = 0.0
	layer.add_child(label)


func _fade_shade(alpha: float, seconds: float) -> void:
	create_tween().tween_property(_shade, "color:a", alpha, seconds)


## A short dip to black that opens a chapter.
func _flash() -> void:
	# The new shot is under a bar that slides off to the right, led by a
	# cyan edge.
	var width := get_viewport().get_visible_rect().size.x
	_wipe.position.x = 0.0
	var tween := create_tween()
	tween.tween_property(_wipe, "position:x", width * 1.1, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


## A white flash on a cut, in time with the music.
func _blink() -> void:
	_blink_rect.color.a = 0.55
	create_tween().tween_property(_blink_rect, "color:a", 0.0, 0.3)


## The logo lands on the screen with lines under it, for `seconds`. With
## `end_card`, sparks first rush in to make it, and "JOUEZ MAINTENANT" pulses.
func _show_title(subtitle: String, seconds: float, end_card := false) -> void:
	_subtitle.text = subtitle
	_logo.scale = Vector2.ONE * 1.5
	var tween := create_tween()
	if end_card:
		_logo_sparks.restart()
		_logo_sparks.emitting = true
		tween.tween_interval(0.55)
	tween.tween_property(_logo, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(_logo, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# It lands with a flash and a jolt.
	tween.parallel().tween_callback(_blink).set_delay(0.3 if not end_card else 0.0)
	tween.parallel().tween_callback(func() -> void: _shake = 0.12).set_delay(0.3)
	tween.parallel().tween_property(_subtitle, "modulate:a", 1.0, 0.6).set_delay(0.5)
	if end_card:
		tween.parallel().tween_callback(_pulse_cta).set_delay(0.4)
	# It keeps growing a little while it stays.
	tween.tween_property(_logo, "scale", Vector2.ONE * 1.06, seconds - 1.7 - (0.55 if end_card else 0.0))
	tween.tween_property(_logo, "modulate:a", 0.0, 0.6)
	tween.parallel().tween_property(_subtitle, "modulate:a", 0.0, 0.6)


## "JOUEZ MAINTENANT" appears, then beats: it swells and brightens in a loop.
func _pulse_cta() -> void:
	_cta.pivot_offset = _cta.size / 2.0
	create_tween().tween_property(_cta, "modulate:a", 1.0, 0.3)
	_cta_tween = create_tween().set_loops()
	_cta_tween.tween_property(_cta, "scale", Vector2.ONE * 1.08, 0.35).set_trans(Tween.TRANS_SINE)
	_cta_tween.parallel().tween_property(_cta, "self_modulate", Color(1.5, 1.5, 1.5), 0.35)
	_cta_tween.tween_property(_cta, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE)
	_cta_tween.parallel().tween_property(_cta, "self_modulate", Color.WHITE, 0.45)


## Two lines at the bottom left: a small one over a large one.
## With `count`, `text` holds a %d that counts up from 0 to it.
func _show_caption(kicker: String, text: String, seconds: float, count := -1) -> void:
	if _caption_tween:
		_caption_tween.kill()
	_kicker.text = kicker
	_caption.text = text % 0 if count >= 0 else text
	_kicker.modulate.a = 0.0
	_caption.modulate.a = 0.0
	_caption_tween = create_tween()
	_caption_tween.tween_property(_kicker, "modulate:a", 1.0, 0.25)
	_caption_tween.parallel().tween_property(_caption, "modulate:a", 1.0, 0.25)
	# They slide in from the left.
	for label: Label in [_kicker, _caption]:
		_caption_tween.parallel().tween_property(label, "offset_left", 0.0, 0.35).from(-70.0) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if count >= 0:
		_caption_tween.parallel().tween_method(func(value: float) -> void: _caption.text = text % roundi(value),
				0.0, float(count), COUNT_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_caption_tween.tween_interval(maxf(seconds - 0.6, 0.1))
	_caption_tween.tween_property(_kicker, "modulate:a", 0.0, 0.35)
	_caption_tween.parallel().tween_property(_caption, "modulate:a", 0.0, 0.35)
