class_name SurvivalGame
extends Node3D
## The survival mode: a wild island (SurvivalWorld) to live on. By day, harvest
## (SurvivalNode), hunt (SurvivalAnimal), craft (SurvivalData.RECIPES) and
## build (SurvivalPiece); by night, hold out against the creatures
## (SurvivalCreature), more of them every night, and a red night every fifth.
## Hunger and thirst go down; at zero they hurt. Dying drops the backpack where
## it happened and brings the hero back to the bed (or the first camp).
## The world is saved (SurvivalSave) every SAVE_EVERY seconds and on leaving.

const MENU_SCENE := "res://scenes/menu.tscn"
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const DAY_LENGTH := 600.0
const NIGHT_LENGTH := 240.0
const SAVE_EVERY := 30.0
## Hunger and thirst, per second (out of 100).
const HUNGER_RATE := 100.0 / 720.0
const THIRST_RATE := 100.0 / 480.0
const STARVE_INTERVAL := 2.0
const HEAL_INTERVAL := 3.0
const REACH := 2.8
const BUILD_REACH := 9.0
const HOTBAR_SIZE := 6
const RED_NIGHT_EVERY := 5
const RESPAWN_TIME := 4.0
const DIFFICULTIES := ["Paisible", "Normal", "Difficile"]
## Enemies of the day, by biome: [model, weapon, melee damage].
const WILD := {
	SurvivalWorld.Biome.FOREST: ["Goblin_Male.fbx", "knife", 0],
	SurvivalWorld.Biome.JUNGLE: ["Goblin_Male.fbx", "knife", 0],
	SurvivalWorld.Biome.DESERT: ["Ninja_Sand.fbx", "smg", 0],
	SurvivalWorld.Biome.MARSH: ["Zombie_Male.fbx", "", 6],
	SurvivalWorld.Biome.MOUNTAIN: ["Knight_Male.fbx", "rifle_3", 0],
	SurvivalWorld.Biome.SNOW: ["Knight_Male.fbx", "rifle_3", 0],
	SurvivalWorld.Biome.BEACH: ["Pirate_Male.fbx", "shotgun_2", 0],
}

## Saved state (see SurvivalSave).
var world_seed := 1
var difficulty := 1
var day := 1
## Seconds into the day (0 at dawn; night from DAY_LENGTH on).
var clock := 90.0
var food := 100.0
var water := 100.0
var inventory := {}
var hotbar: Array = ["", "", "", "", "", ""]
var selected := 0
var spawn_point := Vector3.ZERO
var bed_point := Vector3.INF
var stats := {"kills": 0, "built": 0, "crafted": 0, "best_day": 1, "red_nights": 0}

var building := false
var build_piece := "floor"
var build_material := "wood"
var build_turns := 0

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
var world := SurvivalWorld.new()
var ui: SurvivalUI
var _sun := DirectionalLight3D.new()
var _environment := Environment.new()
var _sky := ProceduralSkyMaterial.new()
var _ghost: SurvivalPiece
var _pieces := Node3D.new()
var _pet: Pet
var _save_left := SAVE_EVERY
var _starve_left := STARVE_INTERVAL
var _heal_left := HEAL_INTERVAL
var _spawn_left := 5.0
var _raid_left := 180.0
var _animal_left := 4.0
var _was_night := false
var _over := false
var _red_night := false


