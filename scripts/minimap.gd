class_name Minimap
extends Control
## Round radar: the player is at the center and "up" is where they look.
## Robots are red dots (bosses bigger), power-ups use their own color.
## Anything out of range sticks to the edge.

const RANGE := 32.0
const BACKGROUND := Color(0, 0, 0, 0.45)
const BORDER := Color(0, 0.9, 1, 0.8)
const ENEMY_COLOR := Color(1.0, 0.2, 0.15)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := size.x * 0.5
	draw_circle(center, radius, BACKGROUND)
	draw_arc(center, radius, 0.0, TAU, 48, BORDER, 2.0)

	var player: Node3D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for power_up: PowerUp in get_tree().get_nodes_in_group("power_ups"):
		_draw_dot(player, power_up.global_position, PowerUp.INFO[power_up.type].color, 3.0)
	for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
		_draw_dot(player, enemy.global_position, ENEMY_COLOR, 6.5 if enemy is Boss else 3.5)
	draw_colored_polygon([center + Vector2(0, -8), center + Vector2(6, 6), center + Vector2(-6, 6)], Color.WHITE)


func _draw_dot(player: Node3D, world_position: Vector3, color: Color, dot_radius: float) -> void:
	var radius := size.x * 0.5
	var offset := world_position - player.global_position
	# Rotating by the player's yaw puts their forward direction at the top.
	var point := Vector2(offset.x, offset.z).rotated(player.global_rotation.y) / RANGE * radius
	point = point.limit_length(radius - dot_radius)
	draw_circle(size * 0.5 + point, dot_radius, color)
