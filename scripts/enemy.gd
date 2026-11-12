class_name Enemy
extends CharacterBody3D
## Robot: chases the player along the navigation mesh, then stops and shoots
## when in range with a clear line of sight.

signal died
signal health_changed(current: int, maximum: int)

const REPATH_INTERVAL := 0.3
const EYE_HEIGHT := 1.2
const WORLD_MASK := 1
const SHOOT_ANIMATION_TIME := 0.4
const DEATH_ANIMATION_TIME := 1.0
## The head starts this far up the model, as a fraction of its height.
const HEAD_START := 0.68
## Beyond this height difference the player is on another floor.
const LEVEL_HEIGHT := 1.5
const MELEE_RANGE := 2.2
const MELEE_INTERVAL := 1.0
const MELEE_SPEED_BONUS := 1.35
const FLY_HEIGHT := 4.5
const FLY_DISTANCE := 9.0
const BURN_DURATION := 3.0
const BURN_TICK := 0.5
const CHILL_DURATION := 2.5
const BURN_COLOR := Color(1.0, 0.45, 0.1)
const CHILL_COLOR := Color(0.5, 0.85, 1.0)
## Elite: bigger, tougher, wrapped in a golden glow, and always drops a bonus.
const ELITE_SCALE := 1.35
const ELITE_HEALTH := 3
const ELITE_COLOR := Color(1.0, 0.8, 0.2)
## Sniper: keeps its distance, shows a laser while it aims, then hits hard.
const SNIPER_AIM_TIME := 1.1
const SNIPER_DAMAGE := 18
const SNIPER_KEEP_AWAY := 12.0
const LASER_COLOR := Color(1.0, 0.1, 0.15)
## Kamikaze: runs at the player and blows up on contact, or when shot down.
const KAMIKAZE_RADIUS := 3.5
const KAMIKAZE_DAMAGE := 25
const KAMIKAZE_COLOR := Color(1.0, 0.25, 0.1)

@export var max_health := 5
@export var move_speed := 3.5
@export var acceleration := 20.0
@export var turn_speed := 8.0
@export var attack_range := 12.0
@export var fire_interval := 1.6
@export var projectile_scene: PackedScene
@export var model_scene: PackedScene
## Height of the point shots are aimed at.
@export var aim_height := 1.0

## Size of the fitted model (see CharacterModel).
var model_height := 1.75
var model_hover := 0.0
## Bosses always die their own way.
var kill_effects_enabled := true
## What it fights with: the id of a Loadout gun or melee weapon, or "" for
## bare hands. Anything but a gun makes it charge and strike at close range.
var weapon_id := "blaster"
## Damage of a close-range strike (enemies without a gun).
var melee_damage := 0
## A flying enemy hovers around the player instead of walking.
var flying := false
## How it fights: &"" (as its weapon says), &"sniper" or &"kamikaze".
var role := &""
var elite := false
@export var power_up_scene: PackedScene
@export var drop_chance := 0.25

var _health := 0
var _dead := false
var _fire_cooldown := 0.0
var _repath_left := 0.0
var _shoot_animation_left := 0.0
var _burn_left := 0.0
var _burn_tick_left := 0.0
var _burn_damage := 0
var _chill_left := 0.0
var _chill_factor := 1.0
var _status_material := StandardMaterial3D.new()
var _player: Player
var _model: CharacterModel
var _base_scale := Vector3.ONE
var _attack_animation := &"shoot"
var _aim_animation := &"aim"
var _stun_left := 0.0
var _freeze_left := 0.0
var _kill_style := &""
var _kill_color := Color.WHITE
## Set by the weapon just before a headshot lands, for the damage number.
var _headshot_pending := false
## Sniper: seconds of aiming left (laser shown), and the laser itself.
var _aim_left := 0.0
var _laser: MeshInstance3D
var _tween: Tween
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _visual: Node3D = $Visual
@onready var _model_pivot: Node3D = $Visual/ModelPivot
@onready var _muzzle: Marker3D = $Visual/Muzzle
@onready var _gun: Node3D = $Visual/Gun
@onready var _status_orb: MeshInstance3D = $Visual/StatusOrb
@onready var _shot_sound: AudioStreamPlayer3D = $ShotSound
@onready var _death_sound: AudioStreamPlayer3D = $DeathSound


