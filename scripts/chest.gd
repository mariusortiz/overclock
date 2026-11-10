class_name Chest
extends Area3D
## Chest opened by walking into it: a random power-up, or sometimes bonus XP
## for the battle pass. Closes again when asked to (each new wave).

signal opened(message: String, bonus_xp: int)

const XP_CHANCE := 0.25
const XP_BONUS := 50

var _closed := true

@onready var _marker: MeshInstance3D = $Marker


func _ready() -> void:
	add_to_group("chests")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_marker.rotate_y(delta * 2.0)


func is_closed() -> bool:
	return _closed


func close() -> void:
	_closed = true
	_marker.visible = true


func _on_body_entered(body: Node3D) -> void:
	if not _closed or not body is Player:
		return
	_closed = false
	_marker.visible = false
	if randf() < XP_CHANCE:
		opened.emit("COFFRE : +%d XP" % XP_BONUS, XP_BONUS)
	else:
		var type: PowerUp.Type = PowerUp.Type.values().pick_random()
		(body as Player).apply_power_up(type)
		opened.emit("COFFRE : %s" % PowerUp.INFO[type].label, 0)
