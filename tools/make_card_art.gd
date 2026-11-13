extends Node
## Renders the art of the collectible cards (Cards.CATALOG) whose subject is
## a model: heroes, enemies, bosses, ships, weapons, the trophy. Each is
## framed alone on a backdrop in its rarity's color and saved as
## assets/cards/<id>.jpg. Cards whose art is an "image" (arenas, anime
## episodes) get theirs from the videos, by hand (see README).
##
## Needs a display (not --headless):
##   godot --rendering-driver opengl3 res://scenes/tools/card_art.tscn
## "-- --only=card_x" renders a single card; "--size=640 --wide" renders it
## bigger and framed wider, for tools/fit_card_art.py to crop around the
## subject (bosses, whose animated models overflow their bounds).

const SIZE := 320
const OUT_DIR := "res://assets/cards/"

var _viewport := SubViewport.new()
var _camera := Camera3D.new()
var _stage := Node3D.new()
var _environment := Environment.new()


func _ready() -> void:
	_viewport.size = Vector2i(SIZE, SIZE)
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_environment.background_mode = Environment.BG_COLOR
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color(0.75, 0.75, 0.85)
	_environment.ambient_light_energy = 0.9
	var world := WorldEnvironment.new()
	world.environment = _environment
	_viewport.add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, 30, 0)
	key.light_energy = 1.2
	_viewport.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-20, 200, 0)
	rim.light_energy = 0.8
	_viewport.add_child(rim)
	_viewport.add_child(_stage)
	_viewport.add_child(_camera)
	_camera.current = true
	_camera.fov = 30.0
	_render_all.call_deferred()


var _wide := false


func _render_all() -> void:
	var only := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--only="):
			only = argument.get_slice("=", 1)
		elif argument.begins_with("--size="):
			_viewport.size = Vector2i.ONE * argument.get_slice("=", 1).to_int()
		elif argument == "--wide":
			_wide = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for card: Dictionary in Cards.all_cards():
		if card.art[0] == "image" or (only != "" and card.id != only):
			continue
		await _render(card)
	get_tree().quit()


func _render(card: Dictionary) -> void:
	for child in _stage.get_children():
		child.queue_free()
	await get_tree().process_frame
	var color: Color = Cards.RARITY[card.rarity].color
	_environment.background_color = color.lerp(Color.WHITE, 0.25)
	var subject := _subject(card.art[0], card.art[1])
	if subject == null:
		push_warning("No art for %s" % card.id)
		return
	_stage.add_child(subject)
	# Let the models settle (skeletons, first animation frame).
	for i in 4:
		await get_tree().process_frame
	_frame(subject, card.art[0])
	for i in 3:
		await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	image.save_jpg(ProjectSettings.globalize_path(OUT_DIR + card.id + ".jpg"), 0.88)
	print("CARD ART %s" % card.id)