func _ready() -> void:
	_build_sky()
	add_child(world)
	add_child(_pieces)
	var save := SurvivalSave.load_world()
	if save.is_empty() or SurvivalSave.fresh:
		world_seed = SurvivalSave.new_seed
		difficulty = SurvivalSave.new_difficulty
		world.setup(world_seed)
		spawn_point = world.find_spawn()
		_give_start_kit()
	else:
		SurvivalSave.apply(self, save)
		world.setup(world_seed)
	SurvivalSave.fresh = false
	world.day = day
	var start: Vector3 = SurvivalSave.player_at if SurvivalSave.player_at != Vector3.INF else spawn_point
	world.build_around(start)
	SurvivalSave.restore_pieces(self, save)
	player.global_position = start + Vector3.UP * 0.5
	player.regen_per_second = 0.0
	player.weapon.ammo_supply = _take_ammo
	player.melee.swung.connect(_on_swung)
	player.died.connect(_on_player_died)
	# The pet comes along, its perk on.
	Pets.enabled = true
	Pets.in_game = true
	if Pets.selected().id != Pets.NONE.id:
		_pet = Pet.new()
		_pet.configure(Pets.selected(), player)
		add_child(_pet)
	hud.touch_controls.look.connect(func(relative: Vector2) -> void:
		if player.health > 0:
			player.look(relative, player.touch_sensitivity))
	hud.quit_pressed.connect(_leave)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.replay_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.dance_chosen.connect(player.dance)
	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.hurt_from.connect(hud.show_hurt_from)
	player.ultimate.charge_changed.connect(hud.set_ultimate)
	hud.set_health(player.health, player.max_health)
	hud.set_score(int(stats.kills))
	hud.get_node("WaveLabel").visible = false
	ui = SurvivalUI.new()
	ui.game = self
	add_child(ui)
	_equip_selected()
	Music.play_track(Music.Track.JUNGLE)
	hud.show_banner("JOUR %d  ·  %s" % [day, str(SurvivalWorld.BIOME_NAMES[world.biome_at(start.x, start.z)]).to_upper()])
	# Test option: "-- --survival-fast" runs the clock 40 times as fast.
	if "--survival-fast" in OS.get_cmdline_user_args():
		Engine.time_scale = 1.0
		set_meta("fast", true)


func _give_start_kit() -> void:
	inventory = {"wood": 4, "stone": 4, "berries": 4}
	hotbar = ["", "", "", "", "", ""]


func _build_sky() -> void:
	var sky := Sky.new()
	sky.sky_material = _sky
	_environment.background_mode = Environment.BG_SKY
	_environment.sky = sky
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.tonemap_exposure = 0.9
	_environment.fog_enabled = true
	_environment.fog_density = 0.006
	var holder := WorldEnvironment.new()
	holder.environment = _environment
	add_child(holder)
	_sun.shadow_enabled = Settings.high_quality
	_sun.directional_shadow_max_distance = 60.0
	add_child(_sun)


# --- The clock -------------------------------------------------------------------------

func is_night() -> bool:
	return clock >= DAY_LENGTH


func _process(delta: float) -> void:
	if _over:
		return
	var speed := 40.0 if has_meta("fast") else 1.0
	clock += delta * speed
	if clock >= DAY_LENGTH + NIGHT_LENGTH:
		clock -= DAY_LENGTH + NIGHT_LENGTH
		_new_day()
	if is_night() != _was_night:
		_was_night = is_night()
		if is_night():
			_on_nightfall()
	_update_light()
	if player.health > 0:
		world.update_focus(player.global_position)
		_update_needs(delta * speed if has_meta("fast") else delta)
		_update_spawns(delta * speed)
	_update_ghost()
	_save_left -= delta
	if _save_left <= 0.0:
		_save_left = SAVE_EVERY
		SurvivalSave.save_world(self)
	hud.reticle.on_target = player.aiming_at_enemy
	if Input.is_action_just_pressed("fire") and not _holds_gun() and player.health > 0 and not ui.is_open():
		if building:
			place_piece()
		else:
			player.melee.try_swing()


func _new_day() -> void:
	day += 1
	world.day = day
	stats.best_day = maxi(int(stats.best_day), day)
	_red_night = false
	# The night creatures burn in the morning light.
	for creature in get_tree().get_nodes_in_group("survival_night"):
		(creature as SurvivalCreature).burn_away()
	hud.show_banner("JOUR %d  ·  TU AS SURVÉCU" % day)
	SurvivalSave.save_world(self)
	Achievements.check()


