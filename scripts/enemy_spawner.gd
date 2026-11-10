class_name EnemySpawner
extends Node
## Keeps a fixed number of robots alive. Spawn points are the nodes of the
## "enemy_spawns" group; robots appear away from the player.

@export var enemy_scene: PackedScene
@export var max_alive := 3
@export var first_spawn_delay := 1.0
@export var respawn_delay := 3.0
@export var min_player_distance := 12.0


func _ready() -> void:
	for i in max_alive:
		_spawn_later(first_spawn_delay + i * 0.5)


func _spawn_later(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_spawn()


func _spawn() -> void:
	var points := get_tree().get_nodes_in_group("enemy_spawns")
	var player: Node3D = get_tree().get_first_node_in_group("player")
	var far_points := points.filter(func(point: Node3D) -> bool:
		return point.global_position.distance_to(player.global_position) >= min_player_distance)
	var point: Node3D = (far_points if not far_points.is_empty() else points).pick_random()

	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = point.global_position
	enemy.died.connect(_spawn_later.bind(respawn_delay))
	get_parent().add_child(enemy)
