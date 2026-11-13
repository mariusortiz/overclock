class_name WaveManager
extends Node
## Runs the waves: spawns robots at the "enemy_spawns" points, away from the
## player, and makes each wave bigger and tougher than the last.

signal wave_started(number: int)
signal wave_cleared(number: int)
signal enemy_killed
signal enemies_left_changed(count: int)
signal boss_spawned(boss: Boss)
signal boss_killed(kind: Boss.Kind)
signal elite_spawned
## The last seconds before a wave: 3, 2, 1.
signal countdown(seconds: int)
signal elite_killed
## A new enemy is in the arena (co-op: the host tells the others).
signal enemy_spawned(enemy: Enemy)

const BOSS_EVERY := 5
const BOSS_ESCORT := 3
## Flying enemies join from this wave on, as this share of the spawns.
const FLYING_FROM_WAVE := 3
const FLYING_CHANCE := 0.25
const FLYING_SPAWN_HEIGHT := 6.0
const FLYING_MODEL := preload("res://assets/models/quaternius/monsters/Bat.fbx")
## One elite per wave from this wave on (not in boss waves).
const ELITE_FROM_WAVE := 2
## Snipers and kamikazes join from these waves, as these shares of the spawns.
const SNIPER_FROM_WAVE := 4
const SNIPER_CHANCE := 0.15
const SNIPER_RANGE := 32.0
const SNIPER_INTERVAL := 3.2
const KAMIKAZE_FROM_WAVE := 6
const KAMIKAZE_CHANCE := 0.12
const KAMIKAZE_SPEED := 1.8

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var first_wave_delay := 2.0
@export var break_duration := 5.0
@export var spawn_interval := 0.8
@export var min_player_distance := 12.0

var wave := 0
## The only boss to come, or -1 for the usual round (Boss.ORDER): the
## Christmas waves have the Père Glaçon only.
var boss_kind := -1
## Fixed health scale for the bosses (a story mission's: as met the first
## time); 0 lets it grow each time the bosses come around.
var boss_health_scale := 0.0
## Players in a co-op game: more enemies, and tougher, for each one more.
var coop_players := 1

var _to_spawn := 0
var _alive := 0
var _stopped := false
var _boss_pending := false
var _elite_pending := false
var _spawn_timer := Timer.new()


func _ready() -> void:
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	# Test option: "-- --start-wave=5" on the command line starts at that wave.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--start-wave="):
			wave = maxi(argument.get_slice("=", 1).to_int() - 1, 0)
	_start_next_wave(first_wave_delay)


## Test helper: the next wave will be a boss wave.
func skip_to_next_boss() -> void:
	@warning_ignore("integer_division")
	wave = (wave / BOSS_EVERY + 1) * BOSS_EVERY - 1


## Stops spawning (game over, or the pause after the Titan).
func stop() -> void:
	_stopped = true
	_spawn_timer.stop()


## Starts again after stop(), with the next wave (endless mode).
func resume() -> void:
	_stopped = false
	_to_spawn = 0
	_alive = 0
	_boss_pending = false
	_start_next_wave(break_duration)


# --- Difficulty curve -------------------------------------------------------

func is_boss_wave() -> bool:
	return wave % BOSS_EVERY == 0


func _enemy_count() -> int:
	if is_boss_wave():
		return 1 + BOSS_ESCORT * coop_players
	return roundi((3 + 2 * (wave - 1)) * (1.0 + 0.5 * (coop_players - 1)))


func _max_alive() -> int:
	@warning_ignore("integer_division")
	return mini(3 + (wave - 1) / 2, 6) + 2 * (coop_players - 1)


func _configure(enemy: Enemy) -> void:
	# Each arena has its own kind of enemy.
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena and arena.enemy_model:
		enemy.model_scene = arena.enemy_model
		enemy.weapon_id = arena.enemy_weapon
	if wave >= FLYING_FROM_WAVE and not is_boss_wave() and randf() < FLYING_CHANCE:
		_make_flying(enemy)
	elif not is_boss_wave():
		var roll := randf()
		if wave >= KAMIKAZE_FROM_WAVE and roll < KAMIKAZE_CHANCE:
			_make_kamikaze(enemy)
		elif wave >= SNIPER_FROM_WAVE and roll < KAMIKAZE_CHANCE + SNIPER_CHANCE:
			_make_sniper(enemy)
	# The elite comes at a random point of the wave, at the latest last.
	if _elite_pending and randf() * _to_spawn < 1.0:
		_elite_pending = false
		enemy.elite = true
	@warning_ignore("integer_division")
	enemy.max_health += (wave - 1) / 2
	enemy.move_speed *= minf(1.0 + 0.06 * (wave - 1), 1.5)
	enemy.fire_interval = maxf(enemy.fire_interval - 0.08 * (wave - 1), 0.9)


