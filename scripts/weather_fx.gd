class_name WeatherFx
extends Node3D
## Rain falling around the player, and in a storm, lightning: a flash of the
## sun now and then (see Weather).

const DROPS := 500
const AREA := 34.0
const HEIGHT := 14.0

var storm := false
var sun: DirectionalLight3D

var _rain := CPUParticles3D.new()
var _flash_left := 6.0
var _sun_energy := 1.0


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.75, 0.82, 0.95, 0.45)
	var drop := BoxMesh.new()
	drop.size = Vector3(0.02, 0.5, 0.02)
	drop.material = material
	_rain.mesh = drop
	_rain.amount = DROPS if Settings.high_quality else DROPS / 2
	_rain.lifetime = 1.0
	_rain.local_coords = false
	_rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_rain.emission_box_extents = Vector3(AREA / 2.0, 0.5, AREA / 2.0)
	_rain.direction = Vector3.DOWN
	_rain.spread = 3.0
	_rain.gravity = Vector3(0, -6.0, 0)
	_rain.initial_velocity_min = 14.0
	_rain.initial_velocity_max = 17.0
	add_child(_rain)
	if sun:
		_sun_energy = sun.light_energy


func _process(delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player")
	if player:
		_rain.global_position = player.global_position + Vector3.UP * HEIGHT
	if not storm or sun == null:
		return
	_flash_left -= delta
	if _flash_left <= 0.0:
		_flash_left = randf_range(5.0, 11.0)
		var tween := create_tween()
		tween.tween_property(sun, "light_energy", _sun_energy * 6.0, 0.05)
		tween.tween_property(sun, "light_energy", _sun_energy, 0.15)
		tween.tween_property(sun, "light_energy", _sun_energy * 4.0, 0.05)
		tween.tween_property(sun, "light_energy", _sun_energy, 0.4)