func _ready() -> void:
	add_to_group("targets")
	if elite:
		max_health *= ELITE_HEALTH
		drop_chance = 1.0
		_visual.scale *= ELITE_SCALE
	_health = max_health
	_base_scale = _visual.scale
	var model: Node3D = model_scene.instantiate()
	model.set_script(CharacterModel)
	_model = model as CharacterModel
	_model.target_height = model_height
	_model.hover_height = model_hover
	_model_pivot.add_child(_model)
	_equip()
	if elite:
		_glow(ELITE_COLOR, 0.3)
	if role == &"kamikaze":
		_glow(KAMIKAZE_COLOR, 0.45, true)
	_fire_cooldown = fire_interval
	_status_material.emission_enabled = true
	_status_material.emission_energy_multiplier = 2.0
	_status_orb.material_override = _status_material
	_status_orb.visible = false
	_player = get_tree().get_first_node_in_group("player") as Player


## Point the player's shots (and aim assist) should go for.
func get_aim_position() -> Vector3:
	return global_position + Vector3.UP * aim_height


## Remembers how this enemy should die if the next damage kills it.
func set_kill_effect(style: StringName, color: Color) -> void:
	_kill_style = style
	_kill_color = color


## The next damage comes from a headshot (it is shown in another color).
func mark_headshot() -> void:
	_headshot_pending = true


## True when a shot landing at `point` (world space) hits the head.
func is_head_hit(point: Vector3) -> bool:
	var head_base := (model_hover + model_height * HEAD_START) * _base_scale.y
	return point.y >= global_position.y + head_base


func take_damage(amount: int) -> void:
	if _dead:
		return
	_health -= amount
	health_changed.emit(maxi(_health, 0), max_health)
	var color := Effects.HEADSHOT_COLOR if _headshot_pending else Effects.DAMAGE_COLOR
	if _burn_tick_left == BURN_TICK:
		color = Effects.DAMAGE_OVER_TIME_COLOR
	Effects.damage_number(get_tree().current_scene, get_aim_position() + Vector3.UP * 0.6, amount, color, _headshot_pending)
	_headshot_pending = false
	if _health <= 0:
		_die()
	else:
		_visual.scale = _base_scale * 1.2
		_scale_visual_to(_base_scale, 0.12)


## Mace: thrown back, and unable to act for a moment.
func knockback(direction: Vector3, strength: float) -> void:
	if _dead:
		return
	velocity.x = direction.x * strength
	velocity.z = direction.z * strength
	_stun_left = 0.35


## Stops the enemy from moving and attacking for `seconds`.
func stun(seconds: float) -> void:
	_freeze_left = seconds


## Fire perk: takes `damage_per_tick` twice a second for a few seconds.
func ignite(damage_per_tick: int) -> void:
	_burn_left = BURN_DURATION
	_burn_damage = damage_per_tick


## Ice perk: moves and shoots more slowly for a moment.
func chill(level: int) -> void:
	_chill_left = CHILL_DURATION
	_chill_factor = maxf(pow(0.6, level), 0.3)


func _update_statuses(delta: float) -> void:
	_chill_left = maxf(_chill_left - delta, 0.0)
	if _burn_left > 0.0:
		_burn_left -= delta
		_burn_tick_left -= delta
		if _burn_tick_left <= 0.0:
			_burn_tick_left = BURN_TICK
			take_damage(_burn_damage)

	_status_orb.visible = not _dead and (_burn_left > 0.0 or _chill_left > 0.0)
	var color := BURN_COLOR if _burn_left > 0.0 else CHILL_COLOR
	_status_material.albedo_color = color
	_status_material.emission = color


