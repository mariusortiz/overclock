class_name WavesNet
extends Node
## The waves in co-op over the local network (2 to 4 players, Net mode
## "waves"). The host runs the waves, the enemies and the bosses, and sends
## their state about 15 times a second; each device runs its own player and
## sends where it is. A hit on an enemy is sent to the host, a hit on a
## player to its device (as in CaptureNet). There are more enemies, and
## tougher, for each player more.
##
## A player who falls is down, not out: a teammate standing close to them
## for REVIVE_TIME brings them back, and everyone down gets up at the next
## wave. The game is lost when every player is down at once.

const SEND_RATE := 15.0
const REVIVE_TIME := 3.0
const REVIVE_DISTANCE := 2.4
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

var main: Node
## entity id -> NetAvatar: the other players (peer ids), and on a guest the
## host's enemies (negative ids).
var _avatars := {}
var _send_left := 0.0
var _next_enemy_id := -1
var _ready_guests := {}
var _revive_progress := {}
var _bolt_scene: PackedScene
var _over := false


func setup(owner_main: Node) -> void:
	main = owner_main
	Enemy.coop = true
	multiplayer.peer_disconnected.connect(_on_peer_left)
	var waves: WaveManager = main.waves
	if Net.is_host():
		waves.coop_players = Net.players.size()
		waves.enemy_spawned.connect(_register_enemy)
		waves.wave_started.connect(func(number: int) -> void: _wave_started.rpc(number, waves.is_boss_wave()))
		waves.wave_cleared.connect(func(number: int) -> void: _wave_cleared.rpc(number, waves.is_boss_wave()))
		waves.enemies_left_changed.connect(func(count: int) -> void: _enemies_left.rpc(waves.wave, count))
	else:
		# The host's waves only.
		waves.stop()
		_guest_ready.rpc_id(1)


func _exit_tree() -> void:
	Enemy.coop = false


@rpc("any_peer", "reliable")
func _guest_ready() -> void:
	_ready_guests[multiplayer.get_remote_sender_id()] = true


# --- Each step ------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	var player: Player = main.player
	_send_left -= delta
	if _send_left <= 0.0:
		_send_left = 1.0 / SEND_RATE
		var yaw: float = player.global_rotation.y + player._model_pivot.rotation.y
		_player_state.rpc(player.global_position, yaw, player._model._current_action, player.health > 0)
		if Net.is_host():
			var states := []
			for enemy: Node in get_tree().get_nodes_in_group("targets"):
				if enemy.has_meta("entity_id") and not (enemy as Enemy)._dead:
					states.append([enemy.get_meta("entity_id"), enemy.global_position, enemy.rotation.y, (enemy as Enemy)._model._current_action])
			_enemy_states.rpc(states)
	_revive_teammates(delta)
	if Net.is_host() and not _over and _everyone_down():
		_over = true
		_game_over.rpc()


## Standing close to a downed teammate brings them back.
func _revive_teammates(delta: float) -> void:
	var player: Player = main.player
	if player.health <= 0:
		return
	for id: int in _avatars:
		if id < 0:
			continue
		var avatar: NetAvatar = _avatars[id]
		if not is_instance_valid(avatar) or avatar.alive:
			_revive_progress.erase(id)
			continue
		if avatar.global_position.distance_to(player.global_position) <= REVIVE_DISTANCE:
			_revive_progress[id] = _revive_progress.get(id, 0.0) + delta
			main.hud.show_banner("RELÈVE TON ÉQUIPIER… %d %%" % roundi(100.0 * _revive_progress[id] / REVIVE_TIME))
			if _revive_progress[id] >= REVIVE_TIME:
				_revive_progress.erase(id)
				_revived.rpc_id(id)
		else:
			_revive_progress.erase(id)


func _everyone_down() -> bool:
	if main.player.health > 0:
		return false
	for id: int in _avatars:
		if id > 0 and is_instance_valid(_avatars[id]) and (_avatars[id] as NetAvatar).alive:
			return false
	return true


@rpc("any_peer", "reliable")
func _revived() -> void:
	var player: Player = main.player
	if player.health <= 0:
		player.revive(player.global_position)
		main.hud.show_banner("UN ÉQUIPIER T'A RELEVÉ")


# --- Players ---------------------------------------------------------------------

@rpc("any_peer", "unreliable_ordered")
func _player_state(at: Vector3, yaw: float, action: StringName, alive: bool) -> void:
	var id := multiplayer.get_remote_sender_id()
	if not Net.players.has(id):
		return
	var avatar: NetAvatar = _avatars.get(id)
	if avatar == null or not is_instance_valid(avatar):
		var hero: Dictionary = Loadout.find(Net.players[id].hero).item
		avatar = _make_avatar(id, load(Loadout.CHARACTER_DIR + str(hero.model)), "heavy", at, 1.75, 0.0, Vector3.ONE)
		avatar.team = &"ally"
		# The host's enemies go after them too.
		avatar.add_to_group("coop_players")
	avatar.apply_state(at, yaw, action, alive)


func _on_peer_left(id: int) -> void:
	var avatar: NetAvatar = _avatars.get(id)
	if avatar and is_instance_valid(avatar):
		avatar.queue_free()
	_avatars.erase(id)


func _make_avatar(id: int, model: PackedScene, weapon: String, at: Vector3, height: float, hover: float, scale: Vector3) -> NetAvatar:
	var body := ENEMY_SCENE.instantiate()
	body.set_script(NetAvatar)
	var avatar := body as NetAvatar
	avatar.entity_id = id
	avatar.net = self
	avatar.team = &"enemy" if id < 0 else &"ally"
	avatar.model_scene = model
	avatar.model_height = height
	avatar.model_hover = hover
	avatar.weapon_id = weapon
	avatar.drop_chance = 0.0
	avatar.position = at
	main.add_child(avatar)
	avatar._visual.scale = scale
	_avatars[id] = avatar
	return avatar


