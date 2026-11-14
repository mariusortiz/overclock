extends Node
## Local network play (autoloaded as "Net"): one device hosts a game, the
## others on the same Wi-Fi find it and join. The host announces itself by
## UDP broadcast every second; joining uses ENet (Godot's high-level
## multiplayer). Not available in the browser, which cannot open these
## connections.
##
## The host owns the list of players and starts the game for everyone; each
## mode then syncs itself with RPCs (see race.gd and capture.gd).

signal players_changed
signal hosts_changed
## The connection to the host failed or was lost: `reason` is shown.
signal left(reason: String)

const PORT := 7777
const DISCOVERY_PORT := 7778
const MAX_PLAYERS := 6
const ANNOUNCE_INTERVAL := 1.0
## A host not heard from for this long is dropped from the list.
const HOST_TIMEOUT := 4.0
const SCENES := {"race": "res://scenes/race.tscn", "capture": "res://scenes/capture.tscn", "fight": "res://scenes/fight.tscn", "waves": "res://scenes/main.tscn"}

## peer id -> {"name", "hero" (Loadout id), "color" (Color as html)}
var players := {}
## Games found on the network: ip -> {"name", "players", "seen"}
var hosts := {}
## Set by the host when it starts a game, the same on every device.
var mode := ""
var seed_value := 0

var _announcer := PacketPeerUDP.new()
var _listener := PacketPeerUDP.new()
var _announce_left := 0.0
var _listening := false


static func is_supported() -> bool:
	return not OS.has_feature("web")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(func() -> void: leave("Connexion impossible"))
	multiplayer.server_disconnected.connect(func() -> void: leave("L'hôte a quitté la partie"))


## True during a networked game or in a lobby.
func is_online() -> bool:
	return multiplayer.multiplayer_peer is ENetMultiplayerPeer \
			and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func is_host() -> bool:
	return is_online() and multiplayer.is_server()


func my_id() -> int:
	return multiplayer.get_unique_id() if is_online() else 1


## Player ids in a stable order (the host first).
func ids() -> Array:
	var list := players.keys()
	list.sort()
	return list


func host() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_PLAYERS - 1)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	players = {1: _my_info()}
	_announcer.set_broadcast_enabled(true)
	_announce_left = 0.0
	players_changed.emit()
	return OK


func join(address: String) -> Error:
	stop_listening()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	return OK


## Leaves the game (or stops hosting). `reason`, when given, is reported.
func leave(reason := "") -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	mode = ""
	_announcer.close()
	if reason != "":
		left.emit(reason)


## The host starts `mode` for everyone.
func start_game(game_mode: String) -> void:
	if is_host():
		_start.rpc(game_mode, randi())


@rpc("authority", "call_local", "reliable")
func _start(game_mode: String, game_seed: int) -> void:
	mode = game_mode
	seed_value = game_seed
	if game_mode == "fight":
		FightSetup.mode = "online"
	# Overpowered shop items play as their fair version against other players.
	Loadout.fair_play = true
	get_tree().change_scene_to_file.call_deferred(SCENES[game_mode])


# --- Players ------------------------------------------------------------------

func _my_info() -> Dictionary:
	var hero := Loadout.selected_character()
	return {"name": str(hero.name).to_upper(), "hero": hero.id, "color": Color.from_hsv(randf(), 0.75, 1.0).to_html(false),
			"ship": Loadout.selected_ship().id, "title": Titles.title_text(), "banner": Titles.selected_banner().id}


func _on_connected() -> void:
	_register.rpc_id(1, _my_info())


func _on_peer_connected(_id: int) -> void:
	pass


@rpc("any_peer", "reliable")
func _register(info: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	if players.size() >= MAX_PLAYERS or mode != "":
		return
	players[multiplayer.get_remote_sender_id()] = info
	_set_players.rpc(players)
	players_changed.emit()


@rpc("authority", "reliable")
func _set_players(list: Dictionary) -> void:
	players = list
	players_changed.emit()


func _on_peer_disconnected(id: int) -> void:
	if players.erase(id) and multiplayer.is_server():
		_set_players.rpc(players)
	players_changed.emit()


# --- Finding games on the Wi-Fi -------------------------------------------------

func start_listening() -> void:
	hosts.clear()
	_listening = _listener.bind(DISCOVERY_PORT) == OK


func stop_listening() -> void:
	_listener.close()
	_listening = false


func _process(delta: float) -> void:
	if is_host() and mode == "":
		_announce_left -= delta
		if _announce_left <= 0.0:
			_announce_left = ANNOUNCE_INTERVAL
			var message := JSON.stringify({"game": "overclock", "name": players[1].name, "players": players.size()})
			_announcer.set_dest_address("255.255.255.255", DISCOVERY_PORT)
			_announcer.put_packet(message.to_utf8_buffer())
	if _listening:
		var changed := false
		while _listener.get_available_packet_count() > 0:
			var packet := _listener.get_packet().get_string_from_utf8()
			var address := _listener.get_packet_ip()
			var data: Variant = JSON.parse_string(packet)
			if data is Dictionary and data.get("game") == "overclock":
				hosts[address] = {"name": data.get("name", "?"), "players": data.get("players", 1), "seen": Time.get_ticks_msec()}
				changed = true
		for address: String in hosts.keys():
			if Time.get_ticks_msec() - hosts[address].seen > HOST_TIMEOUT * 1000.0:
				hosts.erase(address)
				changed = true
		if changed:
			hosts_changed.emit()


## This device's address on the local network, to type on another device.
static func local_address() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "?"
