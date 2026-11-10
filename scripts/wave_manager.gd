class_name WaveManager
extends Node
## Runs the waves: spawns robots at the "enemy_spawns" points, away from the
## player, and makes each wave bigger and tougher than the last.

signal wave_started(number: int)
signal wave_cleared(number: int)
signal enemy_killed
signal enemies_left_changed(count: int)

@export var enemy_scene: PackedScene
@export var first_wave_delay := 2.0
@export var break_duration := 4.0
@export var spawn_interval := 0.8
@export var min_player_distance := 12.0

var wave := 0

var _to_spawn := 0
var _alive := 0
var _stopped := false
var _spawn_timer := Timer.new()


func _ready() -> void:
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	_start_next_wave(first_wave_delay)


## Stops spawning for good (game over).
func stop() -> void:
	_stopped = true
	_spawn_timer.stop()


# --- Difficulty curve -------------------------------------------------------

func _enemy_count() -> int:
	return 3 + 2 * (wave - 1)


func _max_alive() -> int:
	@warning_ignore("integer_division")
	return mini(3 + (wave - 1) / 2, 6)


func _configure(enemy: Enemy) -> void:
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

	var enemy: Enemy = enemy_scene.instantiate()
	_configure(enemy)
	enemy.position = point.global_position
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)
	_to_spawn -= 1
	_alive += 1


func _on_enemy_died() -> void:
	_alive -= 1
	enemy_killed.emit()
	enemies_left_changed.emit(_to_spawn + _alive)
	if _to_spawn == 0 and _alive == 0:
		_spawn_timer.stop()
		wave_cleared.emit(wave)
		_start_next_wave(break_duration)
