class_name Season4Episode
extends Season3Episode
## What the episodes of season 4 share (episodes 32 to 41, "Les Miroirs"):
## the doubles of the squad, come from a mirror world where Le Créateur
## never wrote the game; that world's city in reverse colors; mirror shards
## hanging in the air; Le Reflet, who copies whoever stands in front of him.
##
## Built on season 3's toolkit; kept apart so that seasons 1 to 3 are not
## rendered again when it changes (see .github/workflows/anime.yml).

const MIRROR := Color(0.6, 0.35, 1.0)
const GLASS := Color(0.78, 0.74, 0.95)


## A hero's double: the same hero under a dark violet sheen.
func _double(id: String, at: Vector3, facing: float, gun := "none") -> CharacterModel:
	var double := _hero(id, at, facing, gun)
	_overlay(double, Color(0.4, 0.15, 0.75, 0.55))
	return double


## Turns a model into glass of `color`, with a violet glow at its edges.
func _glass(model: Node3D, color: Color) -> void:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = color
	glass.metallic = 0.85
	glass.roughness = 0.1
	var shaded := _toon_material(glass)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(MIRROR, 0.25)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = shaded
		mesh.material_overlay = glow


## Le Reflet: the squad's soldier in mirror glass, `height` tall.
func _reflect(at: Vector3, facing: float, height := 3.4) -> CharacterModel:
	var reflect := _actor(load(Loadout.CHARACTER_DIR + "Soldier_Male.fbx"), height, at, facing)
	_overlay(reflect, Color(0.85, 0.8, 1.0, 0.5))
	reflect.play(&"idle")
	return reflect


## The mirror Titan: a Titan in mirror glass.
func _mirror_titan(at: Vector3, height := TITAN_HEIGHT) -> CharacterModel:
	var titan := _spawn_titan(at, height)
	_glass(titan, GLASS)
	return titan


## The mirror world: the city of scenes/arenas/mirror.tscn, darker still,
## and shards of mirror turning in the air.
func _load_mirror_world() -> void:
	_load_world("mirror")
	_shards(Vector3(0, 9, -6), 14, 22.0)


## A world as it is (`scene_name`), its sky gone violet: the two worlds
## meeting (episodes 40 and 41).
func _tint_world(color: Color) -> void:
	for world: WorldEnvironment in _set.find_children("*", "WorldEnvironment", true, false):
		var environment: Environment = world.environment.duplicate(true)
		world.environment = environment
		if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
			var sky := environment.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = sky.sky_top_color.lerp(color.darkened(0.6), 0.6)
			sky.sky_horizon_color = sky.sky_horizon_color.lerp(color, 0.6)
		environment.ambient_light_color = environment.ambient_light_color.lerp(color, 0.4)
		environment.fog_light_color = environment.fog_light_color.lerp(color, 0.6)


## Mirror shards: flat panes of glass turning slowly in the air around `at`.
func _shards(at: Vector3, count: int, spread: float) -> void:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.85, 0.82, 1.0, 0.8)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.metallic = 1.0
	glass.roughness = 0.05
	glass.emission_enabled = true
	glass.emission = MIRROR
	glass.emission_energy_multiplier = 0.4
	var rng := RandomNumberGenerator.new()
	rng.seed = episode_number
	for i in count:
		var pane := BoxMesh.new()
		pane.size = Vector3(rng.randf_range(0.6, 1.8), rng.randf_range(1.0, 2.4), 0.05)
		pane.material = glass
		var shard := MeshInstance3D.new()
		shard.mesh = pane
		shard.position = at + Vector3(rng.randf_range(-spread, spread), rng.randf_range(-3, 5), rng.randf_range(-spread, spread * 0.5))
		shard.rotation = Vector3(rng.randf_range(-0.4, 0.4), rng.randf() * TAU, rng.randf_range(-0.4, 0.4))
		_set.add_child(shard)
		_spinners.append(shard)


## A tall mirror standing up, facing +Z (turn it with `facing`): a frame of
## light around a pane of glass. Doubles step out of it.
func _mirror(at: Vector3, facing: float, height := 3.2) -> Node3D:
	var mirror := Node3D.new()
	# See-through: what stands behind it is its reflection.
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.7, 0.68, 0.95, 0.35)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.metallic = 0.8
	glass.roughness = 0.04
	var frame := StandardMaterial3D.new()
	frame.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	frame.albedo_color = MIRROR
	var pane := BoxMesh.new()
	pane.size = Vector3(height * 0.55, height, 0.06)
	pane.material = glass
	var pane_node := MeshInstance3D.new()
	pane_node.mesh = pane
	pane_node.position.y = height / 2.0
	mirror.add_child(pane_node)
	for side in [-1.0, 1.0]:
		var post := BoxMesh.new()
		post.size = Vector3(0.12, height + 0.12, 0.12)
		post.material = frame
		var post_node := MeshInstance3D.new()
		post_node.mesh = post
		post_node.position = Vector3(side * height * 0.28, height / 2.0, 0)
		mirror.add_child(post_node)
		var bar := BoxMesh.new()
		bar.size = Vector3(height * 0.56 + 0.12, 0.12, 0.12)
		bar.material = frame
		var bar_node := MeshInstance3D.new()
		bar_node.mesh = bar
		bar_node.position = Vector3(0, height / 2.0 + side * height / 2.0, 0)
		mirror.add_child(bar_node)
	_set.add_child(mirror)
	mirror.position = at
	mirror.rotation.y = facing
	return mirror


## A mirror breaks: a burst of glass and a flash.
func _shatter(node: Node3D) -> void:
	var at := node.global_position + Vector3.UP * 1.5
	Effects.spray(_set, at, [GLASS, MIRROR, Color.WHITE], 70, Vector3(0.12, 0.12, 0.02), Vector2(3.0, 7.0),
			Vector3(0, -6.0, 0), 80.0, 1.4)
	Effects.flash(_set, at, MIRROR, 8.0, 0.4)
	node.queue_free()


## A double gives way: it shatters like glass.
func _break(model: Node3D) -> void:
	var pivot := _pivot_of(model)
	var at := model.global_position + Vector3.UP
	Effects.spray(_set, at, [GLASS, MIRROR], 50, Vector3(0.1, 0.1, 0.02), Vector2(2.0, 5.0), Vector3(0, -6.0, 0), 70.0, 1.2)
	pivot.visible = false
