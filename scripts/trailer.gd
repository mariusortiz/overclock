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
const DURATION := 120.0
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
var _flock: Node3D

var _shade := ColorRect.new()
var _title := Label.new()
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
	_show_title("OVERCLOCK", "SHOOTER D'ARÈNE · 3D LOW-POLY", 5.0)
	await _until(7.0)

	# Five arenas at a glance.
	for index in ARENAS.size():
		_load_arena(index)
		_orbit(Vector3(0, 1, 0), 30.0, 8.0 + index, 1.1 * index, 0.3)
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
		_show_caption("ENNEMIS", info.enemies, 3.5)
		await _until(start + 7.7)
		if index == CITY:
			start += 8.0
			await _until(start)
			break
		_clear_actors()
		var boss_kind: Boss.Kind = info.boss
		_present_boss(boss_kind, 4.3)
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
	_show_caption("ARSENAL", "%d ARMES · %d SKINS" % [Loadout.WEAPONS.size(), Loadout.SKINS.size()], 13.5)
	await _until(92.0)

	# 92 s: the heroes.
	_build_showroom()
	_flash()
	_line_up_heroes()
	var last_hero := (Loadout.CHARACTERS.size() - 1) * HERO_SPACING
	_dolly(Vector3(-1.0, 1.5, 4.9), Vector3(last_hero + 1.0, 1.5, 4.9),
			Vector3(-1.0, 1.45, 0), Vector3(last_hero + 1.0, 1.45, 0), 12.0)
	_show_caption("CHACUN SON ULTI", "%d HÉROS" % Loadout.CHARACTERS.size(), 10.5)
	await _until(104.0)

	# 104 s: the last boss, and what beating it earns.
	_load_arena(CITY)
	_flash()
	_present_boss(Boss.Kind.TITAN, 4.6)
	_show_caption("AU BOUT DE LA VILLE", "LE TITAN", 3.8)
	await _until(108.6)
	_clear_actors()
	var trophy := Trophy.new()
	_set.add_child(trophy)
	trophy.position = BOSS_SPOT
	_orbit(BOSS_SPOT + Vector3.UP * 1.6, 7.0, 2.2, 1.2, 0.5)
	_show_caption("BATS-LE", "GAGNE LE SKIN CHAMPION", 2.4)
	await _until(111.0)

	# End card.
	_fade_shade(1.0, 1.0)
	await _until(112.3)
	_show_title("OVERCLOCK", "JOUEZ MAINTENANT\n%s\n\n5 ARÈNES · 5 BOSS · %d ARMES · %d HÉROS" % [
			URL, Loadout.WEAPONS.size(), Loadout.CHARACTERS.size()], 7.2)
	await _until(DURATION)
	get_tree().quit()


func _until(time: float) -> void:
	while _clock < time:
		await get_tree().process_frame


# --- Sets -------------------------------------------------------------------

func _clear() -> void:
	_clear_actors()
	for child in _set.get_children():
		child.queue_free()


## Frees the models on stage and keeps the set.
func _clear_actors() -> void:
	for node in _actors + _floaters:
		if is_instance_valid(node):
			node.queue_free()
	_actors.clear()
	_floaters.clear()
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

	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.05, 0.06, 0.15)
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
	_strike_later(boss, seconds * 0.35)


func _strike_later(boss: CharacterModel, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(boss) and not boss.is_queued_for_deletion():
		boss.play(&"shoot", true)


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
		var gun := Loadout.instantiate_weapon(item, skin)
		var length: float = item.length
		gun.scale = Vector3.ONE * (GUN_LENGTH / length)
		# The grip is at the gun's origin: slide it back to turn around its middle.
		gun.position.z = GUN_LENGTH * 0.4
		var holder := Node3D.new()
		holder.position = Vector3(index * GUN_SPACING, GUN_HEIGHT, 0)
		holder.add_child(gun)
		_set.add_child(holder)
		_floaters.append(holder)
		var skin_color: Color = skin.shot
		_label(str(item.name).to_upper(), Vector3(index * GUN_SPACING, 0.78, 0), Color.WHITE, 26)
		_label(str(skin.name).to_upper(), Vector3(index * GUN_SPACING, 0.62, 0), skin_color, 22)


## Every hero side by side, gun in hand, with the name of their ultimate.
func _line_up_heroes() -> void:
	for index in Loadout.CHARACTERS.size():
		var item: Dictionary = Loadout.CHARACTERS[index]
		var at := Vector3(index * HERO_SPACING, 0, 0)
		var scene: PackedScene = load(Loadout.CHARACTER_DIR + str(item.model))
		var hero := _actor(scene, 1.75, 0.0, at, PI, &"aim")
		var gun: Dictionary = Loadout.find(HERO_GUNS[index % HERO_GUNS.size()]).item
		var skin: Dictionary = Loadout.SKINS[(index + 1) % Loadout.SKINS.size()]
		_hold(hero, Loadout.instantiate_weapon(gun, skin), false)
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
	_place_camera()


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
	for pivot in _walkers:
		if is_instance_valid(pivot):
			pivot.position.z += WALK_SPEED * delta
	for index in _floaters.size():
		var floater := _floaters[index]
		if is_instance_valid(floater):
			# Guns: side-on to the camera, swaying, bobbing.
			floater.rotation.y = PI / 2.0 + sin(_clock * 1.3 + index * 0.8) * 0.6
			floater.position.y = GUN_HEIGHT + sin(_clock * 1.7 + index) * 0.05
	if is_instance_valid(_flock):
		_flock.rotation.y += 0.45 * delta
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
	_setup_label(layer, _kicker, 24, ACCENT, 0.745, HORIZONTAL_ALIGNMENT_LEFT)
	_setup_label(layer, _caption, 54, Color.WHITE, 0.815, HORIZONTAL_ALIGNMENT_LEFT)
	_shade.color = Color.BLACK
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_shade)
	_setup_label(layer, _title, 150, TEXT_COLOR, 0.32, HORIZONTAL_ALIGNMENT_CENTER)
	_setup_label(layer, _subtitle, 34, Color.WHITE, 0.64, HORIZONTAL_ALIGNMENT_CENTER)


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
	_shade.color.a = 1.0
	_fade_shade(0.0, 0.4)


## Big title with lines under it, shown for `seconds`.
func _show_title(title: String, subtitle: String, seconds: float) -> void:
	_title.text = title
	_subtitle.text = subtitle
	var tween := create_tween()
	tween.tween_property(_title, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(_subtitle, "modulate:a", 1.0, 0.6).set_delay(0.5)
	tween.tween_interval(seconds - 1.8)
	tween.tween_property(_title, "modulate:a", 0.0, 0.6)
	tween.parallel().tween_property(_subtitle, "modulate:a", 0.0, 0.6)


## Two lines at the bottom left: a small one over a large one.
func _show_caption(kicker: String, text: String, seconds: float) -> void:
	if _caption_tween:
		_caption_tween.kill()
	_kicker.text = kicker
	_caption.text = text
	_kicker.modulate.a = 0.0
	_caption.modulate.a = 0.0
	_caption_tween = create_tween()
	_caption_tween.tween_property(_kicker, "modulate:a", 1.0, 0.25)
	_caption_tween.parallel().tween_property(_caption, "modulate:a", 1.0, 0.25)
	_caption_tween.tween_interval(maxf(seconds - 0.6, 0.1))
	_caption_tween.tween_property(_kicker, "modulate:a", 0.0, 0.35)
	_caption_tween.parallel().tween_property(_caption, "modulate:a", 0.0, 0.35)
