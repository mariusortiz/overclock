class_name Boss
extends Enemy
## Big monster of every fifth wave. Each kind replaces the robot's single shot
## with its own attack.

signal summon_requested(count: int)
## The Léviathan wants its armor's cores around it (see WaveManager).
signal cores_requested(count: int)

## TITAN is the final boss, met in the last arena; VIRUS guards the Matrice,
## just before (it was added last, hence its place in the list: see ORDER).
## FROST, the Père Glaçon, only comes in the Christmas waves (see Events).
## GUARDIAN, the portal's guardian of season 3, guards the crystal planet.
## LEVIATHAN is the raid's boss (see Raid), in the abyss only.
## CUPID, the Cupidon de fer, only comes in the Valentine waves (see Events).
enum Kind { COLOSSUS, BRUTE, ARTILLERY, SUMMONER, TITAN, VIRUS, FROST, GUARDIAN, LEVIATHAN, CUPID }

## The bosses in the order of the arenas.
const ORDER: Array[Kind] = [Kind.COLOSSUS, Kind.BRUTE, Kind.ARTILLERY, Kind.SUMMONER, Kind.VIRUS, Kind.GUARDIAN, Kind.TITAN]

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
	Kind.GUARDIAN: {"name": "LE GARDIEN", "model": "characters/Wizard.fbx", "height": 3.0, "hover": 0.0, "health": 180, "speed": 2.4, "fire_interval": 1.5, "range": 20.0},
	Kind.LEVIATHAN: {"name": "LE LÉVIATHAN", "model": "monsters/Dragon.fbx", "height": 3.6, "hover": 1.2, "health": 420, "speed": 0.0, "fire_interval": 1.7, "range": 32.0},
	Kind.CUPID: {"name": "CUPIDON DE FER", "model": "mechs/George.fbx", "height": 2.3, "hover": 0.0, "health": 95, "speed": 3.2, "fire_interval": 1.3, "range": 20.0},
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
## The Gardien sings: a ring of crystal shards all around it, more often as it
## weakens; crystals burst out of the ground under the player from its second
## phase on, and sentinels come to its call in the third.
const GUARDIAN_SONG_INTERVAL := 7.0
const GUARDIAN_SONG_SHARDS := 14
const CRYSTAL_COLOR := Color(0.45, 0.85, 1.0)
## The Léviathan, in three phases: shielded while its four cores live (they
## have to be shot down first), then calling adds and a rain of strikes, and
## below LEVIATHAN_LASER_BELOW of its life a laser sweeping the floor around
## it (jump over it, or stay up on a platform).
## The Cupidon de fer: a fan of arrows, and every third shot a heart that
## charms the player (reversed controls) for CHARM_TIME.
const CUPID_COLOR := Color(1.0, 0.35, 0.6)
const CHARM_TIME := 2.0
const CHARM_RANGE := 26.0
const LEVIATHAN_CORES := 4
const LEVIATHAN_COLOR := Color(0.1, 0.95, 0.8)
const LEVIATHAN_LASER_BELOW := 0.4
const LEVIATHAN_LASER_LENGTH := 26.0
const LEVIATHAN_LASER_HEIGHT := 0.55
const LEVIATHAN_LASER_SPEED := 0.85
const LEVIATHAN_LASER_DAMAGE := 15
const LEVIATHAN_STRIKE_INTERVAL := 4.5
const LEVIATHAN_SUMMON_INTERVAL := 10.0

var kind := Kind.COLOSSUS

var _summon_left := SUMMON_INTERVAL
var _shield_left := SHIELD_OFF_TIME
var _shielded := false
var _shield: MeshInstance3D
var _shockwave_left := TITAN_SHOCKWAVE_INTERVAL
var _attack_count := 0
var _jump_left := VIRUS_JUMP_INTERVAL
var _song_left := GUARDIAN_SONG_INTERVAL
var _cores_called := false
var _strike_left := LEVIATHAN_STRIKE_INTERVAL
var _sweep_laser: Node3D
var _laser_hit_left := 0.0


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
	if kind == Kind.GUARDIAN:
		dress_guardian(_model)
	if kind == Kind.CUPID:
		_dress_titan()
		dress_cupid(_model)
	if kind == Kind.LEVIATHAN:
		dress_leviathan(_model)
		_shield = _create_shield()
		_shield.scale = Vector3.ONE * 2.2
		_shielded = true
		_shield.visible = true


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
		Kind.GUARDIAN:
			_update_guardian(delta)
		Kind.LEVIATHAN:
			_update_leviathan(delta)


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
		Kind.LEVIATHAN:
			_shoot_fan()
		Kind.CUPID:
			_attack_count += 1
			_shoot_fan()
			if _attack_count % 3 == 0 and _player and _player.global_position.distance_to(global_position) <= CHARM_RANGE:
				_player.charmed_left = CHARM_TIME
				Effects.burst(get_tree().current_scene, _player.global_position + Vector3.UP * 1.6, CUPID_COLOR, 30)
		Kind.GUARDIAN:
			_attack_count += 1
			_shoot_fan()
			if _phase() >= 2 and _attack_count % 2 == 0:
				_call_mortar(_player.global_position)
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


