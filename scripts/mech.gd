class_name Mech
extends Node3D
## A mech waiting in the arena (once in a game of waves, see Main): walking
## into it climbs aboard for PILOT_TIME seconds. Aboard: a heavy machine gun,
## a rocket at the nearest enemy every ROCKET_INTERVAL, damage taken divided
## by ten, a higher view. Then it blows up and the hero jumps out.

signal boarded
signal left

const MODEL := preload("res://assets/models/quaternius/mechs/George.fbx")
const TEXTURE := "res://assets/models/quaternius/mechs/George_Texture.jpg"
const HEIGHT := 3.2
const BOARD_DISTANCE := 2.6
const PILOT_TIME := 30.0
const WAIT_TIME := 45.0
const ROCKET_INTERVAL := 2.0
const ROCKET_RANGE := 32.0
const ROCKET_DAMAGE := 12
const ROCKET_RADIUS := 4.0
const COLOR := Color(0.2, 0.9, 1.0)
const GUN := {"id": "mech_gun", "name": "Mitrailleuse du mech", "model": "AssaultRifle2_1", "length": 0.95,
		"fire_rate": 14.0, "damage": 3, "magazine": 400, "reload_time": 0.6, "zoom_fov": 50.0}

var _player: Player
var _model: Node3D
var _beacon: MeshInstance3D
var _piloting := false
var _left := PILOT_TIME
var _wait := WAIT_TIME
var _rocket_left := ROCKET_INTERVAL
var _camera_height := 0.0


func _ready() -> void:
	add_to_group("transient")
	_model = build_model()
	add_child(_model)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(COLOR, 0.35)
	var column := CylinderMesh.new()
	column.top_radius = 0.6
	column.bottom_radius = 0.6
	column.height = 30.0
	column.material = material
	_beacon = MeshInstance3D.new()
	_beacon.mesh = column
	_beacon.position.y = 15.0
	_beacon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_beacon)
	_player = get_tree().get_first_node_in_group("player") as Player


## The mech's model: the Quaternius mech in white and cyan, HEIGHT tall,
## facing -Z (the trailer uses it too).
static func build_model() -> Node3D:
	var model: Node3D = MODEL.instantiate()
	model.set_script(CharacterModel)
	(model as CharacterModel).target_height = HEIGHT
	var body := StandardMaterial3D.new()
	body.albedo_texture = load(TEXTURE)
	body.albedo_color = Color(0.75, 0.95, 1.0)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(COLOR, 0.15)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = body
		mesh.material_overlay = glow
	var holder := Node3D.new()
	holder.add_child(model)
	(model as CharacterModel).play.call_deferred(&"idle")
	return holder


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if not _piloting:
		rotate_y(delta * 0.6)
		_wait -= delta
		if _wait <= 0.0:
			Effects.burst(get_tree().current_scene, global_position + Vector3.UP, COLOR, 20)
			queue_free()
		elif _player.health > 0 and _player.global_position.distance_to(global_position) <= BOARD_DISTANCE:
			_board()
		return
	_left -= delta
	if _player.health <= 0 or _left <= 0.0:
		_leave()
		return
	_rocket_left -= delta
	if _rocket_left <= 0.0:
		_rocket_left = ROCKET_INTERVAL
		_fire_rocket()


func _board() -> void:
	_piloting = true
	_beacon.queue_free()
	remove_child(_model)
	_player.add_child(_model)
	_model.position = Vector3.ZERO
	_model.rotation.y = 0.0
	_player._model.visible = false
	_player.damage_factor = 0.1
	_player.move_speed *= 0.85
	_camera_height = 1.4
	(_player.get_node("CameraPivot") as Node3D).position.y += _camera_height
	_player._spring_arm.spring_length += 2.0
	_player.weapon.equip_temporary(GUN)
	Effects.flash(get_tree().current_scene, _player.global_position + Vector3.UP * 2.0, COLOR, 8.0, 0.4)
	boarded.emit()


func _leave() -> void:
	set_physics_process(false)
	Effects.burst(get_tree().current_scene, _player.global_position + Vector3.UP * 1.5, Color(1.0, 0.55, 0.15), 50)
	Effects.flash(get_tree().current_scene, _player.global_position + Vector3.UP * 1.5, Color(1.0, 0.55, 0.15), 10.0, 0.5)
	_model.queue_free()
	_player._model.visible = true
	_player.damage_factor = 1.0
	_player.move_speed /= 0.85
	(_player.get_node("CameraPivot") as Node3D).position.y -= _camera_height
	_player._spring_arm.spring_length -= 2.0
	_player.weapon.end_temporary()
	left.emit()
	queue_free()


## A rocket from the mech's shoulder to the nearest enemy in reach: it hurts
## everything around where it lands.
func _fire_rocket() -> void:
	var from := _player.global_position + Vector3.UP * (HEIGHT * 0.85)
	var best: Node3D = null
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		var distance := target.global_position.distance_to(_player.global_position)
		if distance <= ROCKET_RANGE and (best == null or distance < best.global_position.distance_to(_player.global_position)):
			best = target
	if best == null:
		return
	var at: Vector3 = best.get_aim_position()
	Effects.tracer(get_tree().current_scene, from, at, Color(1.0, 0.55, 0.15))
	Effects.burst(get_tree().current_scene, at, Color(1.0, 0.55, 0.15), 30)
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		if target.get_aim_position().distance_to(at) <= ROCKET_RADIUS:
			_player.weapon.tag_kill(target)
			target.take_damage(ROCKET_DAMAGE)


## The seconds left aboard (for the HUD).
func time_left() -> float:
	return _left if _piloting else 0.0
