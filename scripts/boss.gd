class_name Boss
extends Enemy
## Big monster of every fifth wave. Each kind replaces the robot's single shot
## with its own attack.

signal summon_requested(count: int)

enum Kind { COLOSSUS, BRUTE, ARTILLERY, SUMMONER }

const MODEL_DIR := "res://assets/models/quaternius/monsters/"
## "height" is the model's height before the boss scene doubles it, and
## "hover" how far it floats above the floor.
const INFO := {
	Kind.COLOSSUS: {"name": "DRAGON", "model": "Dragon.fbx", "height": 1.7, "hover": 0.5, "health": 60, "speed": 2.2, "fire_interval": 2.2, "range": 14.0},
	Kind.BRUTE: {"name": "SQUELETTE GÉANT", "model": "Skeleton.fbx", "height": 1.8, "hover": 0.0, "health": 50, "speed": 6.0, "fire_interval": 1.0, "range": 2.6},
	Kind.ARTILLERY: {"name": "CHAUVE-SOURIS GÉANTE", "model": "Bat.fbx", "height": 1.3, "hover": 0.9, "health": 55, "speed": 3.0, "fire_interval": 2.0, "range": 24.0},
	Kind.SUMMONER: {"name": "SLIME ROYAL", "model": "Slime.fbx", "height": 1.3, "hover": 0.0, "health": 70, "speed": 3.0, "fire_interval": 1.3, "range": 13.0},
}
const FAN_ANGLES_DEG: Array[float] = [-24.0, -12.0, 0.0, 12.0, 24.0]
const BRUTE_DAMAGE := 18
const SUMMON_INTERVAL := 9.0
const SUMMON_COUNT := 2
const SHIELD_OFF_TIME := 6.0
const SHIELD_ON_TIME := 3.0
const SHIELD_COLOR := Color(0.3, 0.6, 1.0, 0.3)

var kind := Kind.COLOSSUS

var _summon_left := SUMMON_INTERVAL
var _shield_left := SHIELD_OFF_TIME
var _shielded := false
var _shield: MeshInstance3D


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


func _ready() -> void:
	super()
	# Monsters fight bare-handed.
	$Visual/Gun.visible = false
	_aim_animation = &"idle"
	if kind == Kind.BRUTE:
		_attack_animation = &"melee"
	if kind == Kind.SUMMONER:
		_shield = _create_shield()


## Bosses are too heavy to be pushed around.
func knockback(_direction: Vector3, _strength: float) -> void:
	pass


func take_damage(amount: int) -> void:
	if not _shielded:
		super(amount)


func _physics_process(delta: float) -> void:
	super(delta)
	if kind != Kind.SUMMONER or _dead:
		return

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
			var forward := _muzzle.global_position.direction_to(_player.get_aim_position())
			for angle in FAN_ANGLES_DEG:
				_spawn_projectile(forward.rotated(Vector3.UP, deg_to_rad(angle)))
		Kind.BRUTE:
			if global_position.distance_to(_player.global_position) <= attack_range + 0.5:
				_player.take_damage(BRUTE_DAMAGE)
		Kind.ARTILLERY:
			var strike := MortarStrike.new()
			strike.position = _player.global_position
			get_tree().current_scene.add_child(strike)
		Kind.SUMMONER:
			super()


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
