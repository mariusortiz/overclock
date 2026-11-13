class_name Boss
extends Enemy
## Big monster of every fifth wave. Each kind replaces the robot's single shot
## with its own attack.

signal summon_requested(count: int)

## TITAN is the final boss, met in the last arena; VIRUS guards the Matrice,
## just before (it was added last, hence its place in the list: see ORDER).
## FROST, the Père Glaçon, only comes in the Christmas waves (see Events).
enum Kind { COLOSSUS, BRUTE, ARTILLERY, SUMMONER, TITAN, VIRUS, FROST }

## The bosses in the order of the arenas.
const ORDER: Array[Kind] = [Kind.COLOSSUS, Kind.BRUTE, Kind.ARTILLERY, Kind.SUMMONER, Kind.VIRUS, Kind.TITAN]

const MODEL_DIR := "res://assets/models/quaternius/"
## "height" is the model's height before the boss scene doubles it, and
## "hover" how far it floats above the floor.
const INFO := {
	Kind.COLOSSUS: {"name": "DRAGON", "model": "monsters/Dragon.fbx", "height": 1.7, "hover": 0.5, "health": 60, "speed": 2.2, "fire_interval": 2.2, "range": 14.0},
	Kind.BRUTE: {"name": "SQUELETTE GÉANT", "model": "monsters/Skeleton.fbx", "height": 1.8, "hover": 0.0, "health": 50, "speed": 6.0, "fire_interval": 1.0, "range": 2.6},
	Kind.ARTILLERY: {"name": "CHAUVE-SOURIS GÉANTE", "model": "monsters/Bat.fbx", "height": 1.3, "hover": 0.9, "health": 55, "speed": 3.0, "fire_interval": 2.0, "range": 24.0},
	Kind.SUMMONER: {"name": "SLIME ROYAL", "model": "monsters/Slime.fbx", "height": 1.3, "hover": 0.0, "health": 70, "speed": 3.0, "fire_interval": 1.3, "range": 13.0},
	Kind.TITAN: {"name": "TITAN", "model": "mechs/George.fbx", "height": 2.6, "hover": 0.0, "health": 220, "speed": 2.6, "fire_interval": 1.7, "range": 20.0},
	Kind.FROST: {"name": "PÈRE GLAÇON", "model": "monsters/Skeleton.fbx", "height": 2.2, "hover": 0.0, "health": 90, "speed": 3.4, "fire_interval": 1.3, "range": 16.0},
	Kind.VIRUS: {"name": "LE VIRUS", "model": "mechs/George.fbx", "height": 2.3, "hover": 0.0, "health": 150, "speed": 3.2, "fire_interval": 1.2, "range": 18.0},
}
## The Virus jumps next to the player now and then (more often when hurt),
## and copies itself (corrupted enemies) from its second phase on.
const VIRUS_JUMP_INTERVAL := 5.0
const FAN_ANGLES_DEG: Array[float] = [-24.0, -12.0, 0.0, 12.0, 24.0]
const BRUTE_DAMAGE := 18
const SUMMON_INTERVAL := 9.0
const SUMMON_COUNT := 2
const SHIELD_OFF_TIME := 6.0
const SHIELD_ON_TIME := 3.0
const SHIELD_COLOR := Color(0.3, 0.6, 1.0, 0.3)
const TITAN_TEXTURE := "res://assets/models/quaternius/mechs/George_Texture.jpg"
const TITAN_SUMMON_INTERVAL := 11.0
const TITAN_SHOCKWAVE_INTERVAL := 6.0
const TITAN_MORTAR_SPREAD := 5.0

var kind := Kind.COLOSSUS

var _summon_left := SUMMON_INTERVAL
var _shield_left := SHIELD_OFF_TIME
var _shielded := false
var _shield: MeshInstance3D
var _shockwave_left := TITAN_SHOCKWAVE_INTERVAL
var _attack_count := 0
var _jump_left := VIRUS_JUMP_INTERVAL


