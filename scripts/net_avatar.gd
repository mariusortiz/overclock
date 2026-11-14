class_name NetAvatar
extends Enemy
## Zone capture over the network: a fighter driven by another device (a
## player), or, on a guest's device, one of the host's bots. It only shows
## where they are and what they do; the hits it takes are sent on, to the
## device that drives it (see CaptureNet.report_damage).

## Peer id for a player, a negative number for a host's bot.
var entity_id := 0
## CaptureNet or WavesNet: what sends its hits on (report_damage).
var net: Node
var alive := true

var _goal_position := Vector3.ZERO
var _goal_yaw := 0.0


func _ready() -> void:
	show_hit_info = false
	super()
	set_physics_process(false)
	_goal_position = global_position
	# Another player's title floats above them.
	var info: Dictionary = Net.players.get(entity_id, {})
	if str(info.get("title", "")) != "":
		var tag := Label3D.new()
		tag.text = "%s\n« %s »" % [info.get("name", ""), info.title]
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		tag.font_size = 40
		tag.outline_size = 10
		tag.modulate = Color(1.0, 0.85, 0.3)
		tag.no_depth_test = true
		tag.position.y = model_height + 0.6
		add_child(tag)


func take_damage(amount: int, from := Vector3.INF) -> void:
	if not alive or _dead:
		return
	Effects.damage_number(get_tree().current_scene, get_aim_position() + Vector3.UP * 0.6, amount, Effects.DAMAGE_COLOR, _headshot_pending)
	_headshot_pending = false
	_flash_white()
	net.report_damage(entity_id, amount, from)


## Where it is now, as last sent by its device.
func apply_state(at: Vector3, yaw: float, action: StringName, is_alive: bool) -> void:
	_goal_position = at
	_goal_yaw = yaw
	if is_alive != alive:
		set_alive(is_alive)
	if alive and action != &"" and action != _model._current_action:
		_model.play(action, action == &"shoot" or action == &"melee")


## A player falls and comes back: hidden and out of reach in between.
func set_alive(is_alive: bool) -> void:
	alive = is_alive
	if is_alive:
		global_position = _goal_position
		_model.play(&"idle", true)
		visible = true
		collision_layer = ALLY_LAYER if team == &"ally" else TARGETS_LAYER
		add_to_group("allies" if team == &"ally" else "targets")
	else:
		_model.play(&"die", true)
		collision_layer = 0
		remove_from_group("allies")
		remove_from_group("targets")
		get_tree().create_timer(1.2).timeout.connect(func() -> void:
			if not alive:
				visible = false)


## A host's bot dies the way the shot that killed it decided.
func die_with(style: StringName, color: Color) -> void:
	set_kill_effect(style, color)
	_die()


func _process(delta: float) -> void:
	if _dead:
		return
	global_position = global_position.lerp(_goal_position, minf(delta * 12.0, 1.0))
	rotation.y = lerp_angle(rotation.y, _goal_yaw, minf(delta * 12.0, 1.0))
	if _model.place_in_hand(_gun, "R", melee_damage > 0):
		_muzzle.global_position = _gun.global_position - global_basis.z * 0.5 + Vector3.UP * 0.2