func _update_guardian(delta: float) -> void:
	var phase := _phase()
	_song_left -= delta
	if _song_left <= 0.0:
		_song_left = GUARDIAN_SONG_INTERVAL * (1.0 if phase == 1 else (0.75 if phase == 2 else 0.5))
		_sing()
	if phase == 3:
		_summon_left -= delta
		if _summon_left <= 0.0:
			_summon_left = SUMMON_INTERVAL
			summon_requested.emit(SUMMON_COUNT)


func _update_leviathan(delta: float) -> void:
	if not _cores_called:
		_cores_called = true
		cores_requested.emit(LEVIATHAN_CORES)
		return
	# Phase 1: the cores keep its shield up.
	var cores := get_tree().get_nodes_in_group("raid_cores").filter(func(core: Node) -> bool: return not core._dead)
	if not cores.is_empty():
		return
	if _shielded:
		_shielded = false
		_shield.visible = false
		Effects.flash(get_tree().current_scene, global_position + Vector3.UP * 3.0, LEVIATHAN_COLOR, 12.0, 0.8)
		_model.play(&"jump", true)
		_shoot_animation_left = 0.8
	# Phase 2 on: adds, and strikes raining around the player.
	_summon_left -= delta
	if _summon_left <= 0.0:
		_summon_left = LEVIATHAN_SUMMON_INTERVAL
		summon_requested.emit(SUMMON_COUNT)
	_strike_left -= delta
	if _strike_left <= 0.0 and _player:
		_strike_left = LEVIATHAN_STRIKE_INTERVAL
		for i in 3:
			var spread := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 5.0
			_call_mortar(_player.global_position + (spread if i > 0 else Vector3.ZERO))
	# Phase 3: the sweeping laser.
	if float(_health) / max_health < LEVIATHAN_LASER_BELOW:
		if _sweep_laser == null:
			_sweep_laser = _create_laser()
		_sweep_laser.rotate_y(LEVIATHAN_LASER_SPEED * delta)
		_laser_hit_left -= delta
		if _laser_hit_left <= 0.0 and _player and _laser_touches(_player.global_position):
			_laser_hit_left = 0.6
			_player.take_damage(LEVIATHAN_LASER_DAMAGE, global_position)


## Two beams across the floor, level with the shins, turning around the boss.
func _create_laser() -> Node3D:
	var pivot := Node3D.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.2, 0.3)
	var beam := BoxMesh.new()
	beam.size = Vector3(LEVIATHAN_LASER_LENGTH * 2.0, 0.18, 0.18)
	beam.material = material
	for angle in [0.0, PI / 2.0]:
		var part := MeshInstance3D.new()
		part.mesh = beam
		part.rotation.y = angle
		part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(part)
	pivot.top_level = true
	add_child(pivot)
	pivot.global_position = Vector3(global_position.x, global_position.y + LEVIATHAN_LASER_HEIGHT, global_position.z)
	Effects.flash(get_tree().current_scene, pivot.global_position, Color(1.0, 0.2, 0.3), 8.0, 0.5)
	return pivot


## Whether a point (a player's feet) is on one of the beams: near its line,
## and not above it (a jump, or a platform, clears it).
func _laser_touches(at: Vector3) -> bool:
	var local := _sweep_laser.global_transform.affine_inverse() * at
	if local.y > 0.1 or local.y < -1.5:
		return false
	var near_x := absf(local.z) < 0.6 and absf(local.x) < LEVIATHAN_LASER_LENGTH
	var near_z := absf(local.x) < 0.6 and absf(local.z) < LEVIATHAN_LASER_LENGTH
	return near_x or near_z


