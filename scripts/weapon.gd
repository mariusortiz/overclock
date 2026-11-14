class_name Weapon
extends Node3D
## Hitscan gun. Shots go where the camera looks (screen center); the tracer is
## drawn from the muzzle to the hit point. Stats come from a Loadout.WEAPONS
## entry, and the owner's perks modify them.

## `headshot` is true when the shot hit the head.
signal hit_confirmed(headshot: bool)
signal ammo_changed(current: int, magazine: int, reloading: bool)
## A gun was taken in hand (the player's own, or one found in a crate).
signal equipped(weapon_name: String)
## A shot left the gun (once per trigger pull, whatever the pellets).
signal fired

## Camera shake when one of the player's rockets goes off.
const ROCKET_SHAKE := 0.18
const TRACER_COLOR := Color(0, 0.9, 1)
const FLASH_TIME := 0.04
const HEADSHOT_MULTIPLIER := 2
## Magazines that come with a gun found in a crate.
const TEMPORARY_MAGAZINES := 3
const ROCKET_SCENE := preload("res://scenes/rocket.tscn")

@export var max_range := 200.0
## Touch only: a shot that misses still hits a target within this angle of the reticle.
@export var aim_assist_deg := 3.0
@export_flags_3d_physics var hit_mask := 5  # world + targets, not the player

var fire_rate := 8.0
var damage := 1
var magazine_size := 24
var reload_time := 1.4
## Camera field of view while aiming.
var zoom_fov := 40.0
## Above 0, the weapon fires rockets that explode with this radius.
var blast_radius := 0.0
var ammo := 0
var damage_multiplier := 1
## Perk.Type -> level, shared with the player.
var perks := {}
## The Loadout.WEAPONS entry in hand.
var current_data := {}
## Ultimate: fires twice as fast without using ammo.
var overdrive := false
## Shots per trigger pull and their scatter in degrees (shotguns).
var pellets := 1
var spread := 0.0
## Exotic guns (see Loadout.WEAPONS): reach of a shot, shots that go through
## every enemy in line, a thick lasting beam, and fire set on the enemies hit.
var shot_range := 200.0
var pierce := false
var beam := false
var ignite := 0
## When set, the gun is held in this character's right hand.
var holder: CharacterModel

var _cooldown := 0.0
var _reloading := false
var _muzzle_offset := Vector3.ZERO
## Survival: where reloads take their bullets (it is given how many are
## wanted and returns how many it gave); unset, magazines are free.
var ammo_supply := Callable()
## The player's own gun, to come back to after a temporary one.
var _own_data := {}
var _temporary_magazines := 0
var _kill_style := &""
var _kill_color := Color.WHITE
var _use_aim_assist := DisplayServer.is_touchscreen_available()
var _tracer_mesh := BoxMesh.new()
var _lightning_mesh := BoxMesh.new()
var _impact_mesh := SphereMesh.new()
var _explosion_mesh := SphereMesh.new()

@onready var _model_pivot: Node3D = $ModelPivot
@onready var _muzzle: Marker3D = $Muzzle
@onready var _flash: Node3D = $Muzzle/Flash
@onready var _shot_sound: AudioStreamPlayer = $ShotSound
@onready var _hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	_tracer_mesh.size = Vector3(0.04, 0.04, 1.0)
	_tracer_mesh.material = _fx_material(TRACER_COLOR)
	_lightning_mesh.size = Vector3(0.07, 0.07, 1.0)
	_lightning_mesh.material = _fx_material(Perk.INFO[Perk.Type.LIGHTNING].color)
	_set_sphere(_impact_mesh, 0.12, _fx_material(TRACER_COLOR))
	_set_sphere(_explosion_mesh, Perk.EXPLOSION_RADIUS, _fx_material(Color(1.0, 0.6, 0.2, 0.35)))
	_flash.visible = false


## Applies a Loadout.WEAPONS entry: model, stats, full magazine.
func setup(data: Dictionary, owner_perks: Dictionary) -> void:
	perks = owner_perks
	_own_data = data
	_equip(data)


