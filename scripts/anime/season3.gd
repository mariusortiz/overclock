class_name Season3Episode
extends Season2Episode
## What the episodes of season 3 share (episodes 21 to 30, "Le Portail"): the
## portal that took the squad, the planets of the unknown galaxy (the crystal
## planet, the star ruins, the moon where time loops), their crystal
## creatures, golems and Gardien, and Le Créateur, with no code to bend here.
##
## Built on season 2's toolkit (narration, Le Créateur); kept apart so that
## seasons 1 and 2 are not rendered again when it changes (see
## .github/workflows/anime.yml).

const CRYSTAL := Color(0.45, 0.85, 1.0)
const CRYSTAL_PINK := Color(0.95, 0.45, 1.0)
const PORTAL := Color(0.7, 0.4, 1.0)
const STONE := Color(0.62, 0.6, 0.7)
## The squad of season 3.
const SQUAD := ["soldier", "kunoichi", "sand_ghost", "ronin", "captain", "paladin", "cowgirl"]

var _spinners: Array[Node3D] = []


func _process(delta: float) -> void:
	super(delta)
	for spinner in _spinners:
		if is_instance_valid(spinner):
			spinner.rotate_object_local(Vector3.FORWARD, delta * 1.6)


func _clear_set() -> void:
	super()
	_spinners.clear()


## One of season 3's places: "crystal", "ruins" (scenes/arenas), or any arena.
func _load_world(scene_name: String) -> void:
	for bubble in _bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_bubbles.clear()
	_clear_set()
	var arena: Node3D = load("res://scenes/arenas/%s.tscn" % scene_name).instantiate()
	_set.add_child(arena)
	_toon(arena)
	_camera.far = 400.0


## The squad standing in a row across `at`, all facing `facing`.
func _squad(at: Vector3, facing: float, ids: Array = SQUAD, spacing := 1.5, armed := false) -> Dictionary:
	var heroes := {}
	var across := Vector3.RIGHT.rotated(Vector3.UP, facing)
	for index in ids.size():
		var offset := across * (index - (ids.size() - 1) / 2.0) * spacing
		heroes[ids[index]] = _hero(ids[index], at + offset, facing, "" if armed else "none")
	return heroes


## A portal: a ring of light standing up, its middle swirling, sparks pulled
## into it. Faces +Z (turn it with `facing`).
func _portal(at: Vector3, radius: float, facing := 0.0) -> Node3D:
	var portal := Node3D.new()
	_set.add_child(portal)
	portal.position = at
	portal.rotation.y = facing
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = PORTAL.lerp(Color.WHITE, 0.3)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.9
	torus.outer_radius = radius
	torus.material = glow
	ring.mesh = torus
	ring.rotation.x = PI / 2.0
	portal.add_child(ring)
	var inside := StandardMaterial3D.new()
	inside.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	inside.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inside.cull_mode = BaseMaterial3D.CULL_DISABLED
	inside.albedo_color = Color(0.25, 0.1, 0.5, 0.75)
	var disc := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius * 0.9
	cylinder.bottom_radius = radius * 0.9
	cylinder.height = 0.02
	cylinder.material = inside
	disc.mesh = cylinder
	disc.rotation.x = PI / 2.0
	portal.add_child(disc)
	# A spiral of light turning in the middle.
	var swirl := Node3D.new()
	portal.add_child(swirl)
	for i in 3:
		var arm := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(radius * 1.6, radius * 0.06, 0.03)
		box.material = glow
		arm.mesh = box
		arm.rotation.z = TAU * i / 3.0
		swirl.add_child(arm)
	_spinners.append(swirl)
	var sparks := CPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var spark := StandardMaterial3D.new()
	spark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	spark.albedo_color = PORTAL.lerp(Color.WHITE, 0.5)
	quad.material = spark
	sparks.mesh = quad
	sparks.amount = 90
	sparks.lifetime = 1.6
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	sparks.emission_ring_axis = Vector3.FORWARD
	sparks.emission_ring_radius = radius * 1.5
	sparks.emission_ring_inner_radius = radius * 1.1
	sparks.emission_ring_height = 0.1
	sparks.gravity = Vector3.ZERO
	sparks.radial_accel_min = -radius * 3.0
	sparks.radial_accel_max = -radius * 2.0
	sparks.tangential_accel_min = radius
	sparks.tangential_accel_max = radius * 1.5
	portal.add_child(sparks)
	var light := OmniLight3D.new()
	light.light_color = PORTAL
	light.light_energy = 3.0
	light.omni_range = radius * 5.0
	portal.add_child(light)
	return portal