func _on_nightfall() -> void:
	_red_night = day % RED_NIGHT_EVERY == 0 and difficulty > 0
	if difficulty == 0:
		hud.show_banner("LA NUIT TOMBE  ·  PAISIBLE")
	elif _red_night:
		hud.show_banner("NUIT ROUGE  ·  ILS ARRIVENT")
		_spawn_creature("brute", _ring_point(26.0))
	else:
		hud.show_banner("LA NUIT TOMBE  ·  RESTE PRÈS DU FEU")


func _update_light() -> void:
	var total := DAY_LENGTH + NIGHT_LENGTH
	var t := clock / total
	# The sun rises at 0, sets at DAY_LENGTH; at night a dim moon.
	var day_share := DAY_LENGTH / total
	var light := 0.0
	if t < day_share:
		var p := t / day_share
		light = clampf(sin(p * PI) * 1.6, 0.0, 1.0)
		_sun.rotation = Vector3(-lerpf(0.5, PI - 0.5, p), deg_to_rad(30), 0)
	else:
		var p := (t - day_share) / (1.0 - day_share)
		_sun.rotation = Vector3(-lerpf(0.4, PI - 0.4, p), deg_to_rad(-40), 0)
	var night_color := Color(1.0, 0.25, 0.2) if _red_night else Color(0.35, 0.45, 0.85)
	_sun.light_color = Color(1.0, 0.92, 0.82).lerp(night_color, 1.0 - light)
	_sun.light_energy = lerpf(0.25, 0.9, light)
	var dusk := 1.0 - absf(light * 2.0 - 1.0)
	_sky.sky_top_color = Color(0.02, 0.03, 0.1).lerp(Color(0.25, 0.5, 0.88), light)
	_sky.sky_horizon_color = Color(0.06, 0.07, 0.16).lerp(Color(0.75, 0.85, 0.95), light).lerp(Color(1.0, 0.55, 0.3), dusk * 0.5)
	if _red_night and light < 0.5:
		_sky.sky_horizon_color = _sky.sky_horizon_color.lerp(Color(0.5, 0.05, 0.05), 0.6)
	_sky.ground_bottom_color = _sky.sky_horizon_color.darkened(0.3)
	_sky.ground_horizon_color = _sky.sky_horizon_color
	_environment.ambient_light_color = Color(0.3, 0.35, 0.6).lerp(Color(0.85, 0.85, 0.8), light)
	_environment.ambient_light_energy = lerpf(0.35, 0.5, light)
	_environment.fog_light_color = Color(0.05, 0.06, 0.14).lerp(Color(0.55, 0.65, 0.78), light)
	if _red_night and light < 0.5:
		_environment.fog_light_color = Color(0.3, 0.04, 0.04)


## "Jour 3 · 14:20" for the HUD: the day runs 06:00 to 20:00, the night to 06:00.
func clock_text() -> String:
	var hours: float
	if is_night():
		hours = 20.0 + (clock - DAY_LENGTH) / NIGHT_LENGTH * 10.0
	else:
		hours = 6.0 + clock / DAY_LENGTH * 14.0
	hours = fmod(hours, 24.0)
	return "JOUR %d · %02d:%02d" % [day, int(hours), int(fmod(hours, 1.0) * 60.0)]


# --- Needs -------------------------------------------------------------------------------

func _update_needs(delta: float) -> void:
	food = maxf(food - HUNGER_RATE * delta, 0.0)
	water = maxf(water - THIRST_RATE * delta, 0.0)
	if food <= 0.0 or water <= 0.0:
		_starve_left -= delta
		if _starve_left <= 0.0:
			_starve_left = STARVE_INTERVAL
			player.take_damage(3)
	elif food > 50.0 and water > 50.0 and player.health < player.max_health:
		_heal_left -= delta
		if _heal_left <= 0.0:
			_heal_left = HEAL_INTERVAL
			player.heal(2)