## Swaps to a gun found in a crate. It lasts a few magazines, then the
## player's own gun comes back.
func equip_temporary(data: Dictionary) -> void:
	_temporary_magazines = TEMPORARY_MAGAZINES
	_equip(data)


## Drops a temporary gun at once (the mech's, when it is left).
func end_temporary() -> void:
	if _temporary_magazines > 0:
		_temporary_magazines = 0
		_equip(_own_data)


func _equip(data: Dictionary) -> void:
	current_data = data
	_reloading = false
	fire_rate = data.fire_rate
	damage = data.damage
	magazine_size = data.magazine
	reload_time = data.reload_time
	zoom_fov = data.zoom_fov
	blast_radius = data.get("blast_radius", 0.0)
	pellets = data.get("pellets", 1)
	spread = data.get("spread", 0.0)
	shot_range = data.get("range", max_range)
	pierce = data.get("pierce", false)
	beam = data.get("beam", false)
	ignite = data.get("ignite", 0)
	_tracer_mesh.size = Vector3(0.12, 0.12, 1.0) if beam else Vector3(0.04, 0.04, 1.0)

	for old in _model_pivot.get_children():
		_model_pivot.remove_child(old)
		old.queue_free()
	_model_pivot.add_child(Loadout.instantiate_weapon(data))
	# The skin also colors the shots and decides how enemies die.
	var skin := Loadout.selected_skin()
	var shot_color: Color = skin.shot
	_kill_style = skin.kill
	_kill_color = shot_color
	(_tracer_mesh.material as StandardMaterial3D).albedo_color = shot_color
	(_impact_mesh.material as StandardMaterial3D).albedo_color = shot_color
	($Muzzle/Flash/Mesh as MeshInstance3D).material_override = _fx_material(shot_color.lerp(Color.WHITE, 0.5))
	($Muzzle/Flash/Light as OmniLight3D).light_color = shot_color
	_muzzle_offset = Loadout.weapon_layout(data, Loadout.selected_skin()).muzzle
	_muzzle.position = _muzzle_offset

	ammo = get_magazine_size()
	ammo_changed.emit(ammo, get_magazine_size(), false)
	equipped.emit(data.name)


func get_magazine_size() -> int:
	return roundi(magazine_size * (1.0 + Perk.MAGAZINE_BONUS * _level(Perk.Type.BIG_MAGAZINE)))


## Call after the owner gains a perk.
func on_perks_changed() -> void:
	if not _reloading:
		ammo = get_magazine_size()
		ammo_changed.emit(ammo, get_magazine_size(), false)


func _process(_delta: float) -> void:
	# The gun sits in the hand but keeps pointing where the player aims.
	if holder and holder.place_in_hand(_model_pivot, "R", false):
		_muzzle.position = _model_pivot.position + _muzzle_offset


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _reloading:
		return
	if Input.is_action_just_pressed("reload") and ammo < get_magazine_size():
		_reload()
	elif Input.is_action_pressed("fire") and _cooldown == 0.0:
		_fire()


func _level(type: Perk.Type) -> int:
	return perks.get(type, 0)


func _fire() -> void:
	_cooldown = 1.0 / (fire_rate * (1.0 + Perk.RAPID_FIRE_BONUS * _level(Perk.Type.RAPID_FIRE)))
	if overdrive:
		_cooldown *= 0.5
	var camera := get_viewport().get_camera_3d()
	var origin := camera.global_position
	var direction := -camera.global_basis.z

	# A shotgun fires several pellets at once, scattered in a cone.
	for pellet in pellets:
		var scattered := direction
		if spread > 0.0:
			var side := camera.global_basis.x.rotated(direction, randf() * TAU)
			scattered = direction.rotated(side, deg_to_rad(spread) * sqrt(randf()))
		_fire_ray(origin, scattered)

	_show_flash()
	fired.emit()
	_shot_sound.pitch_scale = randf_range(0.94, 1.06)
	_shot_sound.play()

	if overdrive:
		return
	ammo -= 1
	ammo_changed.emit(ammo, get_magazine_size(), false)
	if ammo == 0:
		_reload()


