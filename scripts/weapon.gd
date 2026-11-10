class_name Weapon
extends Node3D
## Hitscan gun. Shots go where the camera looks (screen center); the tracer is
## drawn from the muzzle to the hit point.

signal hit_confirmed

const TRACER_COLOR := Color(0, 0.9, 1)
const FLASH_TIME := 0.04

@export var fire_rate := 8.0
@export var damage := 1
@export var max_range := 200.0
## Touch only: a shot that misses still hits a target within this angle of the reticle.
@export var aim_assist_deg := 3.0
@export_flags_3d_physics var hit_mask := 5  # world + targets, not the player

var _cooldown := 0.0
var _use_aim_assist := DisplayServer.is_touchscreen_available()
var _tracer_mesh := BoxMesh.new()
var _impact_mesh := SphereMesh.new()

@onready var _muzzle: Marker3D = $Muzzle
@onready var _flash: Node3D = $Muzzle/Flash
@onready var _shot_sound: AudioStreamPlayer = $ShotSound
@onready var _hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = TRACER_COLOR
	_tracer_mesh.size = Vector3(0.04, 0.04, 1.0)
	_tracer_mesh.material = material
	_impact_mesh.radius = 0.12
	_impact_mesh.height = 0.24
	_impact_mesh.radial_segments = 8
	_impact_mesh.rings = 4
	_impact_mesh.material = material
	_flash.visible = false


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if Input.is_action_pressed("fire") and _cooldown == 0.0:
		_fire()


func _fire() -> void:
	_cooldown = 1.0 / fire_rate
	var camera := get_viewport().get_camera_3d()
	var origin := camera.global_position
	var direction := -camera.global_basis.z

	var hit := _cast(origin, origin + direction * max_range)
	if _use_aim_assist and not _is_damageable(hit):
		var assisted := _find_assist_hit(origin, direction)
		if not assisted.is_empty():
			hit = assisted

	var end := origin + direction * max_range
	if not hit.is_empty():
		end = hit.position
		_spawn_impact(end)
		if _is_damageable(hit):
			hit.collider.take_damage(damage)
			_hit_sound.play()
			hit_confirmed.emit()

	_spawn_tracer(_muzzle.global_position, end)
	_show_flash()
	_shot_sound.pitch_scale = randf_range(0.94, 1.06)
	_shot_sound.play()


func _cast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, hit_mask)
	return get_world_3d().direct_space_state.intersect_ray(query)


func _is_damageable(hit: Dictionary) -> bool:
	return not hit.is_empty() and hit.collider.has_method("take_damage")


## Returns a hit on the visible target closest to the aim direction, or {}.
func _find_assist_hit(origin: Vector3, direction: Vector3) -> Dictionary:
	var best := {}
	var best_angle := deg_to_rad(aim_assist_deg)
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		var to_target: Vector3 = target.get_aim_position() - origin
		var angle := direction.angle_to(to_target)
		if angle >= best_angle:
			continue
		var hit := _cast(origin, origin + to_target.normalized() * max_range)
		if not hit.is_empty() and hit.collider == target:
			best = hit
			best_angle = angle
	return best


func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	if length < 0.5:
		return
	var tracer := _spawn_fx(_tracer_mesh)
	tracer.look_at_from_position((from + to) * 0.5, to)
	tracer.scale = Vector3(1.0, 1.0, length)
	_shrink_and_free(tracer, Vector3(0.0, 0.0, length), 0.08)


func _spawn_impact(at: Vector3) -> void:
	var impact := _spawn_fx(_impact_mesh)
	impact.global_position = at
	_shrink_and_free(impact, Vector3.ZERO, 0.15)


func _spawn_fx(mesh: Mesh) -> MeshInstance3D:
	var fx := MeshInstance3D.new()
	fx.mesh = mesh
	fx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	get_tree().current_scene.add_child(fx)
	return fx


func _shrink_and_free(fx: Node3D, to_scale: Vector3, duration: float) -> void:
	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", to_scale, duration)
	tween.tween_callback(fx.queue_free)


func _show_flash() -> void:
	_flash.visible = true
	await get_tree().create_timer(FLASH_TIME).timeout
	_flash.visible = false