## Eats, drinks or heals with an item of the inventory. Returns whether it did.
func consume(item: String) -> bool:
	var info: Dictionary = SurvivalData.ITEMS.get(item, {})
	if not info.get("kind", "") in ["food", "drink", "heal"] or count(item) <= 0:
		return false
	remove(item, 1)
	food = minf(food + float(info.get("food", 0)), 100.0)
	water = minf(water + float(info.get("water", 0)), 100.0)
	if info.has("heal"):
		player.heal(int(info.heal))
	if info.has("hurt"):
		player.take_damage(int(info.hurt))
		hud.show_banner("BEURK, C'ÉTAIT CRU")
	if info.has("leaves"):
		add(info.leaves, 1)
	return true


## Near water (the sea, the river, a lake).
func near_water() -> bool:
	var at := player.global_position
	if at.y > SurvivalWorld.WATER_LEVEL + 2.5:
		for offset: Vector2 in [Vector2(2.5, 0), Vector2(-2.5, 0), Vector2(0, 2.5), Vector2(0, -2.5)]:
			if world.height_at(at.x + offset.x, at.z + offset.y) < SurvivalWorld.WATER_LEVEL and at.y < SurvivalWorld.WATER_LEVEL + 3.5:
				return true
		return false
	return world.height_at(at.x, at.z) < SurvivalWorld.WATER_LEVEL + 1.0 or at.y < SurvivalWorld.WATER_LEVEL + 1.8


# --- Inventory -------------------------------------------------------------------------------

func count(item: String) -> int:
	return int(inventory.get(item, 0))


func add(item: String, amount: int) -> void:
	inventory[item] = count(item) + amount
	# Tools, guns, food and heals go to a free slot of the bar.
	var kind: String = SurvivalData.ITEMS.get(item, {}).get("kind", "")
	if kind in ["tool", "gun", "food", "drink", "heal"] and not item in hotbar:
		var free := hotbar.find("")
		if free >= 0:
			hotbar[free] = item
			if free == selected:
				_equip_selected()
	if ui:
		ui.refresh()


func remove(item: String, amount: int) -> void:
	inventory[item] = count(item) - amount
	if count(item) <= 0:
		inventory.erase(item)
		var slot := hotbar.find(item)
		if slot >= 0:
			hotbar[slot] = ""
			if slot == selected:
				_equip_selected()
	if ui:
		ui.refresh()


func has_all(cost: Dictionary) -> bool:
	for item: String in cost:
		if count(item) < int(cost[item]):
			return false
	return true


func _take_ammo(wanted: int) -> int:
	var given := mini(wanted, count("ammo"))
	if given > 0:
		remove("ammo", given)
	return given


# --- The bar and what is in hand ------------------------------------------------------------

func select_slot(index: int) -> void:
	selected = clampi(index, 0, HOTBAR_SIZE - 1)
	var item: String = hotbar[selected]
	# Food and heals in the bar are used on the spot.
	if SurvivalData.ITEMS.get(item, {}).get("kind", "") in ["food", "drink", "heal"]:
		consume(item)
	_equip_selected()
	if ui:
		ui.refresh()


func held() -> Dictionary:
	var item: String = hotbar[selected]
	return SurvivalData.ITEMS.get(item, {})


func _holds_gun() -> bool:
	return held().get("kind", "") == "gun"


func _equip_selected() -> void:
	var item := held()
	var gun: bool = item.get("kind", "") == "gun"
	player.weapon.set_physics_process(gun)
	player.weapon.get_node("ModelPivot").visible = gun
	if gun:
		var data: Dictionary = Loadout.find(item.gun).item
		player.weapon.setup(data, player.perks)
		player.weapon.ammo = 0
		player.weapon._reload()
	var tool := item if item.get("kind", "") == "tool" else {}
	player.melee.setup({"id": tool.get("model", "fists"), "damage": int(tool.get("damage", 1)), "range": REACH, "cooldown": 0.55, "sweep": false, "cone": 70.0,
			"knockback": 0.0, "model": tool.get("model", "")})
	hud.set_ammo(player.weapon.ammo if gun else 0, player.weapon.get_magazine_size() if gun else 0, false)