## One shot from the camera along `direction`: hit, damage and effects.
func _fire_ray(origin: Vector3, direction: Vector3) -> void:
	if pierce:
		_fire_piercing(origin, direction)
		return
	var hit := _cast(origin, origin + direction * shot_range)
	if _use_aim_assist and spread == 0.0 and not _is_damageable(hit):
		var assisted := _find_assist_hit(origin, direction)
		if not assisted.is_empty():
			hit = assisted

	var end := origin + direction * shot_range
	if not hit.is_empty():
		end = hit.position

	if blast_radius > 0.0:
		_launch_rocket(end)
	else:
		if not hit.is_empty():
			_spawn_fx(_impact_mesh, end, 0.15)
			if _is_damageable(hit):
				var headshot := _apply_hit(hit.collider, end)
				_hit_sound.pitch_scale = 1.6 if headshot else 1.0
				_hit_sound.play()
				hit_confirmed.emit(headshot)
			elif _level(Perk.Type.EXPLOSIVE) > 0:
				_explode(end, null)
		_spawn_tracer(_tracer_mesh, _muzzle.global_position, end, 0.16 if beam else 0.08)


## A shot that goes through enemies: it hits each one in line, up to the
## first wall.
func _fire_piercing(origin: Vector3, direction: Vector3) -> void:
	var end := origin + direction * shot_range
	var passed: Array[RID] = []
	var hit_any := false
	var headshot_any := false
	for i in 12:
		var query := PhysicsRayQueryParameters3D.create(origin, end, hit_mask, passed)
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break
		if not _is_damageable(hit):
			end = hit.position
			break
		passed.append(hit.rid)
		_spawn_fx(_impact_mesh, hit.position, 0.15)
		headshot_any = _apply_hit(hit.collider, hit.position) or headshot_any
		hit_any = true
	if hit_any:
		_hit_sound.pitch_scale = 1.6 if headshot_any else 1.0
		_hit_sound.play()
		hit_confirmed.emit(headshot_any)
	_spawn_tracer(_tracer_mesh, _muzzle.global_position, end, 0.16 if beam else 0.08)


func _launch_rocket(toward: Vector3) -> void:
	var rocket: Rocket = ROCKET_SCENE.instantiate()
	var from := _muzzle.global_position
	rocket.position = from
	rocket.direction = from.direction_to(toward)
	rocket.exploded.connect(_on_rocket_exploded)
	get_tree().current_scene.add_child(rocket)


func _on_rocket_exploded(at: Vector3) -> void:
	var blast := _spawn_fx(_explosion_mesh, at, 0.25)
	var shooter := get_parent() as Player
	if shooter:
		shooter.shake(ROCKET_SHAKE)
	blast.scale = Vector3.ONE * (blast_radius / Perk.EXPLOSION_RADIUS)
	var hit_any := false
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		if at.distance_to(target.get_aim_position()) <= blast_radius:
			_damage_with_elements(target)
			hit_any = true
	if hit_any:
		_hit_sound.pitch_scale = 1.0
		_hit_sound.play()
		hit_confirmed.emit(false)


## Damages an enemy and applies the fire and ice perks.
## Makes `enemy` die the way the equipped skin kills, if it dies next.
func tag_kill(enemy: Node3D) -> void:
	enemy.set_kill_effect(_kill_style, _kill_color)


func _damage_with_elements(enemy: Node3D, multiplier := 1) -> void:
	tag_kill(enemy)
	enemy.take_damage(damage * damage_multiplier * multiplier)
	if _level(Perk.Type.FIRE) > 0 or ignite > 0:
		enemy.ignite(_level(Perk.Type.FIRE) + ignite)
	if _level(Perk.Type.ICE) > 0:
		enemy.chill(_level(Perk.Type.ICE))