## Pink and white iron, two white wings on its back and a pink glow: the
## Cupidon de fer's look (the boss, its card).
static func dress_cupid(model: Node3D) -> void:
	var body := StandardMaterial3D.new()
	body.albedo_color = Color(1.0, 0.62, 0.75)
	body.albedo_texture = load(TITAN_TEXTURE)
	body.metallic = 0.6
	body.roughness = 0.3
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(CUPID_COLOR, 0.15)
	var bounds := AABB()
	var first := true
	var to_model := model.global_transform.affine_inverse() if model.is_inside_tree() else Transform3D.IDENTITY
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = body
		mesh.material_overlay = glow
		# Its bounds in the model's own space (the meshes of an FBX may be turned).
		var box: AABB = (to_model * mesh.global_transform) * mesh.get_aabb() if mesh.is_inside_tree() else mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	var wing_material := StandardMaterial3D.new()
	wing_material.albedo_color = Color(1.0, 0.97, 0.98)
	wing_material.emission_enabled = true
	wing_material.emission = Color(1.0, 0.8, 0.9)
	wing_material.emission_energy_multiplier = 0.3
	var height := bounds.size.y
	for side in [-1.0, 1.0]:
		var wing := BoxMesh.new()
		wing.size = Vector3(height * 0.32, height * 0.2, height * 0.03)
		wing.material = wing_material
		var part := MeshInstance3D.new()
		part.mesh = wing
		part.position = Vector3(side * height * 0.2, bounds.position.y + height * 0.7, bounds.get_center().z - height * 0.18)
		part.rotation = Vector3(0, side * 0.5, side * 0.35)
		model.add_child(part)


## Deep-sea colors and a glow of teal: the Léviathan's look (the boss, its
## card, the trailer).
static func dress_leviathan(model: Node3D) -> void:
	var body := StandardMaterial3D.new()
	body.albedo_color = Color(0.08, 0.2, 0.28)
	body.metallic = 0.4
	body.roughness = 0.35
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(LEVIATHAN_COLOR, 0.18)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = body
		mesh.material_overlay = glow


## The song: shards fly out all around, level with the player's chest.
func _sing() -> void:
	Effects.burst(get_tree().current_scene, global_position + Vector3.UP * 3.0, CRYSTAL_COLOR, 40)
	_model.play(&"shoot", true)
	_shoot_animation_left = 0.6
	var offset := randf() * TAU
	for i in GUARDIAN_SONG_SHARDS:
		var angle := offset + TAU * i / GUARDIAN_SONG_SHARDS
		_spawn_projectile(Vector3(cos(angle), 0.0, sin(angle)))


## Glowing crystal all over: the Gardien's look, here and on its card and in
## the trailer.
static func dress_guardian(model: Node3D) -> void:
	var crystal := StandardMaterial3D.new()
	crystal.albedo_color = Color(0.55, 0.8, 1.0, 0.85)
	crystal.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal.metallic = 0.5
	crystal.roughness = 0.08
	crystal.emission_enabled = true
	crystal.emission = Color(0.5, 0.6, 1.0)
	crystal.emission_energy_multiplier = 0.6
	var shine := StandardMaterial3D.new()
	shine.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shine.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	shine.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shine.albedo_color = Color(0.95, 0.45, 1.0, 0.18)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = crystal
		mesh.material_overlay = shine
	# A crown of shards turning above its head, placed once it stands.
	for i in 2:
		await model.get_tree().process_frame
	if not is_instance_valid(model):
		return
	var bounds := AABB()
	var first := true
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var box := mesh.global_transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	var crown := Node3D.new()
	model.add_child(crown)
	crown.global_position = Vector3(bounds.get_center().x, bounds.end.y + bounds.size.y * 0.08, bounds.get_center().z)
	var size := bounds.size.y
	for i in 8:
		var shard := _part(PrismMesh.new(), crystal)
		(shard.mesh as PrismMesh).size = Vector3(size * 0.04, size * 0.11, size * 0.04)
		crown.add_child(shard)
		var angle := TAU * i / 8.0
		shard.global_position = crown.global_position + Vector3(cos(angle), 0, sin(angle)) * size * 0.16
	var turn := crown.create_tween().set_loops()
	turn.tween_property(crown, "rotation:y", TAU, 6.0).from(0.0)


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
	dress_frost(_model)