## A swing: harvests what is in front, if anything.
func _on_swung() -> void:
	var forward := -player.global_basis.z
	var best: SurvivalNode = null
	var best_distance := REACH + 0.8
	for node: SurvivalNode in get_tree().get_nodes_in_group("survival_nodes"):
		var offset := node.global_position - player.global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance < best_distance and (distance < 1.0 or forward.dot(offset.normalized()) > 0.35):
			best = node
			best_distance = distance
	if best == null:
		return
	var given := best.hit(held())
	if given.has("_needs"):
		hud.show_banner("IL FAUT UNE PIOCHE")
		return
	var lines: Array[String] = []
	for item: String in given:
		add(item, int(given[item]))
		lines.append("+%d %s" % [given[item], SurvivalData.item_name(item)])
	if not lines.is_empty():
		ui.toast(", ".join(lines))


## ACTION: open a chest, use the bed, drink. Returns what happened.
func interact() -> void:
	var piece := nearest_piece(["chest", "bed"], 2.6)
	if piece and piece.type == "chest":
		ui.open_chest(piece)
		return
	if piece and piece.type == "bed":
		bed_point = piece.global_position + Vector3.UP * 0.6
		hud.show_banner("TU RÉAPPARAÎTRAS ICI")
		SurvivalSave.save_world(self)
		return
	var backpack := nearest_piece(["backpack"], 2.6)
	if backpack:
		for item: String in backpack.content:
			add(item, int(backpack.content[item]))
		backpack.queue_free()
		hud.show_banner("SAC RÉCUPÉRÉ")
		return
	if near_water():
		if count("flask") > 0:
			remove("flask", 1)
			add("water_flask", 1)
			ui.toast("Gourde remplie")
		water = minf(water + 30.0, 100.0)
		ui.toast("Tu bois : soif %d" % int(water))
		return
	ui.toast("Rien à faire ici")


func nearest_piece(types: Array, reach: float) -> SurvivalPiece:
	var best: SurvivalPiece = null
	for piece: SurvivalPiece in get_tree().get_nodes_in_group("survival_pieces"):
		if piece.type in types and piece.global_position.distance_to(player.global_position) <= reach:
			if best == null or piece.global_position.distance_to(player.global_position) < best.global_position.distance_to(player.global_position):
				best = piece
	return best


## The stations within reach, for the recipes.
func stations_near() -> Array:
	var found := []
	for piece: SurvivalPiece in get_tree().get_nodes_in_group("survival_stations"):
		if piece.global_position.distance_to(player.global_position) <= SurvivalData.STATION_RANGE:
			found.append(piece.type)
	return found


# --- Crafting ---------------------------------------------------------------------------------

func can_craft(recipe: Array) -> bool:
	return has_all(recipe[2]) and (recipe[3] == "" or recipe[3] in stations_near())


func craft(recipe: Array) -> bool:
	if not can_craft(recipe):
		return false
	for item: String in recipe[2]:
		remove(item, int(recipe[2][item]))
	add(recipe[0], int(recipe[1]))
	stats.crafted = int(stats.crafted) + 1
	if recipe[0] == "piece:forge":
		Achievements.set_flag("survival_forge")
	ui.toast("Fabriqué : %s" % SurvivalData.item_name(recipe[0]))
	return true


# --- Building ----------------------------------------------------------------------------------

func set_building(on: bool) -> void:
	building = on
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	if on:
		_make_ghost()
	if ui:
		ui.refresh()


func choose_piece(piece: String, piece_material := "") -> void:
	build_piece = piece
	if piece_material != "":
		build_material = piece_material
	if building:
		set_building(true)


func rotate_piece() -> void:
	build_turns = (build_turns + 1) % 4
	if _ghost:
		_ghost.rotation.y = build_turns * PI / 2.0


func _make_ghost() -> void:
	_ghost = SurvivalPiece.new()
	_ghost.configure(build_piece, build_material, true)
	add_child(_ghost)
	_ghost.rotation.y = build_turns * PI / 2.0