## Call before adding the boss to the scene. `health_scale` grows each time
## the four bosses come around again.
func configure(boss_kind: Kind, health_scale: float) -> void:
	kind = boss_kind
	var info: Dictionary = INFO[kind]
	max_health = roundi(info.health * health_scale)
	move_speed = info.speed
	fire_interval = info.fire_interval
	attack_range = info.range
	model_scene = load(MODEL_DIR + info.model)
	model_height = info.height
	model_hover = info.hover
	drop_chance = 1.0
	weapon_id = "blaster"  # hidden: monsters fight bare-handed
	if kind == Kind.BRUTE:
		melee_damage = BRUTE_DAMAGE
	kill_effects_enabled = false


func _ready() -> void:
	super()
	# Monsters fight bare-handed.
	$Visual/Gun.visible = false
	_aim_animation = &"idle"
	if kind == Kind.BRUTE:
		_attack_animation = &"melee"
	if kind == Kind.SUMMONER:
		_shield = _create_shield()
	if kind == Kind.TITAN:
		_dress_titan()
	if kind == Kind.VIRUS:
		_dress_virus()
	if kind == Kind.FROST:
		_dress_frost()


## Bosses are too heavy to be pushed around.
## Bosses shake off a stun faster.
func stun(seconds: float) -> void:
	super(seconds * 0.4)


func knockback(_direction: Vector3, _strength: float) -> void:
	pass


func take_damage(amount: int, from := Vector3.INF) -> void:
	if not _shielded:
		super(amount, from)


func _physics_process(delta: float) -> void:
	super(delta)
	if _dead:
		return
	match kind:
		Kind.SUMMONER:
			_update_summoner(delta)
		Kind.TITAN:
			_update_titan(delta)
		Kind.VIRUS:
			_update_virus(delta)


func _update_summoner(delta: float) -> void:
	_summon_left -= delta
	if _summon_left <= 0.0:
		_summon_left = SUMMON_INTERVAL
		summon_requested.emit(SUMMON_COUNT)

	_shield_left -= delta
	if _shield_left <= 0.0:
		_shielded = not _shielded
		_shield_left = SHIELD_ON_TIME if _shielded else SHIELD_OFF_TIME
		_shield.visible = _shielded


func _attack() -> void:
	match kind:
		Kind.COLOSSUS:
			_shoot_fan()
		Kind.BRUTE:
			super()
		Kind.ARTILLERY:
			_call_mortar(_player.global_position)
		Kind.SUMMONER:
			super()
		Kind.FROST:
			# A gust of icy shards, and icicles falling around the player.
			_attack_count += 1
			_shoot_fan()
			if _attack_count % 2 == 0:
				for i in 2 if _phase() == 1 else 4:
					var spread := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 4.0
					_call_mortar(_player.global_position + (spread if i > 0 else Vector3.ZERO))
		Kind.VIRUS:
			_attack_count += 1
			_shoot_fan()
			if _phase() == 3 and _attack_count % 3 == 0:
				_call_mortar(_player.global_position)
		Kind.TITAN:
			_attack_count += 1
			_shoot_fan()
			# From the second phase on, every other attack also shells the area.
			if _phase() >= 2 and _attack_count % 2 == 0:
				for i in 3:
					var spread := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * TITAN_MORTAR_SPREAD
					_call_mortar(_player.global_position + (spread if i > 0 else Vector3.ZERO))


func _shoot_fan() -> void:
	var forward := _muzzle.global_position.direction_to(_player.get_aim_position())
	for angle in FAN_ANGLES_DEG:
		_spawn_projectile(forward.rotated(Vector3.UP, deg_to_rad(angle)))


func _call_mortar(at: Vector3) -> void:
	var strike := MortarStrike.new()
	strike.position = at
	get_tree().current_scene.add_child(strike)


## The Titan fights in three phases, as its health drops by thirds.
func _phase() -> int:
	var left := float(_health) / max_health
	return 1 if left > 0.66 else (2 if left > 0.33 else 3)


func _update_titan(delta: float) -> void:
	var phase := _phase()
	if phase >= 2:
		_summon_left -= delta
		if _summon_left <= 0.0:
			_summon_left = TITAN_SUMMON_INTERVAL
			summon_requested.emit(SUMMON_COUNT)
	if phase == 3:
		_shockwave_left -= delta
		if _shockwave_left <= 0.0:
			_shockwave_left = TITAN_SHOCKWAVE_INTERVAL
			var wave := Shockwave.new()
			wave.position = global_position
			get_tree().current_scene.add_child(wave)
			_model.play(&"jump", true)
			_shoot_animation_left = 0.8


