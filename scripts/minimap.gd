class_name Minimap
extends Control
## Round radar: the player is at the center and "up" is where they look.
## Enemies are red dots (bosses bigger), power-ups use their own color,
## charged healing pads are green, closed chests yellow and weapon crates orange.
## Anything out of range sticks to the edge.

const RANGE := 32.0
const BACKGROUND := Color(0, 0, 0, 0.45)
const BORDER := Color(0, 0.9, 1, 0.8)
const ENEMY_COLOR := Color(1.0, 0.2, 0.15)
const PAD_COLOR := Color(0.2, 1.0, 0.4)
const CHEST_COLOR := Color(1.0, 0.85, 0.2)


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
	for pad: RegenPad in get_tree().get_nodes_in_group("regen_pads"):
		if pad.is_charged():
			_draw_dot(player, pad.global_position, PAD_COLOR, 4.0)
	for chest: Chest in get_tree().get_nodes_in_group("chests"):
		if chest.is_closed():
			_draw_dot(player, chest.global_position, CHEST_COLOR, 4.0)
	for crate: Node3D in get_tree().get_nodes_in_group("crates"):
		_draw_dot(player, crate.global_position, SupplyCrate.COLOR, 5.0)
	for power_up: PowerUp in get_tree().get_nodes_in_group("power_ups"):
		_draw_dot(player, power_up.global_position, PowerUp.INFO[power_up.type].color, 3.0)
	# Team modes: the zones in their holder's color, the allies in cyan.
	for zone: CaptureZone in get_tree().get_nodes_in_group("capture_zones"):
		_draw_dot(player, zone.global_position, zone.color(), 7.0)
	for ally: Node3D in get_tree().get_nodes_in_group("allies"):
		_draw_dot(player, ally.global_position, CaptureZone.ALLY_COLOR, 3.5)
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