## What placing the chosen piece costs: {item: count}.
func piece_cost() -> Dictionary:
	var info: Dictionary = SurvivalData.PIECES[build_piece]
	if info.get("station", false):
		return {"piece:" + build_piece: 1}
	var cost := {}
	if int(info.get("cost", 0)) > 0:
		cost[build_material] = int(info.cost)
	for item: String in info.get("extra", {}):
		cost[item] = int(info.extra[item])
	return cost


## Where the chosen piece would go: on the 2 m grid, in front of the hero.
func _placement() -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return {}
	var from := camera.global_position
	var to := from - camera.global_basis.z * (BUILD_REACH + 4.0)
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var point: Vector3 = hit.position if not hit.is_empty() else player.global_position - player.global_basis.z * 4.0
	if point.distance_to(player.global_position) > BUILD_REACH:
		point = player.global_position + (point - player.global_position).normalized() * BUILD_REACH
	var cell := SurvivalPiece.CELL
	var center := Vector3(floorf(point.x / cell) * cell + cell * 0.5, point.y, floorf(point.z / cell) * cell + cell * 0.5)
	# On a floor or a roof, on top of it; on the ground, at its height.
	if not hit.is_empty() and hit.collider is SurvivalPiece and (hit.collider as SurvivalPiece).type in ["floor", "roof", "stairs"]:
		var under := hit.collider as SurvivalPiece
		center.y = under.global_position.y + (0.25 if under.type == "floor" else SurvivalPiece.WALL_HEIGHT + 0.2)
	else:
		center.y = world.height_at(center.x, center.z)
	var rotation_y := build_turns * PI / 2.0
	if SurvivalData.PIECES[build_piece].get("edge", false):
		center += Vector3(0, 0, -cell * 0.5).rotated(Vector3.UP, rotation_y)
	return {"at": center, "rotation": rotation_y}


func _update_ghost() -> void:
	if not building or _ghost == null:
		return
	var spot := _placement()
	if spot.is_empty():
		return
	_ghost.global_position = spot.at
	_ghost.rotation.y = spot.rotation
	_ghost.set_valid(_can_place(spot))


func _can_place(spot: Dictionary) -> bool:
	if not has_all(piece_cost()):
		return false
	for piece: SurvivalPiece in get_tree().get_nodes_in_group("survival_pieces"):
		if piece.global_position.distance_to(spot.at) < 0.4 and piece.type == build_piece:
			return false
	return spot.at.y > SurvivalWorld.WATER_LEVEL - 0.5


func place_piece() -> void:
	var spot := _placement()
	if spot.is_empty() or not _can_place(spot):
		hud.show_banner("IMPOSSIBLE ICI" if has_all(piece_cost()) else "PAS ASSEZ DE MATÉRIAUX")
		return
	var cost := piece_cost()
	for item: String in cost:
		remove(item, int(cost[item]))
	var piece := spawn_piece(build_piece, build_material, spot.at, spot.rotation)
	stats.built = int(stats.built) + 1
	Effects.burst(self, piece.global_position + Vector3.UP * 0.5, Color(1, 1, 1), 12)


func spawn_piece(type: String, piece_material: String, at: Vector3, rotation_y: float) -> SurvivalPiece:
	var piece := SurvivalPiece.new()
	piece.configure(type, piece_material)
	piece.position = at
	piece.rotation.y = rotation_y
	_pieces.add_child(piece)
	return piece


## Takes a piece down (in build mode, aimed at): half its cost back.
func dismantle() -> void:
	var camera := get_viewport().get_camera_3d()
	var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_basis.z * (BUILD_REACH + 4.0), 1)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or not hit.collider is SurvivalPiece:
		return
	var piece := hit.collider as SurvivalPiece
	var info: Dictionary = SurvivalData.PIECES[piece.type]
	if info.get("station", false):
		add("piece:" + piece.type, 1)
		for item: String in piece.content:
			add(item, int(piece.content[item]))
	elif int(info.get("cost", 0)) > 0:
		add(piece.material_id, maxi(int(info.cost) / 2, 1))
	piece.queue_free()


# --- Who comes ----------------------------------------------------------------------------------

