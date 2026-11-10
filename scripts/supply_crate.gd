class_name SupplyCrate
extends Area3D
## Crate dropped from the sky under a parachute. Once landed, walking into it
## hands the player a random gun for a few magazines.

signal collected(weapon: Dictionary)

const FALL_SPEED := 5.0
const START_HEIGHT := 30.0
const LIFETIME_ON_GROUND := 40.0
## Decks are 3 m high: anything higher is the top of a prop.
const MAX_LANDING_HEIGHT := 3.3
const COLOR := Color(1.0, 0.55, 0.1)
const MODEL := preload("res://assets/models/melee/box-large.glb")

var _ground_y := 0.0
var _landed := false
var _age_on_ground := 0.0
var _parachute := MeshInstance3D.new()
var _beacon := MeshInstance3D.new()


func _ready() -> void:
	add_to_group("transient")
	add_to_group("crates")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * 3.0
	add_child(model)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.2, 2.2, 2.2)
	shape.shape = box
	shape.position.y = 0.8
	add_child(shape)

	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(COLOR, 0.55)
	# Parachute: a wide cone above the crate.
	var canopy := CylinderMesh.new()
	canopy.top_radius = 0.1
	canopy.bottom_radius = 1.8
	canopy.height = 1.2
	canopy.material = glow
	_parachute.mesh = canopy
	_parachute.position.y = 3.2
	add_child(_parachute)
	# Beacon: a tall beam so the crate can be found from afar.
	var beam := CylinderMesh.new()
	beam.top_radius = 0.12
	beam.bottom_radius = 0.12
	beam.height = 14.0
	beam.material = glow
	_beacon.mesh = beam
	_beacon.position.y = 8.0
	_beacon.visible = false
	add_child(_beacon)

	# Find the ground (or a deck) below the drop point. A few tries around it
	# avoid landing on top of a tall prop.
	var space := get_world_3d().direct_space_state
	var from := Vector3(global_position.x, START_HEIGHT, global_position.z)
	for attempt in 8:
		var query := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * (START_HEIGHT + 5.0), 1)
		var hit := space.intersect_ray(query)
		_ground_y = hit.position.y if not hit.is_empty() else 0.0
		if _ground_y <= MAX_LANDING_HEIGHT:
			break
		from += Vector3(randf_range(-4.0, 4.0), 0, randf_range(-4.0, 4.0))
	global_position = from


func _physics_process(delta: float) -> void:
	if _landed:
		_age_on_ground += delta
		if _age_on_ground >= LIFETIME_ON_GROUND:
			queue_free()
		return
	global_position.y -= FALL_SPEED * delta
	if global_position.y <= _ground_y:
		global_position.y = _ground_y
		_landed = true
		_parachute.visible = false
		_beacon.visible = true
		# The player may already be standing where it lands.
		for body in get_overlapping_bodies():
			_on_body_entered(body)


func _on_body_entered(body: Node3D) -> void:
	if not _landed or not body is Player:
		return
	var current: Dictionary = (body as Player).weapon.current_data
	var choices := Loadout.WEAPONS.filter(func(item: Dictionary) -> bool: return item.id != current.id)
	collected.emit(choices.pick_random())
	queue_free()
