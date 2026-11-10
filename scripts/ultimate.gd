class_name Ultimate
extends Node
## The character's ultimate ability. It charges with kills (and slowly over
## time), then the "ultimate" action triggers it. Each character has its own.

signal charge_changed(ratio: float)
signal activated(ultimate_name: String)

const KILL_CHARGE := 0.1
## Charge per second without killing anything.
const PASSIVE_CHARGE := 1.0 / 120.0
const ROCKET_SCENE := preload("res://scenes/rocket.tscn")
const COLOR := Color(1.0, 0.85, 0.2)

## What each ultimate is called and does (shown in the armory). The keys are
## the "ulti" of Loadout.CHARACTERS.
const INFO := {
	&"airstrike": {"name": "Frappe aérienne", "text": "Bombarde les 5 ennemis les plus proches"},
	&"deadeye": {"name": "Duel", "text": "Tire d'un coup sur les 6 ennemis les plus proches"},
	&"overdrive": {"name": "Surrégime", "text": "8 s de tir deux fois plus rapide, sans recharger"},
	&"clones": {"name": "Clones", "text": "Deux clones se battent à tes côtés pendant 12 s"},
	&"broadside": {"name": "Bordée", "text": "Tire 8 roquettes tout autour de toi"},
	&"rampart": {"name": "Rempart", "text": "Invulnérable pendant 6 s"},
	&"whirlwind": {"name": "Tourbillon", "text": "Tranche tous les ennemis à moins de 5 m"},
	&"rage": {"name": "Rage", "text": "Soin, puissance et vitesse"},
	&"arrows": {"name": "Volée de flèches", "text": "Touche tous les ennemis de l'arène"},
	&"dynamite": {"name": "Dynamite", "text": "Explosion de 9 m qui repousse les ennemis"},
	&"curse": {"name": "Malédiction", "text": "Tous les ennemis brûlent et sont ralentis"},
	&"timestop": {"name": "Arrêt du temps", "text": "Fige tous les ennemis pendant 5 s"},
	&"blessing": {"name": "Bénédiction", "text": "Soin complet, bouclier et régénération"},
}

var charge := 0.0
## True while the player cannot be hurt (Rempart).
var shielded := false

var _player: Player
var _kind := &""
## Seconds left of a timed ultimate.
var _time_left := 0.0


func setup(player: Player, kind: StringName) -> void:
	_player = player
	_kind = kind


func add_charge(amount: float) -> void:
	charge = minf(charge + amount, 1.0)
	charge_changed.emit(charge)


func _physics_process(delta: float) -> void:
	if _time_left > 0.0:
		_time_left -= delta
		if _time_left <= 0.0:
			_end()
	elif charge < 1.0:
		add_charge(PASSIVE_CHARGE * delta)
	if Input.is_action_just_pressed("ultimate") and charge >= 1.0 and _player.health > 0:
		_activate()


func _activate() -> void:
	charge = 0.0
	charge_changed.emit(charge)
	activated.emit(INFO[_kind].name)
	var scene := get_tree().current_scene
	var center := _player.get_aim_position()
	Effects.burst(scene, center, COLOR, 30)
	match _kind:
		&"airstrike":
			var targets := _nearest(5)
			for i in targets.size():
				var at: Vector3 = targets[i].global_position
				get_tree().create_timer(0.4 + 0.25 * i, false).timeout.connect(_blast.bind(at, 4.0, 10))
		&"deadeye":
			for enemy in _nearest(6):
				Effects.tracer(scene, center, enemy.get_aim_position(), COLOR)
				_hit(enemy, 12)
		&"overdrive":
			_player.weapon.overdrive = true
			_time_left = 8.0
		&"clones":
			for side: float in [-1.0, 1.0]:
				var clone := Clone.new()
				clone.player = _player
				clone.offset = Vector3(side * 2.0, 0, 0.5)
				clone.position = _player.global_position
				scene.add_child(clone)
		&"broadside":
			for i in 8:
				var rocket: Rocket = ROCKET_SCENE.instantiate()
				rocket.direction = Vector3.FORWARD.rotated(Vector3.UP, TAU * i / 8.0)
				rocket.position = center + rocket.direction
				rocket.exploded.connect(_blast.bind(4.0, 10))
				scene.add_child(rocket)
		&"rampart":
			shielded = true
			_time_left = 6.0
		&"whirlwind":
			_blast(center, 5.0, 30)
		&"rage":
			_player.heal(30)
			_player.apply_power_up(PowerUp.Type.POWER)
			_player.apply_power_up(PowerUp.Type.SPEED)
		&"arrows":
			for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
				var target: Vector3 = enemy.get_aim_position()
				Effects.tracer(scene, target + Vector3(0, 20, 0), target, COLOR)
				_hit(enemy, 8)
		&"dynamite":
			for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
				var away := enemy.global_position - _player.global_position
				if away.length() <= 9.0:
					enemy.knockback(away.normalized(), 14.0)
			_blast(center, 9.0, 12)
		&"curse":
			for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
				enemy.ignite(2)
				enemy.chill(3)
		&"timestop":
			for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
				enemy.stun(5.0)
		&"blessing":
			_player.heal(_player.max_health)
			_player.apply_power_up(PowerUp.Type.SHIELD)
			_player.apply_power_up(PowerUp.Type.REGEN)


func _end() -> void:
	shielded = false
	_player.weapon.overdrive = false


## The `count` enemies closest to the player.
func _nearest(count: int) -> Array:
	var enemies := get_tree().get_nodes_in_group("targets")
	var origin := _player.global_position
	enemies.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))
	return enemies.slice(0, count)


## Explosion hurting every enemy within `radius` of `at`.
func _blast(at: Vector3, radius: float, damage: int) -> void:
	Effects.burst(get_tree().current_scene, at, COLOR, 40)
	for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
		if at.distance_to(enemy.get_aim_position()) <= radius:
			_hit(enemy, damage)


func _hit(enemy: Node3D, damage: int) -> void:
	_player.weapon.tag_kill(enemy)
	enemy.take_damage(damage)