## The Père Glaçon's look on any model of the skeleton (the boss, its card,
## the trailer): ice all over, a red bonnet with a white pompom, and a big
## white beard with a moustache. The bonnet and the beard follow the head;
## they are placed once the model stands in its first pose, sized from its
## height, in front of its face (a CharacterModel looks along -Z).
static func dress_frost(model: Node3D) -> void:
	var ice := StandardMaterial3D.new()
	ice.albedo_color = Color(0.75, 0.9, 1.0)
	ice.metallic = 0.3
	ice.roughness = 0.15
	ice.emission_enabled = true
	ice.emission = Color(0.4, 0.7, 1.0)
	ice.emission_energy_multiplier = 0.25
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = ice
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false)
	if skeleton == null or skeleton.find_bone("Head") == -1:
		return
	var head := BoneAttachment3D.new()
	head.bone_name = "Head"
	skeleton.add_child(head)
	for i in 3:
		await model.get_tree().process_frame
	if not is_instance_valid(head):
		return
	var bounds := AABB()
	var first := true
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var box := mesh.global_transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	# About the radius of the skull, whose middle is a little above the head bone.
	var r := bounds.size.y * 0.11
	var facing := model.global_basis.orthonormalized()
	var up := facing.y
	# The skeleton's face is on the model's +Z side.
	var front := facing.z
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.98, 1.0)
	white.roughness = 0.9
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.85, 0.08, 0.1)
	var top := head.global_position + up * r * 1.1
	# The bonnet, leaning back a little, its pompom at the tip.
	var bonnet := _part(CylinderMesh.new(), red)
	(bonnet.mesh as CylinderMesh).top_radius = 0.0
	(bonnet.mesh as CylinderMesh).bottom_radius = r * 1.15
	(bonnet.mesh as CylinderMesh).height = r * 2.2
	_attach(head, bonnet, top + up * r * 1.6 - front * r * 0.2, facing.rotated(facing.x, -0.35))
	var pompom := _part(SphereMesh.new(), white)
	(pompom.mesh as SphereMesh).radius = r * 0.32
	(pompom.mesh as SphereMesh).height = r * 0.64
	_attach(head, pompom, top + up * r * 2.65 - front * r * 0.6, facing)
	var brim := _part(CylinderMesh.new(), white)
	(brim.mesh as CylinderMesh).top_radius = r * 1.25
	(brim.mesh as CylinderMesh).bottom_radius = r * 1.25
	(brim.mesh as CylinderMesh).height = r * 0.35
	_attach(head, brim, top + up * r * 0.6 - front * r * 0.05, facing)
	# The beard: a long rounded point under the jaw, puffs along the cheeks.
	var beard := _part(CylinderMesh.new(), white)
	(beard.mesh as CylinderMesh).top_radius = r * 0.95
	(beard.mesh as CylinderMesh).bottom_radius = r * 0.12
	(beard.mesh as CylinderMesh).height = r * 2.2
	_attach(head, beard, top - up * r * 1.85 + front * r * 0.75, facing.rotated(facing.x, -0.25))
	for side in [-1.0, 0.0, 1.0]:
		var puff := _part(SphereMesh.new(), white)
		(puff.mesh as SphereMesh).radius = r * 0.5
		(puff.mesh as SphereMesh).height = r * 1.0
		_attach(head, puff, top - up * r * 1.05 + front * r * 0.8 + facing.x * side * r * 0.7, facing)
	# The moustache: two curls under the nose.
	for side in [-1.0, 1.0]:
		var curl := _part(CapsuleMesh.new(), white)
		(curl.mesh as CapsuleMesh).radius = r * 0.2
		(curl.mesh as CapsuleMesh).height = r * 1.0
		_attach(head, curl, top - up * r * 0.65 + front * r * 1.1 + facing.x * side * r * 0.42,
				facing.rotated(front, side * 1.2))


static func _part(mesh: Mesh, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	return part


## Puts `part` under the head at `at`, turned by `basis` (world space, unscaled).
static func _attach(head: Node3D, part: Node3D, at: Vector3, basis: Basis) -> void:
	head.add_child(part)
	part.global_transform = Transform3D(basis, at)


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
	if _sweep_laser:
		_sweep_laser.queue_free()
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