func _physics_process(delta: float) -> void:
	_update_statuses(delta)
	var slow := _chill_factor if _chill_left > 0.0 else 1.0

	if flying and not _dead:
		_fly(delta, slow)
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var wanted := Vector3.ZERO
	var animation := &"idle"
	_freeze_left -= delta
	if not _dead and _freeze_left <= 0.0 and _player and _player.health > 0:
		var to_player := _player.global_position - global_position
		_face(to_player, delta)
		var can_shoot := to_player.length() <= attack_range and _has_line_of_sight()
		if _aim_left > 0.0:
			_aim_left -= delta
			if _aim_left <= 0.0:
				_snipe()
		elif can_shoot:
			_fire_cooldown -= delta * slow
			if _fire_cooldown <= 0.0:
				_shoot()
		# Stand and aim only on the player's floor; otherwise keep coming (up
		# or down a ramp), shooting on the way when the player is in sight.
		# A sniper backs away from a player who comes too close.
		if role == &"sniper" and _aim_left <= 0.0 and to_player.length() < SNIPER_KEEP_AWAY:
			var away := Vector3(-to_player.x, 0, -to_player.z).normalized()
			wanted = away * move_speed * slow
			animation = &"walk"
		elif (can_shoot and absf(to_player.y) < LEVEL_HEIGHT) or _aim_left > 0.0:
			animation = _aim_animation
		else:
			wanted = _chase_direction(delta) * move_speed * slow
			if not wanted.is_zero_approx():
				animation = &"walk"

	# Let the one-shot shooting animation finish before switching back.
	_shoot_animation_left -= delta
	if not _dead and _shoot_animation_left <= 0.0:
		_model.play(animation)

	# While knocked back, the enemy slides to a stop instead of steering.
	_stun_left -= delta
	var target_velocity := Vector3.ZERO if _stun_left > 0.0 else wanted
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	move_and_slide()

	# The gun sits in the hand but keeps pointing forward; a blade follows the arm.
	if _model.place_in_hand(_gun, "R", melee_damage > 0):
		_muzzle.global_position = _gun.global_position - global_basis.z * 0.5 + Vector3.UP * 0.2
	_update_laser()


## Puts the weapon in hand and, without a gun, switches to close combat.
func _equip() -> void:
	if flying:
		_gun.visible = false
		return
	var found := Loadout.find(weapon_id)
	if not found.is_empty() and found.kind == "Arme":
		_gun.add_child(Loadout.instantiate_weapon(found.item, Loadout.SKINS[0]))
		return
	if not found.is_empty():
		_gun.add_child(Loadout.instantiate_melee(found.item))
	if melee_damage == 0:
		melee_damage = 8
	attack_range = MELEE_RANGE
	fire_interval = MELEE_INTERVAL
	move_speed *= MELEE_SPEED_BONUS
	_attack_animation = &"melee"
	_aim_animation = &"idle"


## Flying: circles the player at a distance, above the ground, and shoots.
func _fly(delta: float, slow: float) -> void:
	var wanted := Vector3.ZERO
	_freeze_left -= delta
	if _freeze_left <= 0.0 and _player and _player.health > 0:
		var to_player := _player.global_position - global_position
		_face(to_player, delta)
		var flat := Vector3(to_player.x, 0, to_player.z)
		var distance := flat.length()
		var toward := flat / maxf(distance, 0.01)
		# Close in or back off to the orbit distance, while drifting sideways.
		wanted = toward * clampf(distance - FLY_DISTANCE, -1.0, 1.0) + toward.cross(Vector3.UP) * 0.6
		wanted.y = clampf(_player.global_position.y + FLY_HEIGHT - global_position.y, -1.0, 1.0)
		wanted *= move_speed * slow
		if distance <= attack_range and _has_line_of_sight():
			_fire_cooldown -= delta * slow
			if _fire_cooldown <= 0.0:
				_shoot()
	_shoot_animation_left -= delta
	if _shoot_animation_left <= 0.0:
		_model.play(&"walk")
	_stun_left -= delta
	if _stun_left <= 0.0:
		velocity = velocity.move_toward(wanted, acceleration * delta)
	move_and_slide()
	_muzzle.global_position = global_position + Vector3.UP * aim_height - global_basis.z * 0.6