func _update_virus(delta: float) -> void:
	var phase := _phase()
	_jump_left -= delta
	if _jump_left <= 0.0:
		_jump_left = VIRUS_JUMP_INTERVAL * (1.0 if phase == 1 else 0.65)
		_glitch_jump()
	if phase >= 2:
		_summon_left -= delta
		if _summon_left <= 0.0:
			_summon_left = SUMMON_INTERVAL
			summon_requested.emit(SUMMON_COUNT)


## Vanishes in a burst of green and comes back somewhere near the player.
func _glitch_jump() -> void:
	if _player == null:
		return
	var scene := get_tree().current_scene
	Effects.burst(scene, global_position + Vector3.UP * 2.0, VIRUS_COLOR, 40)
	var angle := randf() * TAU
	var wanted := _player.global_position + Vector3(cos(angle), 0, sin(angle)) * randf_range(7.0, 10.0)
	var landing := NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, wanted)
	if landing.distance_to(wanted) < 4.0:
		global_position = landing
	Effects.burst(scene, global_position + Vector3.UP * 2.0, VIRUS_COLOR, 40)
	var tween := create_tween()
	for i in 4:
		tween.tween_callback(func() -> void: _visual.visible = i % 2 == 1)
		tween.tween_interval(0.08)
	tween.tween_callback(func() -> void: _visual.visible = true)


## The giant skeleton turned to ice, a red bonnet on its head.
func _dress_frost() -> void:
	var ice := StandardMaterial3D.new()
	ice.albedo_color = Color(0.75, 0.9, 1.0)
	ice.metallic = 0.3
	ice.roughness = 0.15
	ice.emission_enabled = true
	ice.emission = Color(0.4, 0.7, 1.0)
	ice.emission_energy_multiplier = 0.25
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = ice
	var bonnet := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.45
	cone.height = 0.9
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.85, 0.08, 0.1)
	cone.material = red
	bonnet.mesh = cone
	var pompom := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.14
	ball.height = 0.28
	var white := StandardMaterial3D.new()
	white.albedo_color = Color.WHITE
	ball.material = white
	pompom.mesh = ball
	pompom.position.y = 0.48
	bonnet.add_child(pompom)
	var head := BoneAttachment3D.new()
	var skeleton: Skeleton3D = _model.find_child("Skeleton3D", true, false)
	if skeleton and skeleton.find_bone("Head") != -1:
		head.bone_name = "Head"
		skeleton.add_child(head)
		head.add_child(bonnet)
		bonnet.position.y = 0.35
		# The skeleton's own scale: the bonnet keeps its size in meters.
		bonnet.scale = Vector3.ONE / maxf(skeleton.global_basis.get_scale().x, 0.001)


## The Titan's body, black, with a green glow: the Virus in a body.
func _dress_virus() -> void:
	_dress_titan()
	var body := StandardMaterial3D.new()
	body.albedo_color = Color(0.08, 0.12, 0.09)
	body.albedo_texture = load(TITAN_TEXTURE)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(VIRUS_COLOR, 0.3)
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = body
		mesh.material_overlay = glow


## The mech's texture is a separate file, and it needs a body as big as it looks.
func _dress_titan() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(TITAN_TEXTURE)
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = material
	var shape := CapsuleShape3D.new()
	shape.radius = 1.3
	shape.height = 5.0
	var collision: CollisionShape3D = $CollisionShape3D
	collision.shape = shape
	collision.position.y = 2.5


func _die() -> void:
	if _shield:
		_shield.visible = false
	super()


func _create_shield() -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = SHIELD_COLOR
	var mesh := SphereMesh.new()
	mesh.radius = 2.4
	mesh.height = 4.8
	mesh.material = material
	var shield := MeshInstance3D.new()
	shield.mesh = mesh
	shield.position.y = aim_height
	shield.visible = false
	add_child(shield)
	return shield
