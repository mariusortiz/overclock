class_name CaptureNet
extends Node
## Zone capture over the local network. The host runs the bots, the zones
## and the score; each device runs its own player and sends where it is.
## Everything a device does not run is shown by a NetAvatar. A hit on an
## avatar is sent to the device that runs that fighter.
##
## Teams: players in Net.ids() order alternate, team 0 (the host's) and 1.
## The host's point of view is the absolute one: its "ally" is team 0.

const SEND_RATE := 15.0
const ZONE_RATE := 5.0
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

var capture: Node
## This device's team, 0 or 1.
var my_team := 0
## entity id -> NetAvatar
var _avatars := {}
var _send_left := 0.0
var _zone_left := 0.0
var _next_bot_id := -1
## entity id -> the time this player last hit it (to count the kill).
var _my_hits := {}
var _bolt_scene: PackedScene


## Guests that have loaded the arena (the host waits for them before the bots).
var _ready_guests := {}


func setup(owner_capture: Node) -> void:
	capture = owner_capture
	my_team = team_of(Net.my_id())
	multiplayer.peer_disconnected.connect(_on_peer_left)
	if not Net.is_host():
		_guest_ready.rpc_id(1)


## Host: waits for every guest's scene (or a few seconds), so that nothing it
## sends is lost.
func wait_for_guests(timeout: float) -> void:
	var left := timeout
	while _ready_guests.size() < Net.players.size() - 1 and left > 0.0:
		await get_tree().create_timer(0.2).timeout
		left -= 0.2


@rpc("any_peer", "reliable")
func _guest_ready() -> void:
	_ready_guests[multiplayer.get_remote_sender_id()] = true


static func team_of(peer: int) -> int:
	return Net.ids().find(peer) % 2


## Human players in a team.
static func humans_in(team: int) -> int:
	var count := 0
	for id in Net.ids():
		if team_of(id) == team:
			count += 1
	return count


func _physics_process(delta: float) -> void:
	_send_left -= delta
	if _send_left <= 0.0:
		_send_left = 1.0 / SEND_RATE
		var player: Player = capture.player
		var yaw: float = player.global_rotation.y + player._model_pivot.rotation.y
		_player_state.rpc(player.global_position, yaw, player._model._current_action, player.health > 0)
		if Net.is_host():
			var states := []
			for bot: Node in get_tree().get_nodes_in_group("capture_bots"):
				var capture_bot := bot as CaptureBot
				if capture_bot._dead:
					continue
				states.append([capture_bot.get_meta("entity_id"), capture_bot.global_position, capture_bot.rotation.y,
						capture_bot._model._current_action])
			_bot_states.rpc(states)
	if Net.is_host():
		_zone_left -= delta
		if _zone_left <= 0.0:
			_zone_left = 1.0 / ZONE_RATE
			var controls := []
			for zone: CaptureZone in capture._zones:
				controls.append(zone.control)
			_zones_state.rpc(controls, capture._points[&"ally"], capture._points[&"enemy"])


# --- Bots (host) ------------------------------------------------------------------

## Gives a new host bot its id and tells the guests about it.
func register_bot(bot: CaptureBot) -> void:
	var id := _next_bot_id
	_next_bot_id -= 1
	bot.set_meta("entity_id", id)
	bot.add_to_group("capture_bots")
	_spawn_bot_avatar.rpc(id, 0 if bot.team == &"ally" else 1, bot.model_scene.resource_path, bot.weapon_id, bot.global_position)
	bot.died.connect(func() -> void:
		_bot_died.rpc(id, bot._kill_style, bot._kill_color))
	bot.shot.connect(func(from: Vector3, direction: Vector3) -> void: _bolt.rpc(from, direction))


## A host bot's bolt, for the eyes only: it hits nothing on the guests'
## screens (the host decides who it hits).
@rpc("authority", "unreliable")
func _bolt(from: Vector3, direction: Vector3) -> void:
	if _bolt_scene == null:
		var sample := ENEMY_SCENE.instantiate()
		_bolt_scene = sample.projectile_scene
		sample.free()
	var bolt: Projectile = _bolt_scene.instantiate()
	bolt.position = from
	bolt.direction = direction
	bolt.collision_mask = 1
	capture.add_child(bolt)


