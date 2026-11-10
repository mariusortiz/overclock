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

const BOSS_EVERY := 5
const BOSS_ESCORT := 3

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var first_wave_delay := 2.0
@export var break_duration := 5.0
@export var spawn_interval := 0.8
@export var min_player_distance := 12.0

var wave := 0

var _to_spawn := 0
var _alive := 0
var _stopped := false
var _boss_pending := false
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


## Stops spawning for good (game over).
func stop() -> void:
	_stopped = true
	_spawn_timer.stop()


# --- Difficulty curve -------------------------------------------------------

func is_boss_wave() -> bool:
	return wave % BOSS_EVERY == 0


func _enemy_count() -> int:
	if is_boss_wave():
		return 1 + BOSS_ESCORT
	return 3 + 2 * (wave - 1)


func _max_alive() -> int:
	@warning_ignore("integer_division")
	return mini(3 + (wave - 1) / 2, 6)


func _configure(enemy: Enemy) -> void:
	# Each arena has its own kind of enemy.
	var arena := get_tree().get_first_node_in_group("arena") as Arena
	if arena and arena.enemy_model:
		enemy.model_scene = arena.enemy_model
	@warning_ignore("integer_division")
	enemy.max_health += (wave - 1) / 2
	enemy.move_speed *= minf(1.0 + 0.06 * (wave - 1), 1.5)
	enemy.fire_interval = maxf(enemy.fire_interval - 0.08 * (wave - 1), 0.9)


# --- Wave flow --------------------------------------------------------------

func _start_next_wave(delay: float) -> void:
	await get_tree().create_timer(delay, false).timeout
	if _stopped:
		return
	wave += 1
	_to_spawn = _enemy_count()
	_boss_pending = is_boss_wave()
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
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)
	_to_spawn -= 1
	_alive += 1
	if enemy is Boss:
		boss_spawned.emit(enemy)


## The bosses take turns, one per arena, and get tougher each time they come
## around.
func _create_boss() -> Boss:
	@warning_ignore("integer_division")
	var index := wave / BOSS_EVERY - 1
	var kinds := Boss.Kind.values()
	var boss: Boss = boss_scene.instantiate()
	@warning_ignore("integer_division")
	boss.configure(kinds[index % kinds.size()], 1.0 + 0.6 * (index / kinds.size()))
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