func _subject(kind: String, reference: String) -> Node3D:
	match kind:
		"hero":
			var item: Dictionary = Loadout.find(reference).item
			return _character(Loadout.CHARACTER_DIR + str(item.model), &"victory")
		"enemy":
			return _character(Loadout.CHARACTER_DIR + reference, &"idle")
		"elite":
			var elite := _character(Loadout.CHARACTER_DIR + reference, &"aim")
			var gold := StandardMaterial3D.new()
			gold.albedo_color = Color(1.0, 0.8, 0.25)
			gold.metallic = 0.7
			gold.roughness = 0.3
			for mesh: MeshInstance3D in elite.find_children("*", "MeshInstance3D", true, false):
				mesh.material_overlay = null
				mesh.material_override = gold
			return elite
		"glow":
			# An enemy with the glow its role gives it in the game (sniper, kamikaze).
			var parts := reference.split(":")
			var glowing := _character(Loadout.CHARACTER_DIR + parts[0], &"aim")
			var overlay := StandardMaterial3D.new()
			overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			overlay.albedo_color = Color(parts[1], 0.18)
			for mesh: MeshInstance3D in glowing.find_children("*", "MeshInstance3D", true, false):
				mesh.material_overlay = overlay
			return glowing
		"boss":
			return _character(Boss.MODEL_DIR + reference, &"idle")
		"titan":
			var titan := _character(Boss.MODEL_DIR + str(Boss.INFO[Boss.Kind.TITAN].model), &"idle")
			var material := StandardMaterial3D.new()
			material.albedo_texture = load(Boss.TITAN_TEXTURE)
			if reference == "red":
				material.albedo_color = Color(1.0, 0.45, 0.4)
			for mesh: MeshInstance3D in titan.find_children("*", "MeshInstance3D", true, false):
				mesh.material_override = material
			return titan
		"ship":
			var ship := RaceShip.new()
			ship.configure(Loadout.find(reference).item)
			var holder := Node3D.new()
			holder.add_child(ship)
			ship.rotation = Vector3(0.45, 2.4, 0.15)
			return holder
		"gun", "gun_skin":
			var parts := reference.split(":")
			var skin: Dictionary = Loadout.find(parts[1]).item if parts.size() > 1 else Loadout.SKINS[0]
			var gun := Loadout.instantiate_weapon(Loadout.find(parts[0]).item, skin)
			var holder := Node3D.new()
			holder.add_child(gun)
			gun.rotation = Vector3(0.1, PI / 2.0 + 0.35, 0.0)
			return holder
		"melee":
			var blade := Loadout.instantiate_melee(Loadout.find(reference).item, Loadout.SKINS[0])
			var holder := Node3D.new()
			holder.add_child(blade)
			blade.rotation = Vector3(0.0, 0.6, -0.6)
			return holder
		"trophy":
			return Trophy.new()
		"virus":
			# The Titan's body in black, glowing green (see Boss._dress_virus).
			var virus := _character(Boss.MODEL_DIR + str(Boss.INFO[Boss.Kind.VIRUS].model), &"idle")
			var body := StandardMaterial3D.new()
			body.albedo_color = Color(0.08, 0.12, 0.09)
			body.albedo_texture = load(Boss.TITAN_TEXTURE)
			var glow := StandardMaterial3D.new()
			glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			glow.albedo_color = Color(0.2, 1.0, 0.45, 0.12)
			for mesh: MeshInstance3D in virus.find_children("*", "MeshInstance3D", true, false):
				mesh.material_override = body
				mesh.material_overlay = glow
			return virus
		"dance":
			# A hero caught in the dance's most telling pose.
			var parts := reference.split(":")
			var dance := Dances.find(parts[0])
			var item: Dictionary = Loadout.find(parts[1]).item
			var holder := _character(Loadout.CHARACTER_DIR + str(item.model), dance.get("animation", &"idle"))
			var dancer := holder.get_child(0) as CharacterModel
			var poses: Array = dance.get("poses", [{}])
			dancer.pose.targets = poses[mini(1, poses.size() - 1)]
			dancer.pose.weight = 1.0
			return holder
	return null


func _character(path: String, action: StringName) -> Node3D:
	var model: Node3D = load(path).instantiate()
	model.set_script(CharacterModel)
	var character := model as CharacterModel
	var holder := Node3D.new()
	holder.add_child(character)
	holder.rotation.y = PI + 0.35
	character.play(action)
	return holder


## Points the camera at the subject so that it fills the picture.
func _frame(subject: Node3D, kind: String) -> void:
	var bounds := AABB()
	var first := true
	for mesh: MeshInstance3D in subject.find_children("*", "MeshInstance3D", true, false):
		var box := mesh.global_transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	var center := bounds.get_center()
	var radius := bounds.size.length() * 0.5
	# Characters: a little above the middle, so the face is in the picture.
	if kind in ["hero", "enemy", "elite", "glow", "boss", "titan", "virus", "dance"]:
		center.y += bounds.size.y * 0.02
		radius *= 0.7
	else:
		radius *= 0.72
	if _wide:
		radius *= 2.0
	var distance := radius / tan(deg_to_rad(_camera.fov * 0.5)) * 1.05
	_camera.look_at_from_position(center + Vector3(0.0, radius * 0.25, distance), center)