@rpc("authority", "reliable")
func _spawn_bot_avatar(id: int, team: int, model_path: String, weapon: String, at: Vector3) -> void:
	_make_avatar(id, team, load(model_path), weapon, at)


@rpc("authority", "unreliable_ordered")
func _bot_states(states: Array) -> void:
	for state: Array in states:
		var avatar: NetAvatar = _avatars.get(state[0])
		if avatar and is_instance_valid(avatar):
			avatar.apply_state(state[1], state[2], state[3], true)


@rpc("authority", "reliable")
func _bot_died(id: int, style: StringName, color: Color) -> void:
	var avatar: NetAvatar = _avatars.get(id)
	if avatar and is_instance_valid(avatar):
		if Time.get_ticks_msec() - _my_hits.get(id, -10000) < 1500:
			capture.count_kill()
		avatar.die_with(style if style != &"" else &"knockback", color)
	_avatars.erase(id)


# --- Players --------------------------------------------------------------------

@rpc("any_peer", "unreliable_ordered")
func _player_state(at: Vector3, yaw: float, action: StringName, alive: bool) -> void:
	var id := multiplayer.get_remote_sender_id()
	if not Net.players.has(id):
		return
	var avatar: NetAvatar = _avatars.get(id)
	if avatar == null or not is_instance_valid(avatar):
		var hero: Dictionary = Loadout.find(Net.players[id].hero).item
		avatar = _make_avatar(id, team_of(id), load(Loadout.CHARACTER_DIR + str(hero.model)), "heavy", at)
	avatar.apply_state(at, yaw, action, alive)


func _on_peer_left(id: int) -> void:
	var avatar: NetAvatar = _avatars.get(id)
	if avatar and is_instance_valid(avatar):
		avatar.queue_free()
	_avatars.erase(id)


func _make_avatar(id: int, team: int, model: PackedScene, weapon: String, at: Vector3) -> NetAvatar:
	var body := ENEMY_SCENE.instantiate()
	body.set_script(NetAvatar)
	var avatar := body as NetAvatar
	avatar.entity_id = id
	avatar.net = self
	avatar.team = &"ally" if team == my_team else &"enemy"
	avatar.model_scene = model
	avatar.weapon_id = weapon
	avatar.drop_chance = 0.0
	avatar.position = at
	capture.add_child(avatar)
	_avatars[id] = avatar
	return avatar


# --- Damage ---------------------------------------------------------------------

## A hit on an avatar on this device: the device that runs the fighter applies it.
func report_damage(entity_id: int, amount: int, from: Vector3) -> void:
	_my_hits[entity_id] = Time.get_ticks_msec()
	if Net.is_host():
		_apply_damage(entity_id, amount, from)
	else:
		_damage.rpc_id(1, entity_id, amount, from)


@rpc("any_peer", "reliable")
func _damage(entity_id: int, amount: int, from: Vector3) -> void:
	_apply_damage(entity_id, amount, from)


func _apply_damage(entity_id: int, amount: int, from: Vector3) -> void:
	if entity_id < 0:
		for bot: Node in get_tree().get_nodes_in_group("capture_bots"):
			if bot.get_meta("entity_id") == entity_id:
				(bot as CaptureBot).take_damage(amount, from)
	elif entity_id == Net.my_id():
		capture.player.take_damage(amount, from)
	else:
		_hurt.rpc_id(entity_id, amount, from)


@rpc("any_peer", "reliable")
func _hurt(amount: int, from: Vector3) -> void:
	capture.player.take_damage(amount, from)


# --- Zones and the end (from the host) -----------------------------------------

@rpc("authority", "unreliable_ordered")
func _zones_state(controls: Array, team0: float, team1: float) -> void:
	var sign := 1.0 if my_team == 0 else -1.0
	for index in mini(controls.size(), capture._zones.size()):
		var zone: CaptureZone = capture._zones[index]
		zone.control = float(controls[index]) * sign
		zone.update(0.0, 0, 0)
	capture._points[&"ally"] = team0 if my_team == 0 else team1
	capture._points[&"enemy"] = team1 if my_team == 0 else team0
	capture._refresh_top()


## The host tells everyone which team won.
func announce_winner(team: int) -> void:
	_winner.rpc(team)


@rpc("authority", "call_local", "reliable")
func _winner(team: int) -> void:
	capture.finish_online(team == my_team)