# --- Enemies (from the host) --------------------------------------------------------

func _register_enemy(enemy: Enemy) -> void:
	var id := _next_enemy_id
	_next_enemy_id -= 1
	enemy.set_meta("entity_id", id)
	var boss := ""
	if enemy is Boss:
		boss = str(Boss.INFO[(enemy as Boss).kind].name)
		enemy.health_changed.connect(func(current: int, maximum: int) -> void: _boss_health.rpc(current, maximum))
	_spawn_enemy.rpc(id, enemy.model_scene.resource_path, enemy.weapon_id, enemy.global_position, enemy.model_height,
			enemy.model_hover, enemy._visual.scale, boss, enemy.max_health, enemy.elite)
	# Who landed the last blow: a guest whose hit is being applied, or the host.
	enemy.died.connect(func() -> void:
		var killer: int = main.waves.remote_blow if main.waves.remote_blow != 0 else 1
		_enemy_died.rpc(id, enemy._kill_style, enemy._kill_color, enemy is Boss, killer))
	enemy.fired_bolt.connect(func(from: Vector3, direction: Vector3) -> void: _bolt.rpc(from, direction))


@rpc("authority", "reliable")
func _spawn_enemy(id: int, model_path: String, weapon: String, at: Vector3, height: float, hover: float, scale: Vector3,
		boss: String, max_health: int, elite: bool) -> void:
	var avatar := _make_avatar(id, load(model_path), weapon, at, height, hover, scale)
	Effects.flash(main, at + Vector3.UP, Color(1.0, 0.5, 0.15) if boss != "" else Color(0.16, 0.9, 1.0), 3.0, 0.35)
	if elite:
		avatar._glow(Enemy.ELITE_COLOR, 0.3)
	if boss != "":
		main.hud.show_boss(boss)
		main.hud.set_boss_health(max_health, max_health)
		Music.play_track(Music.Track.BOSS)


@rpc("authority", "unreliable_ordered")
func _enemy_states(states: Array) -> void:
	for state: Array in states:
		var avatar: NetAvatar = _avatars.get(state[0])
		if avatar and is_instance_valid(avatar):
			avatar.apply_state(state[1], state[2], state[3], true)


@rpc("authority", "unreliable_ordered")
func _boss_health(current: int, maximum: int) -> void:
	main.hud.set_boss_health(current, maximum)


@rpc("authority", "reliable")
func _enemy_died(id: int, style: StringName, color: Color, boss: bool, killer: int) -> void:
	var avatar: NetAvatar = _avatars.get(id)
	if avatar and is_instance_valid(avatar):
		# The kill counts for the device that landed the last blow only.
		if killer == multiplayer.get_unique_id():
			main.coop_kill(boss)
		avatar.die_with(style if style != &"" else &"knockback", color)
	_avatars.erase(id)
	if boss:
		main.hud.hide_boss()
		Music.play_track(main._arena.music_track)
		if Pets.give_egg():
			main.hud.show_banner("UN ŒUF ! IL ÉCLÔT APRÈS %d VAGUES" % Pets.HATCH_WAVES)


## A host enemy's bolt, for the eyes only on the guests' screens.
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
	main.add_child(bolt)


# --- The waves (from the host) ------------------------------------------------------

@rpc("authority", "reliable")
func _wave_started(number: int, boss: bool) -> void:
	main.waves.wave = number
	main.coop_wave_started(number, boss)


@rpc("authority", "reliable")
func _wave_cleared(number: int, boss: bool) -> void:
	main.coop_wave_cleared(number, boss)


@rpc("authority", "unreliable_ordered")
func _enemies_left(wave: int, count: int) -> void:
	main.hud.set_wave(wave, count)


## The host moves everyone to the next arena.
func change_arena(index: int) -> void:
	_arena.rpc(index)


@rpc("authority", "call_local", "reliable")
func _arena(index: int) -> void:
	for id: int in _avatars.keys():
		if id < 0:
			if is_instance_valid(_avatars[id]):
				_avatars[id].queue_free()
			_avatars.erase(id)
	main.coop_change_arena(index)


func announce_victory() -> void:
	_victory.rpc()


@rpc("authority", "call_local", "reliable")
func _victory() -> void:
	_over = true
	main.coop_end(true)


@rpc("authority", "call_local", "reliable")
func _game_over() -> void:
	_over = true
	main.coop_end(false)


# --- Damage ------------------------------------------------------------------------

## A hit on an avatar on this device: the device that runs it applies it.
func report_damage(entity_id: int, amount: int, from: Vector3) -> void:
	if entity_id < 0:
		if Net.is_host():
			_apply_enemy_damage(entity_id, amount, from)
		else:
			_damage.rpc_id(1, entity_id, amount, from)
	else:
		_hurt.rpc_id(entity_id, amount, from)


@rpc("any_peer", "reliable")
func _damage(entity_id: int, amount: int, from: Vector3) -> void:
	# A guest's hit: if it kills, the kill is the guest's (see WaveManager.remote_blow).
	main.waves.remote_blow = multiplayer.get_remote_sender_id()
	_apply_enemy_damage(entity_id, amount, from)
	main.waves.remote_blow = 0


func _apply_enemy_damage(entity_id: int, amount: int, from: Vector3) -> void:
	for enemy: Node in get_tree().get_nodes_in_group("targets"):
		if enemy.get_meta("entity_id", 0) == entity_id:
			(enemy as Enemy).take_damage(amount, from)
			return


@rpc("any_peer", "reliable")
func _hurt(amount: int, from: Vector3) -> void:
	main.player.take_damage(amount, from)