func _update_spawns(delta: float) -> void:
	_spawn_left -= delta
	_animal_left -= delta
	_raid_left -= delta
	if is_night() and difficulty > 0:
		var wanted := mini(3 + day * 2, 14) * (2 if difficulty == 2 else 1)
		if _red_night:
			wanted = int(wanted * 1.5)
		if _spawn_left <= 0.0 and get_tree().get_nodes_in_group("survival_night").size() < wanted:
			_spawn_left = 4.0
			_spawn_creature("shadow", _ring_point(randf_range(26.0, 38.0)))
	elif not is_night():
		if _spawn_left <= 0.0:
			_spawn_left = 35.0
			if difficulty > 0 and randf() < 0.4 and get_tree().get_nodes_in_group("survival_wild").size() < 3:
				_spawn_creature("wild", _ring_point(randf_range(30.0, 45.0)))
		if _animal_left <= 0.0:
			_animal_left = 10.0
			if get_tree().get_nodes_in_group("survival_animals").size() < 6:
				_spawn_animal(_ring_point(randf_range(18.0, 40.0)))
		if _raid_left <= 0.0:
			_raid_left = 180.0
			var chests := get_tree().get_nodes_in_group("survival_pieces").filter(func(piece: SurvivalPiece) -> bool:
				return piece.type == "chest" and not piece.content.is_empty())
			if difficulty > 0 and not chests.is_empty() and randf() < 0.5:
				var chest: SurvivalPiece = chests.pick_random()
				for i in 2:
					_spawn_creature("raider", chest.global_position + Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU) * 45.0)
				hud.show_banner("DES PILLARDS APPROCHENT DE TON COFFRE")
	# Too far behind: gone.
	for group in ["survival_wild", "survival_animals"]:
		for creature: Node3D in get_tree().get_nodes_in_group(group):
			if creature.global_position.distance_to(player.global_position) > 110.0:
				creature.queue_free()


func _ring_point(radius: float) -> Vector3:
	for attempt in 12:
		var offset := Vector2.from_angle(randf() * TAU) * radius
		var x := player.global_position.x + offset.x
		var z := player.global_position.z + offset.y
		var height := world.height_at(x, z)
		if height > SurvivalWorld.WATER_LEVEL + 0.5 and world.is_ready_at(Vector3(x, 0, z)):
			return Vector3(x, height + 0.4, z)
	return player.global_position + Vector3(radius, 1.0, 0)


func _spawn_creature(kind: String, at: Vector3) -> SurvivalCreature:
	var body := ENEMY_SCENE.instantiate()
	var bolt: PackedScene = body.projectile_scene
	var power_up: PackedScene = body.power_up_scene
	body.set_script(SurvivalCreature)
	var creature := body as SurvivalCreature
	creature.projectile_scene = bolt
	creature.power_up_scene = power_up
	creature.kind = "shadow" if kind == "brute" else kind
	creature.drop_chance = 0.1
	var scaling := 1.0 + 0.12 * (day - 1)
	match kind:
		"shadow":
			creature.model_scene = load(Loadout.CHARACTER_DIR + "Zombie_Male.fbx")
			creature.weapon_id = ""
			creature.melee_damage = 8
			creature.attack_range = 1.8
			creature.max_health = roundi(8 * scaling)
			creature.move_speed = 4.2
			creature.add_to_group("survival_night")
		"brute":
			creature.model_scene = load(Boss.MODEL_DIR + "monsters/Skeleton.fbx")
			creature.model_height = 3.4
			creature.weapon_id = ""
			creature.melee_damage = 22
			creature.attack_range = 2.8
			creature.max_health = roundi(70 * scaling)
			creature.move_speed = 3.6
			creature.add_to_group("survival_night")
		"wild":
			var info: Array = WILD[world.biome_at(at.x, at.z)]
			creature.model_scene = load(Loadout.CHARACTER_DIR + str(info[0]))
			creature.weapon_id = info[1]
			creature.melee_damage = info[2]
			creature.attack_range = 2.0 if info[2] > 0 else 14.0
			creature.max_health = roundi(10 * scaling)
			creature.add_to_group("survival_wild")
		"raider":
			var heroes := Loadout.CHARACTERS.filter(func(item: Dictionary) -> bool: return not item.get("code", false))
			creature.model_scene = load(Loadout.CHARACTER_DIR + str(heroes.pick_random().model))
			creature.weapon_id = ["smg", "heavy", "revolver_1"].pick_random()
			creature.attack_range = 15.0
			creature.max_health = roundi(16 * scaling)
			creature.move_speed = 4.5
			creature.add_to_group("survival_wild")
	creature.position = at
	add_child(creature)
	if kind in ["shadow", "brute"]:
		# Night creatures: black, their glow red.
		creature._glow(Color(1.0, 0.1, 0.1) if kind == "brute" else Color(0.45, 0.1, 0.6), 0.55)
	creature.died.connect(_on_creature_died.bind(creature))
	return creature