## A direct hit: damage (doubled on the head), elements, then the chaining
## perks. Returns true for a headshot.
func _apply_hit(enemy: Node3D, point: Vector3) -> bool:
	var headshot: bool = enemy.has_method("is_head_hit") and enemy.is_head_hit(point)
	if headshot:
		enemy.mark_headshot()
	_damage_with_elements(enemy, HEADSHOT_MULTIPLIER if headshot else 1)
	if _level(Perk.Type.LIGHTNING) > 0:
		_chain_lightning(enemy)
	if _level(Perk.Type.EXPLOSIVE) > 0:
		_explode(point, enemy)
	return headshot


## Jumps to the closest other enemy in range.
func _chain_lightning(from_enemy: Node3D) -> void:
	var from: Vector3 = from_enemy.get_aim_position()
	var closest: Node3D = null
	var closest_distance := Perk.LIGHTNING_RANGE
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		var distance := from.distance_to(target.get_aim_position())
		if target != from_enemy and distance < closest_distance:
			closest = target
			closest_distance = distance
	if closest:
		_spawn_tracer(_lightning_mesh, from, closest.get_aim_position(), 0.15)
		tag_kill(closest)
		closest.take_damage(_level(Perk.Type.LIGHTNING))


## Splash damage around an impact. `direct_hit` already took the shot itself.
func _explode(point: Vector3, direct_hit: Node3D) -> void:
	_spawn_fx(_explosion_mesh, point, 0.2)
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		if target != direct_hit and point.distance_to(target.get_aim_position()) <= Perk.EXPLOSION_RADIUS:
			tag_kill(target)
			target.take_damage(_level(Perk.Type.EXPLOSIVE))


func _reload() -> void:
	# A temporary gun is dropped once its magazines are spent.
	if _temporary_magazines > 0:
		_temporary_magazines -= 1
		if _temporary_magazines == 0:
			_equip(_own_data)
			return
	_reloading = true
	ammo_changed.emit(ammo, get_magazine_size(), true)
	var reloaded := current_data
	await get_tree().create_timer(reload_time, false).timeout
	if current_data != reloaded:
		return  # the gun changed while reloading
	if ammo_supply.is_valid():
		ammo += int(ammo_supply.call(get_magazine_size() - ammo))
	else:
		ammo = get_magazine_size()
	_reloading = false
	ammo_changed.emit(ammo, get_magazine_size(), false)


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
		if Weather.fog() and to_target.length() > Weather.FOG_ASSIST_RANGE:
			continue
		var angle := direction.angle_to(to_target)
		if angle >= best_angle:
			continue
		var hit := _cast(origin, origin + to_target.normalized() * max_range)
		if not hit.is_empty() and hit.collider == target:
			best = hit
			best_angle = angle
	return best


# --- Visual effects ---------------------------------------------------------

func _fx_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _set_sphere(mesh: SphereMesh, radius: float, material: Material) -> void:
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = material


func _spawn_tracer(mesh: Mesh, from: Vector3, to: Vector3, duration := 0.08) -> void:
	var length := from.distance_to(to)
	if length < 0.5:
		return
	var tracer := _spawn_fx(mesh, (from + to) * 0.5, duration, Vector3(0.0, 0.0, length))
	tracer.look_at(to)
	tracer.scale = Vector3(1.0, 1.0, length)


## Shows a mesh that shrinks to `end_scale` and disappears.
func _spawn_fx(mesh: Mesh, at: Vector3, duration: float, end_scale := Vector3.ZERO) -> MeshInstance3D:
	var fx := MeshInstance3D.new()
	fx.mesh = mesh
	fx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fx.position = at
	get_tree().current_scene.add_child(fx)
	var tween := fx.create_tween()
	tween.tween_property(fx, "scale", end_scale, duration)
	tween.tween_callback(fx.queue_free)
	return fx


func _show_flash() -> void:
	_flash.visible = true
	await get_tree().create_timer(FLASH_TIME).timeout
	_flash.visible = false