func _face(to_player: Vector3, delta: float) -> void:
	var target_yaw := atan2(-to_player.x, -to_player.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, minf(turn_speed * delta, 1.0))


func _has_line_of_sight() -> bool:
	var from := global_position + Vector3.UP * EYE_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, _player.get_aim_position(), WORLD_MASK)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _chase_direction(delta: float) -> Vector3:
	# The navigation map is empty until the arena has baked and synced.
	if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
		return Vector3.ZERO
	_repath_left -= delta
	if _repath_left <= 0.0:
		_repath_left = REPATH_INTERVAL
		_agent.target_position = _player.global_position
	if _agent.is_navigation_finished():
		return Vector3.ZERO
	var direction := _agent.get_next_path_position() - global_position
	direction.y = 0.0
	return direction.normalized()


func _shoot() -> void:
	_fire_cooldown = fire_interval
	if role == &"sniper":
		# A sniper first takes aim, laser on, and only then fires (see _snipe).
		_aim_left = SNIPER_AIM_TIME
		return
	_attack()
	_shot_sound.play()
	_model.play(_attack_animation, true)
	_shoot_animation_left = SHOOT_ANIMATION_TIME


## What a shot does. Bosses override this.
func _attack() -> void:
	if role == &"kamikaze":
		if global_position.distance_to(_player.global_position) <= attack_range + 0.5:
			_die()
		return
	if melee_damage > 0:
		if global_position.distance_to(_player.global_position) <= attack_range + 0.5:
			_player.take_damage(melee_damage)
		return
	_spawn_projectile(_muzzle.global_position.direction_to(_player.get_aim_position()))


## The sniper's shot, at the end of its aim: it hits if the player is still
## in sight.
func _snipe() -> void:
	_shot_sound.play()
	_model.play(_attack_animation, true)
	_shoot_animation_left = SHOOT_ANIMATION_TIME
	var target := _player.get_aim_position()
	var query := PhysicsRayQueryParameters3D.create(_muzzle.global_position, target, WORLD_MASK)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		_player.take_damage(SNIPER_DAMAGE)
	else:
		target = hit.position
	Effects.tracer(get_tree().current_scene, _muzzle.global_position, target, LASER_COLOR)


## Red line from the sniper's gun to the player while it takes aim.
func _update_laser() -> void:
	var aiming := _aim_left > 0.0 and not _dead and _player != null
	if not aiming:
		if _laser:
			_laser.queue_free()
			_laser = null
		return
	if _laser == null:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = LASER_COLOR
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.025, 0.025, 1.0)
		mesh.material = material
		_laser = MeshInstance3D.new()
		_laser.mesh = mesh
		_laser.add_to_group("transient")
		get_tree().current_scene.add_child(_laser)
	var from := _muzzle.global_position
	var to := _player.get_aim_position()
	if from.is_equal_approx(to):
		return
	_laser.look_at_from_position((from + to) / 2.0, to)
	_laser.scale = Vector3(1, 1, from.distance_to(to))


## Wraps the model in a colored glow; `pulse` makes it throb.
func _glow(color: Color, strength: float, pulse := false) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.albedo_color = Color(color, strength)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = material
	if pulse:
		var tween := create_tween().set_loops()
		tween.tween_property(material, "albedo_color:a", strength * 0.2, 0.25)
		tween.tween_property(material, "albedo_color:a", strength, 0.25)


## A kamikaze's blast, which hurts the player if close enough.
func _blow_up() -> void:
	_kill_style = &"burst"
	_kill_color = KAMIKAZE_COLOR
	var at := get_aim_position()
	Effects.burst(get_tree().current_scene, at, KAMIKAZE_COLOR, 44)
	Effects.burst(get_tree().current_scene, at, Color(1.0, 0.85, 0.3), 20)
	if _player and _player.global_position.distance_to(global_position) <= KAMIKAZE_RADIUS:
		_player.take_damage(KAMIKAZE_DAMAGE)
		_player.shake(0.25)


