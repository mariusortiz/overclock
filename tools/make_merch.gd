extends AnimeDirector
## Renders the print files of the merchandise (merch/): the game's heroes,
## ships and Titan in the anime's cel-shaded style, at print resolution, most
## on a transparent background (for T-shirts and stickers).
##
## Needs a display (not --headless):
##   godot --rendering-driver opengl3 res://scenes/tools/merch.tscn
## The logo and the speech bubble are SVG files, drawn by hand (merch/).

const OUT_DIR := "res://merch/"
const SIZE := 2400
const STICKER_SIZE := 1400

var _shot := SubViewport.new()
var _shot_camera := Camera3D.new()


func _init() -> void:
	duration = 1.0


func _story() -> void:
	_layer.visible = false
	_dolly(Vector3(0, 2, 10), Vector3(0, 2, 10), Vector3.ZERO, Vector3.ZERO, 1.0)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_shot.transparent_bg = true
	_shot.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_shot)
	_shot.add_child(_shot_camera)
	_shot_camera.current = true
	# Thicker ink lines at print size.
	_outline.set_shader_parameter("width", 9.0)

	# The squad, heroic, side by side.
	_clear_studio()
	var ids := ["captain", "soldier", "kunoichi", "ronin"]
	for index in ids.size():
		var hero := _hero(ids[index], Vector3(-2.4 + 1.6 * index, 0, -absf(index - 1.5) * 0.4), PI)
		hero.play(&"victory" if index % 3 == 0 else &"aim", true)
	await _capture("escouade", Vector2i(SIZE, SIZE), Vector3(0, 1.4, 11.0), Vector3(0, 0.95, 0), 34.0)

	# Vipère and the Soldier, face to face.
	_clear_studio()
	var soldier := _hero("soldier", Vector3(-1.5, 0, 0), -PI / 2.0 - 0.35)
	var vipere := _hero("sand_ghost", Vector3(1.5, 0, 0), PI / 2.0 + 0.35)
	soldier.play(&"aim")
	vipere.play(&"aim")
	await _capture("rivaux", Vector2i(SIZE, SIZE), Vector3(0, 1.2, 7.5), Vector3(0, 0.95, 0), 34.0)

	# The fleet, in formation.
	_clear_studio()
	var colors := [CYAN, RED, GOLD, Color(1.0, 0.5, 0.8)]
	for index in 4:
		var ship := RaceShip.new()
		ship.configure(Loadout.SHIPS[[0, 1, 5, 7][index]])
		_set.add_child(ship)
		ship.position = Vector3(-5.4 + 3.6 * index, 1.2 * index - (1.2 if index == 3 else 0.0), 0.0)
		ship.rotation = Vector3(0.45, 0.85, 0.25)
		ship.boost(100.0)
		_toon(ship)
	await _capture("flotte", Vector2i(SIZE, SIZE), Vector3(0, 8, 28), Vector3(0, 1.2, 0), 32.0)

	# Stickers: one hero each, die-cut.
	for id: String in ["soldier", "kunoichi", "sand_ghost", "ronin", "captain"]:
		_clear_studio()
		var hero := _hero(id, Vector3.ZERO, PI + 0.35)
		hero.play(&"victory", true)
		await _capture("sticker_" + id, Vector2i(STICKER_SIZE, STICKER_SIZE), Vector3(0, 1.1, 4.4), Vector3(0, 0.9, 0), 30.0)

	# Poster: the red Titan over the city, the heroes from behind.
	_load_arena(4)
	_spawn_titan(STAGE + Vector3(0, 0, -8), 14.0, Color(1.0, 0.45, 0.4))
	for index in 4:
		var id: String = ["soldier", "kunoichi", "captain", "ronin"][index]
		_hero(id, STAGE + Vector3(-1.8 + 1.2 * index, 0, 3.5), 0.0).play(&"aim")
	_shot.transparent_bg = false
	await _capture("affiche_titan", Vector2i(1600, 2400), STAGE + Vector3(0, 0.5, 9.5), STAGE + Vector3(0, 6.5, -6), 62.0)
	get_tree().quit()


## An empty studio: lights, no backdrop (the picture is transparent).
func _clear_studio() -> void:
	_clear_set()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.8, 0.8, 0.9)
	environment.ambient_light_energy = 1.0
	var world := WorldEnvironment.new()
	world.environment = environment
	_set.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 25, 0)
	sun.light_energy = 1.2
	_set.add_child(sun)
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))


## Renders the set from `from` looking at `at`, `size` pixels, into merch/<name>.png.
func _capture(file: String, size: Vector2i, from: Vector3, at: Vector3, fov: float) -> void:
	_shot.size = size
	_shot_camera.fov = fov
	_shot_camera.far = 400.0
	_shot_camera.look_at_from_position(from, at)
	for i in 6:
		await RenderingServer.frame_post_draw
	var image := _shot.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT_DIR + file + ".png"))
	print("MERCH %s" % file)
