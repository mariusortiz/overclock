extends Node3D
## Composition rendered once to make the loading screen artwork (see
## tools/make_poster.py). Not part of the game: open it with F6 from the home
## screen in a test build.

const CHARACTERS := "res://assets/models/quaternius/characters/"
const MONSTERS := "res://assets/models/quaternius/monsters/"

## Each fighter: model, place, turn (degrees, 0 = facing the camera), the
## animation frozen at "time" seconds, and what they hold (Loadout ids).
const CAST := [
	{"model": "Soldier_Male.fbx", "at": Vector3(0.0, 0.0, 0.9), "yaw": 8.0, "action": &"shoot", "time": 0.05, "weapon": "heavy", "melee": ""},
	{"model": "Ninja_Male.fbx", "at": Vector3(-1.5, 0.0, 0.1), "yaw": 30.0, "action": &"melee", "time": 0.3, "weapon": "", "melee": "knife"},
	{"model": "Cowboy_Female.fbx", "at": Vector3(1.5, 0.0, 0.1), "yaw": -28.0, "action": &"shoot", "time": 0.0, "weapon": "blaster", "melee": ""},
	{"model": "Viking_Male.fbx", "at": Vector3(-3.0, 0.0, -0.9), "yaw": 38.0, "action": &"melee", "time": 0.2, "weapon": "", "melee": "axe"},
	{"model": "Knight_Golden_Male.fbx", "at": Vector3(3.0, 0.0, -0.9), "yaw": -38.0, "action": &"victory", "time": 0.6, "weapon": "", "melee": "mace"},
]

## Weapon holders and the hand each one follows.
var _held: Array[Array] = []


func _ready() -> void:
	_build_backdrop()
	for fighter: Dictionary in CAST:
		_add_fighter(fighter)

	var dragon := _create_model(MONSTERS + "Dragon.fbx", 4.6, 0.2)
	var dragon_holder := _add_holder(Vector3(0.0, 0.0, -6.5), 0.0)
	dragon_holder.add_child(dragon)
	dragon.freeze(&"idle", 0.4)


func _process(_delta: float) -> void:
	for pair in _held:
		(pair[0] as Node3D).global_position = (pair[1] as Node3D).global_position


func _add_fighter(fighter: Dictionary) -> void:
	var holder := _add_holder(fighter.at, fighter.yaw)
	var model := _create_model(CHARACTERS + fighter.model, 1.75, 0.0)
	holder.add_child(model)
	model.freeze(fighter.action, fighter.time)
	if fighter.weapon != "":
		_hold(holder, Loadout.instantiate_weapon(Loadout.find(fighter.weapon).item, Loadout.SKINS[0]), model.get_attachment("Fist.R"))
	if fighter.melee != "":
		_hold(holder, Loadout.instantiate_melee(Loadout.find(fighter.melee).item), model.get_attachment("Fist.R"))


func _hold(holder: Node3D, item: Node3D, hand: Node3D) -> void:
	var grip := Node3D.new()
	holder.add_child(grip)
	grip.add_child(item)
	_held.append([grip, hand])


## A node at `at`, turned so that 0 degrees faces the camera.
func _add_holder(at: Vector3, yaw_deg: float) -> Node3D:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = PI + deg_to_rad(yaw_deg)
	add_child(holder)
	return holder


func _create_model(path: String, height: float, hover: float) -> CharacterModel:
	var model: Node3D = load(path).instantiate()
	model.set_script(CharacterModel)
	var character := model as CharacterModel
	character.target_height = height
	character.hover_height = hover
	return character


func _build_backdrop() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.03, 0.06, 0.2)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.4, 0.45, 0.75)
	environment.ambient_light_energy = 0.5
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.04, 0.08, 0.26)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(60, 60)
	floor_mesh.material = floor_material
	var ground := MeshInstance3D.new()
	ground.mesh = floor_mesh
	add_child(ground)

	# Warm key light from the front right, colored rim lights from behind.
	var key := DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.92, 0.8)
	key.light_energy = 1.5
	key.shadow_enabled = true
	add_child(key)
	key.look_at_from_position(Vector3(4, 6, 6), Vector3(0, 1, 0))
	_add_rim_light(Vector3(-4.0, 3.0, -2.5), Color(1.0, 0.24, 0.95))
	_add_rim_light(Vector3(4.0, 3.0, -2.5), Color(0.16, 0.83, 1.0))

	var camera := Camera3D.new()
	camera.fov = 36.0
	add_child(camera)
	camera.look_at_from_position(Vector3(0.0, 1.0, 7.0), Vector3(0.0, 1.5, 0.0))
	camera.make_current()


func _add_rim_light(at: Vector3, color: Color) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = 6.0
	light.omni_range = 12.0
	add_child(light)
