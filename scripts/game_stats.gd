class_name GameStats
extends Node
## Counts what happens during a game (kills, headshots, waves…). At the end,
## the counts are added to the career totals shown on the home screen and to
## the progress of the daily challenges (see Challenges).

const CAREER_KEY := "career"
## Career stats that keep the best value instead of adding up.
const BEST_OF: Array[String] = ["best_wave"]

## Stat name -> count, for this game.
var counts := {}
## Gun id -> enemies it killed in this game.
var weapon_kills := {}
## Blade id -> enemies it killed in this game (see Mastery).
var melee_kills := {}

var _player: Player
var _last_hit_frame := -1


func setup(player: Player, waves: WaveManager) -> void:
	_player = player
	waves.enemy_killed.connect(_on_enemy_killed)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.boss_killed.connect(func(_kind: Boss.Kind) -> void: add("bosses"))
	waves.elite_killed.connect(add.bind("elites"))
	player.weapon.fired.connect(add.bind("shots"))
	player.weapon.hit_confirmed.connect(_on_hit)
	player.melee.hit_confirmed.connect(add.bind("melee_hits"))
	player.ultimate.activated.connect(func(_name: String) -> void: add("ultimates"))


func add(stat: String, amount := 1) -> void:
	counts[stat] = counts.get(stat, 0) + amount


func _process(delta: float) -> void:
	if _player and _player.health > 0:
		counts["seconds"] = counts.get("seconds", 0.0) + delta


func _on_enemy_killed() -> void:
	add("kills")
	# A kill while the blade strikes is the blade's.
	if _player.melee.striking:
		var blade_id: String = Loadout.selected_melee().id
		melee_kills[blade_id] = melee_kills.get(blade_id, 0) + 1
		return
	var weapon_id: String = _player.weapon.current_data.get("id", "")
	weapon_kills[weapon_id] = weapon_kills.get(weapon_id, 0) + 1


## A shotgun's pellets confirm several hits for one shot: count it once.
func _on_hit(headshot: bool) -> void:
	if headshot:
		add("headshots")
	var frame := Engine.get_physics_frames()
	if frame != _last_hit_frame:
		_last_hit_frame = frame
		add("hits")


func _on_wave_cleared(number: int) -> void:
	add("waves")
	counts["best_wave"] = maxi(counts.get("best_wave", 0), number)


## The game is over: adds it to the career and to the daily challenges.
## Returns the challenges and weekly missions it completed.
func finish() -> Array[Dictionary]:
	add("games")
	var career := load_career()
	for stat: String in counts:
		var value: float = counts[stat]
		if stat in BEST_OF:
			career[stat] = maxf(career.get(stat, 0), value)
		else:
			career[stat] = career.get(stat, 0) + value
	var kills_by_weapon: Dictionary = career.get("weapon_kills", {})
	for weapon_id: String in weapon_kills:
		kills_by_weapon[weapon_id] = kills_by_weapon.get(weapon_id, 0) + weapon_kills[weapon_id]
	career["weapon_kills"] = kills_by_weapon
	SaveData.save_progress(CAREER_KEY, career)
	Mastery.record(weapon_kills, melee_kills)
	var completed := Challenges.record(counts)
	for mission in Weekly.record(counts):
		mission.weekly = true
		mission.text = "Semaine : " + mission.text
		completed.append(mission)
	return completed


static func load_career() -> Dictionary:
	return SaveData.load_progress(CAREER_KEY, {})


## The career as lines of [label, value] for the home screen.
static func career_lines() -> Array[Array]:
	var career := load_career()
	var shots: float = career.get("shots", 0)
	var accuracy := "-" if shots == 0 else "%d %%" % roundi(100.0 * minf(career.get("hits", 0) / shots, 1.0))
	var minutes := roundi(career.get("seconds", 0.0) / 60.0)
	var favorite := "-"
	var kills_by_weapon: Dictionary = career.get("weapon_kills", {})
	var most := 0
	for weapon_id: String in kills_by_weapon:
		var found := Loadout.find(weapon_id)
		if kills_by_weapon[weapon_id] > most and not found.is_empty():
			most = kills_by_weapon[weapon_id]
			favorite = found.item.name
	var lines: Array[Array] = [
		["Parties", str(int(career.get("games", 0)))],
		["Temps de jeu", "%d h %02d" % [floori(minutes / 60.0), minutes % 60]],
		["Ennemis abattus", str(int(career.get("kills", 0)))],
		["Élites abattues", str(int(career.get("elites", 0)))],
		["Boss vaincus", str(int(career.get("bosses", 0)))],
		["Meilleure vague", str(int(career.get("best_wave", 0)))],
		["Précision", accuracy],
		["Tirs à la tête", str(int(career.get("headshots", 0)))],
		["Coups au corps à corps", str(int(career.get("melee_hits", 0)))],
		["Arme favorite", favorite],
	]
	return lines