func _spawn_projectile(direction: Vector3) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.position = _muzzle.global_position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)


func _die() -> void:
	_dead = true
	remove_from_group("targets")
	collision_layer = 0
	_update_laser()
	if role == &"kamikaze":
		_blow_up()
	died.emit()
	if randf() < drop_chance:
		_drop_power_up()
	_death_sound.play()
	if _tween:
		_tween.kill()
	_visual.scale = _base_scale
	_tween = create_tween()
	_play_death(_kill_style if kill_effects_enabled else &"")
	_tween.tween_callback(queue_free)


## Animates the death on `_tween`. The style comes from the skin of the gun
## that made the kill: each skin has its own (see Loadout.SKINS).
func _play_death(style: StringName) -> void:
	var scene := get_tree().current_scene
	var chest := get_aim_position()
	match style:
		&"knockback":  # thrown back, spinning, and gone in a puff of smoke
			_model.play(&"die")
			var away := Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.5
			if _player:
				away = (global_position - _player.global_position).normalized() * 2.5
			_tween.tween_property(self, "global_position", global_position + away + Vector3.UP * 0.6, 0.45) \
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			_tween.parallel().tween_property(_visual, "rotation:x", -TAU * 0.75, 0.45)
			_tween.tween_callback(Effects.spray.bind(scene, chest + away, [Color(0.8, 0.8, 0.8), Color(0.55, 0.55, 0.6)], 18,
					Vector3.ONE * 0.3, Vector2(0.5, 1.5), Vector3(0, 0.8, 0), 180.0, 1.0))
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.15)
		&"vanish":  # Néon: stretches into a beam of light
			_model.stop()
			_model.tint(_kill_color, 2.5)
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(0.05, 2.6, 0.05), 0.4)
			_tween.tween_callback(Effects.burst.bind(scene, chest + Vector3.UP, _kill_color, 14, true))
		&"shatter":  # Glace: freezes solid, then breaks apart
			_model.stop()
			_model.tint(_kill_color.lerp(Color.WHITE, 0.4), 0.3)
			_tween.tween_interval(0.45)
			_tween.tween_callback(Effects.burst.bind(scene, chest, _kill_color, 36))
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.05)
		&"burn":  # Lave: chars, glowing, with rising embers
			_model.play(&"die")
			_model.tint(Color(0.12, 0.08, 0.06).lerp(_kill_color, 0.35), 1.2)
			Effects.burst(scene, chest, _kill_color, 28, true)
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(0.6, 0.15, 0.6), 1.0)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.2)
		&"leaves":  # Camouflage: crumbles into leaves that drift down
			_model.stop()
			_model.tint(Color(0.25, 0.35, 0.15))
			Effects.spray(scene, chest + Vector3.UP * 0.4, [Color(0.3, 0.5, 0.15), Color(0.45, 0.6, 0.2), Color(0.5, 0.35, 0.15)], 40,
					Vector3(0.18, 0.18, 0.01), Vector2(0.5, 2.0), Vector3(0, -1.2, 0), 120.0, 2.2)
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(1, 0.01, 1), 0.5)
		&"melt":  # Toxique: sinks into a puddle, bubbling
			_model.play(&"die")
			_model.tint(_kill_color, 0.6)
			Effects.burst(scene, chest, _kill_color, 20, true)
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(1.5, 0.04, 1.5), 1.0)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.3)
		&"ascend":  # Royal: lifted up, crowned with purple sparks, then fades
			_model.stop()
			_model.tint(_kill_color, 1.2)
			Effects.spray(scene, chest + Vector3.UP * 0.8, [_kill_color, Color(1.0, 0.85, 0.3)], 30,
					Vector3.ONE * 0.08, Vector2(1.0, 2.5), Vector3(0, 1.0, 0), 40.0, 1.4, true)
			_tween.tween_property(_visual, "position:y", 2.2, 0.9).set_ease(Tween.EASE_IN)
			_tween.parallel().tween_property(_visual, "rotation:y", TAU, 0.9)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.2)
		&"pixelate":  # Carbone: breaks up into black cubes that tumble down
			_model.stop()
			_model.tint(Color(0.08, 0.08, 0.1))
			_tween.tween_interval(0.15)
			_tween.tween_callback(Effects.spray.bind(scene, chest, [Color(0.06, 0.06, 0.08), Color(0.25, 0.25, 0.28), Color.WHITE], 48,
					Vector3.ONE * 0.2, Vector2(1.0, 3.0), Vector3(0, -9.0, 0), 160.0, 1.3))
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.06)
		&"petals":  # Sakura: bursts into pink petals that float away
			Effects.spray(scene, chest, [_kill_color, Color(1.0, 0.75, 0.88), Color.WHITE], 60,
					Vector3(0.14, 0.1, 0.01), Vector2(2.0, 4.5), Vector3(0.6, -0.8, 0), 180.0, 2.4)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.08)
		&"splash":  # Océan: bursts into a splash of water and slumps
			_model.play(&"die")
			_model.tint(_kill_color, 0.4)
			Effects.spray(scene, chest, [_kill_color, Color(0.6, 0.85, 1.0), Color.WHITE], 50,
					Vector3.ONE * 0.1, Vector2(3.0, 6.0), Vector3(0, -12.0, 0), 50.0, 1.0)
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(1.3, 0.05, 1.3), 0.35)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.25)
		&"flare":  # Solaire: a blinding flash and sun rays
			_model.stop()
			_model.tint(Color.WHITE, 4.0)
			Effects.flash(scene, chest, _kill_color, 10.0, 0.5)
			Effects.spray(scene, chest, [_kill_color, Color.WHITE], 36,
					Vector3(0.05, 0.05, 0.6), Vector2(6.0, 9.0), Vector3.ZERO, 180.0, 0.35, true)
			_tween.tween_property(_visual, "scale", _base_scale * 1.3, 0.1)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.12)
		&"statue":  # Or: turns into a golden statue, which then crumbles
			_model.stop()
			_model.tint(Color(1.0, 0.8, 0.25), 0.35)
			_tween.tween_interval(0.7)
			_tween.tween_callback(Effects.spray.bind(scene, chest, [Color(1.0, 0.8, 0.25), Color(0.8, 0.6, 0.15)], 40,
					Vector3.ONE * 0.16, Vector2(0.5, 2.0), Vector3(0, -9.0, 0), 120.0, 1.2))
			_tween.tween_property(_visual, "scale", _base_scale * Vector3(1, 0.01, 1), 0.25)
		&"confetti":  # Champion: a burst of confetti and a flash
			Effects.flash(scene, chest, _kill_color, 6.0, 0.4)
			Effects.spray(scene, chest, [_kill_color, Color(1.0, 0.85, 0.3), Color(0.16, 0.9, 1.0), Color.WHITE], 70,
					Vector3(0.12, 0.08, 0.01), Vector2(3.0, 6.0), Vector3(0, -3.0, 0), 70.0, 2.0)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.08)
		&"burst":  # a kamikaze's blast: explodes into a shower of pieces
			Effects.burst(scene, chest, _kill_color, 48)
			Effects.burst(scene, chest, Color.WHITE, 16)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.08)
		_:  # falls over, then shrinks away (bosses, melee kills)
			_model.play(&"die")
			_tween.tween_interval(DEATH_ANIMATION_TIME)
			_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.2)


func _scale_visual_to(target_scale: Vector3, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_visual, "scale", target_scale, duration)


func _drop_power_up() -> void:
	var power_up: PowerUp = power_up_scene.instantiate()
	power_up.type = PowerUp.Type.values().pick_random()
	power_up.position = global_position
	get_tree().current_scene.add_child(power_up)