## Keeps its distance and takes aim with a laser before each shot.
func _make_sniper(enemy: Enemy) -> void:
	enemy.role = &"sniper"
	enemy.weapon_id = "sniper"
	enemy.melee_damage = 0
	enemy.attack_range = SNIPER_RANGE
	enemy.fire_interval = SNIPER_INTERVAL


## Fragile and fast, glowing red: blows up on contact.
func _make_kamikaze(enemy: Enemy) -> void:
	enemy.role = &"kamikaze"
	enemy.weapon_id = ""
	enemy.melee_damage = 1  # the blast does the damage (see Enemy._blow_up)
	enemy.max_health = 3
	enemy.move_speed *= KAMIKAZE_SPEED


## Turns a regular enemy into a small bat that hovers and spits.
func _make_flying(enemy: Enemy) -> void:
	enemy.flying = true
	enemy.model_scene = FLYING_MODEL
	enemy.model_height = 1.0
	enemy.model_hover = 0.4
	enemy.weapon_id = "blaster"
	enemy.max_health = maxi(enemy.max_health - 2, 2)
	enemy.move_speed *= 1.3


# --- Wave flow --------------------------------------------------------------

func _start_next_wave(delay: float) -> void:
	var counted := 3 if delay >= 3.5 else 0
	await get_tree().create_timer(delay - counted, false).timeout
	for seconds in range(counted, 0, -1):
		if _stopped:
			return
		countdown.emit(seconds)
		await get_tree().create_timer(1.0, false).timeout
	if _stopped:
		return
	wave += 1
	_to_spawn = _enemy_count()
	_boss_pending = is_boss_wave()
	_elite_pending = wave >= ELITE_FROM_WAVE and not is_boss_wave()
	wave_started.emit(wave)
	enemies_left_changed.emit(_to_spawn)
	_spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	if _to_spawn > 0 and _alive < _max_alive():
		_spawn()


func _spawn() -> void:
	var points := get_tree().get_nodes_in_group("enemy_spawns")
	var player: Node3D = get_tree().get_first_node_in_group("player")
	var far_points := points.filter(func(point: Node3D) -> bool:
		return point.global_position.distance_to(player.global_position) >= min_player_distance)
	var point: Node3D = (far_points if not far_points.is_empty() else points).pick_random()

	var enemy: Enemy
	if _boss_pending:
		_boss_pending = false
		enemy = _create_boss()
	else:
		enemy = enemy_scene.instantiate()
		_configure(enemy)
	enemy.position = point.global_position
	if enemy is Boss:
		enemy.position = _arena_center()
	if enemy.flying:
		enemy.position.y += FLYING_SPAWN_HEIGHT
	enemy.died.connect(_on_enemy_died)
	if enemy.elite:
		enemy.died.connect(elite_killed.emit)
	if coop_players > 1:
		enemy.max_health = roundi(enemy.max_health * (1.0 + 0.3 * (coop_players - 1)))
	get_parent().add_child(enemy)
	enemy_spawned.emit(enemy)
	# A flash where it appears.
	var flash_color := Color(1.0, 0.5, 0.15) if enemy is Boss else Color(0.16, 0.9, 1.0)
	Effects.spray(get_parent(), enemy.position + Vector3.UP * 0.6, [flash_color, Color.WHITE], 22,
			Vector3.ONE * 0.1, Vector2(1.0, 3.0), Vector3(0, 2.0, 0), 35.0, 0.8, true)
	Effects.flash(get_parent(), enemy.position + Vector3.UP, flash_color, 3.0, 0.35)
	if enemy.elite:
		elite_spawned.emit()
	_to_spawn -= 1
	_alive += 1
	if enemy is Boss:
		boss_spawned.emit(enemy)


## Where the boss appears: the arena's boss spawn, on the floor in the open.
func _arena_center() -> Vector3:
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	return arena.boss_spawn_position() if arena else Vector3(0, 0.1, 0)


## The bosses take turns, one per arena (Boss.ORDER), and get tougher each
## time they come around.
func _create_boss() -> Boss:
	@warning_ignore("integer_division")
	var index := wave / BOSS_EVERY - 1
	var kinds: Array = Boss.ORDER if boss_kind < 0 else [boss_kind]
	var boss: Boss = boss_scene.instantiate()
	@warning_ignore("integer_division")
	var health_scale := boss_health_scale if boss_health_scale > 0.0 else 1.0 + 0.6 * (index / kinds.size())
	boss.configure(kinds[index % kinds.size()], health_scale)
	boss.summon_requested.connect(_on_boss_summon_requested)
	boss.died.connect(boss_killed.emit.bind(boss.kind))
	return boss


func _on_boss_summon_requested(count: int) -> void:
	_to_spawn += count
	enemies_left_changed.emit(_to_spawn + _alive)


func _on_enemy_died() -> void:
	_alive -= 1
	enemy_killed.emit()
	enemies_left_changed.emit(_to_spawn + _alive)
	if _to_spawn == 0 and _alive == 0:
		_spawn_timer.stop()
		wave_cleared.emit(wave)
		_start_next_wave(break_duration)