func _spawn_animal(at: Vector3) -> void:
	var biome := world.biome_at(at.x, at.z)
	if biome in [SurvivalWorld.Biome.SNOW, SurvivalWorld.Biome.BEACH]:
		return
	var animal := SurvivalAnimal.new()
	animal.pet_id = SurvivalAnimal.KINDS.pick_random()
	animal.position = at
	add_child(animal)
	animal.died.connect(func(_animal: SurvivalAnimal) -> void:
		add("raw_meat", 2)
		add("leather", 1)
		ui.toast("+2 Viande crue, +1 Cuir"))


func _on_creature_died(creature: SurvivalCreature) -> void:
	stats.kills = int(stats.kills) + 1
	hud.set_score(int(stats.kills))
	player.on_enemy_killed()
	hud.reticle.show_kill()
	if creature.kind == "raider":
		for item: String in creature.loot:
			add(item, int(creature.loot[item]))
		add("scrap", 2)
		add("ammo", 8)
	elif creature.kind == "shadow" and randf() < 0.3:
		add("crystal", 1)
	if creature.model_height > 3.0:
		stats.red_nights = int(stats.red_nights) + 1
		Achievements.set_flag("survival_red_night")
		add("crystal", 4)
		add("metal", 4)


# --- Death -------------------------------------------------------------------------------------

func _on_player_died() -> void:
	# The backpack stays where the hero fell.
	var content := inventory.duplicate()
	inventory = {}
	hotbar = ["", "", "", "", "", ""]
	if not content.is_empty():
		var backpack := spawn_piece("chest", "wood", player.global_position, 0.0)
		backpack.type = "backpack"
		backpack.content = content
		backpack.remove_from_group("survival_pieces")
		backpack.add_to_group("survival_pieces")
	hud.show_death_title()
	await get_tree().create_timer(RESPAWN_TIME).timeout
	var at := bed_point if bed_point != Vector3.INF else spawn_point
	world.build_around(at)
	player.revive(at + Vector3.UP * 0.5)
	food = maxf(food, 60.0)
	water = maxf(water, 60.0)
	_equip_selected()
	hud.show_banner("TON SAC T'ATTEND LÀ OÙ TU ES TOMBÉ")
	if ui:
		ui.refresh()


# --- Leaving -----------------------------------------------------------------------------------

func _leave() -> void:
	if _over:
		return
	_over = true
	SurvivalSave.save_world(self)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var rewards := SurvivalSave.pay_session(self)
	hud.show_game_over(int(stats.kills) * 100 + day * 1000, 0, false, rewards.xp, rewards.unlocked, Hud.Result.LEFT)
	hud.set_result_line("Jour %d · %d créatures · %d pièces construites · monde sauvegardé" % [day, int(stats.kills), int(stats.built)])
	hud.show_rewards(rewards.credits, rewards.gems, 0)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6:
			select_slot(event.keycode - KEY_1)
		KEY_I, KEY_TAB:
			ui.toggle_inventory()
		KEY_V:
			set_building(not building)
		KEY_G:
			interact()
		KEY_T:
			rotate_piece()
		KEY_X:
			if building:
				dismantle()