## The portal opens: it grows from a point.
func _open(portal: Node3D, seconds: float) -> void:
	portal.scale = Vector3.ONE * 0.01
	create_tween().tween_property(portal, "scale", Vector3.ONE, seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_ring(portal.position, PORTAL, 14.0, seconds)
	_shake = maxf(_shake, 0.2)


## `model` (its pivot) is pulled into `portal`, spinning and shrinking.
func _pull_in(model: Node3D, portal: Node3D, seconds: float, delay := 0.0) -> void:
	var pivot := _pivot_of(model)
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(pivot, "position", portal.position, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(pivot, "rotation:y", pivot.rotation.y + TAU * 2.0, seconds)
	tween.parallel().tween_property(pivot, "scale", Vector3.ONE * 0.05, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		pivot.visible = false
		Effects.burst(_set, portal.position, PORTAL, 20))


## A creature of the crystal planet: the planet's sentinel, glowing.
func _crystal_creature(at: Vector3, facing: float, action: StringName) -> Enemy:
	var enemy := _enemy(at, facing, action)
	_overlay(enemy, Color(CRYSTAL, 0.35))
	return enemy


## A stone golem of the ruins: the giant skeleton, carved in stone, its eyes
## and joints glowing gold.
func _golem(at: Vector3, facing: float, height := 4.0) -> CharacterModel:
	var golem := _actor(load(Boss.MODEL_DIR + "monsters/Skeleton.fbx"), height, at, facing)
	var stone := StandardMaterial3D.new()
	stone.albedo_color = STONE
	stone.albedo_texture = load("res://assets/textures/panel_light.png")
	stone.uv1_triplanar = true
	stone.uv1_scale = Vector3.ONE * 0.5
	for mesh: MeshInstance3D in golem.find_children("*", "MeshInstance3D", true, false):
		var toon := _toon_material(stone)
		mesh.material_override = toon
	_overlay(golem, Color(GOLD, 0.12))
	return golem


## The portal's Gardien: the giant crystal wizard (Boss.dress_guardian).
func _guardian(at: Vector3, facing: float, height := 9.0) -> CharacterModel:
	var guardian := _actor(load(Boss.MODEL_DIR + str(Boss.INFO[Boss.Kind.GUARDIAN].model)), height, at, facing)
	Boss.dress_guardian(guardian)
	return guardian


func _overlay(node: Node, color: Color) -> void:
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = color
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = glow


## A crystal rings: a note of light rises from it.
func _note(at: Vector3, color: Color) -> void:
	_ring(at, color, 3.0, 0.8)
	Effects.burst(_set, at + Vector3.UP * 1.2, color, 24)
	Effects.flash(_set, at + Vector3.UP * 1.2, color, 6.0, 0.3)


## A star map in the air: dots of light around `at`, one of them pulsing.
func _star_map(at: Vector3, size: float) -> Node3D:
	var map := Node3D.new()
	_set.add_child(map)
	map.position = at
	var random := RandomNumberGenerator.new()
	random.seed = 7
	var light := StandardMaterial3D.new()
	light.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	light.albedo_color = CRYSTAL.lerp(Color.WHITE, 0.4)
	for i in 40:
		var star := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = size * random.randf_range(0.02, 0.045)
		sphere.height = sphere.radius * 2.0
		sphere.material = light
		star.mesh = sphere
		star.position = Vector3(random.randf_range(-1, 1), random.randf_range(-0.5, 0.5), random.randf_range(-0.3, 0.3)) * size
		map.add_child(star)
	var target := MeshInstance3D.new()
	var marker := SphereMesh.new()
	marker.radius = size * 0.08
	marker.height = size * 0.16
	var gold := StandardMaterial3D.new()
	gold.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gold.albedo_color = GOLD
	marker.material = gold
	target.mesh = marker
	target.position = Vector3(size * 0.55, size * 0.2, 0)
	map.add_child(target)
	var pulse := target.create_tween().set_loops()
	pulse.tween_property(target, "scale", Vector3.ONE * 1.8, 0.4)
	pulse.tween_property(target, "scale", Vector3.ONE, 0.4)
	# A faint disc of light behind the stars: a hologram.
	var back := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = size * 1.1
	disc.bottom_radius = size * 1.1
	disc.height = 0.02
	var haze := StandardMaterial3D.new()
	haze.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	haze.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	haze.albedo_color = Color(0.04, 0.03, 0.15, 0.8)
	disc.material = haze
	back.mesh = disc
	back.rotation.x = PI / 2.0
	back.position.z = -size * 0.35
	map.add_child(back)
	map.scale = Vector3.ONE * 0.01
	create_tween().tween_property(map, "scale", Vector3.ONE, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return map


## A statue of Le Créateur, carved long ago: the cow, in gold, gone dull.
func _statue(at: Vector3, facing: float, height: float) -> CharacterModel:
	var statue := _actor(load(Loadout.CHARACTER_DIR + "Cow.fbx"), height, at, facing)
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.85, 0.68, 0.32)
	gold.metallic = 0.6
	for mesh: MeshInstance3D in statue.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = _toon_material(gold)
	statue.play(&"victory")
	return statue


## Night falls on the set: a black sky with a big ringed planet hanging in
## it (the moon of episode 27).
func _night_sky() -> void:
	for child in _set.get_children():
		var world := child.find_child("WorldEnvironment", true, false) as WorldEnvironment
		if world == null:
			continue
		var environment := world.environment.duplicate(true) as Environment
		var sky := environment.sky.sky_material as ProceduralSkyMaterial
		sky.sky_top_color = Color(0.0, 0.0, 0.02)
		sky.sky_horizon_color = Color(0.08, 0.06, 0.16)
		environment.fog_light_color = Color(0.08, 0.06, 0.16)
		world.environment = environment
	var planet := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 40.0
	sphere.height = 80.0
	var surface := StandardMaterial3D.new()
	surface.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.albedo_color = Color(0.55, 0.35, 0.75)
	surface.disable_fog = true
	sphere.material = surface
	planet.mesh = sphere
	planet.position = Vector3(-60, 70, -220)
	_set.add_child(planet)
	var band := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 55.0
	torus.outer_radius = 70.0
	var ring := StandardMaterial3D.new()
	ring.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.albedo_color = Color(0.85, 0.7, 0.95)
	ring.disable_fog = true
	torus.material = ring
	band.mesh = torus
	band.position = planet.position
	band.rotation = Vector3(0.35, 0, 0.25)
	_set.add_child(band)


## Three moons in the sky of the unknown galaxy, seen from `at` looking -Z.
func _moons() -> void:
	for moon: Array in [[Vector3(-70, 90, -200), 18.0, Color(0.85, 0.75, 1.0)], [Vector3(30, 120, -260), 11.0, Color(0.6, 0.9, 1.0)],
			[Vector3(90, 70, -180), 7.0, Color(1.0, 0.7, 0.85)]]:
		var body := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = moon[1]
		sphere.height = moon[1] * 2.0
		var surface := StandardMaterial3D.new()
		surface.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		surface.albedo_color = moon[2]
		surface.disable_fog = true
		sphere.material = surface
		body.mesh = sphere
		body.position = moon[0]
		_set.add_child(body)


## A ship that came down hard: tilted, half in the ground, smoking.
func _wreck(color: Color, at: Vector3, facing: float) -> RaceShip:
	var ship := _parked_ship(color, at, facing)
	ship.rotation.z = 0.35
	ship.rotation.x = -0.2
	var smoke := CPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.6, 0.6)
	var grey := StandardMaterial3D.new()
	grey.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grey.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	grey.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grey.albedo_color = Color(0.3, 0.3, 0.35, 0.5)
	quad.material = grey
	smoke.mesh = quad
	smoke.amount = 30
	smoke.lifetime = 2.5
	smoke.direction = Vector3.UP
	smoke.spread = 20.0
	smoke.gravity = Vector3.UP * 0.5
	smoke.initial_velocity_min = 0.8
	smoke.initial_velocity_max = 1.6
	smoke.scale_amount_max = 2.5
	_set.add_child(smoke)
	smoke.global_position = at + Vector3.UP * 0.8
	return ship


## Time skips back: the picture flashes white and shakes, the clock rewinds.
func _rewind() -> void:
	_impact_frame()
	_glitch(0.5)
	_speed(0.6)
	_shake = 0.3


## Le Créateur tries his tricks, and nothing happens: no code here.
func _no_power(creator: CharacterModel) -> void:
	creator.play(&"victory", true)
	Effects.burst(_set, creator.global_position + Vector3.UP * 1.8, Color(0.6, 0.6, 0.6), 6)
