extends Node
## Renders the art of the collectible cards (Cards.CATALOG) whose subject is
## a model: heroes, enemies, bosses, ships, weapons, the trophy. Each is
## framed alone on a backdrop in its rarity's color and saved as
## assets/cards/<id>.jpg. Cards whose art is an "image" (arenas, anime
## episodes) get theirs from the videos, by hand (see README).
##
## Needs a display (not --headless):
##   godot --rendering-driver opengl3 res://scenes/tools/card_art.tscn
## "-- --only=card_x" renders a single card.

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


func _render_all() -> void:
	var only := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--only="):
			only = argument.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for card: Dictionary in Cards.CATALOG:
		if card.art[0] == "image" or (only != "" and card.id != only):
			continue
		await _render(card)
	get_tree().quit()


func _render(card: Dictionary) -> void:
	for child in _stage.get_children():
		child.queue_free()
	await get_tree().process_frame
	var color: Color = Cards.RARITY[card.rarity].color
	_environment.background_color = color.darkened(0.55)
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
	if kind in ["hero", "enemy", "elite", "boss", "titan"]:
		center.y += bounds.size.y * 0.08
		radius *= 0.85
	var distance := radius / tan(deg_to_rad(_camera.fov * 0.5)) * 1.05
	_camera.look_at_from_position(center + Vector3(0.0, radius * 0.25, distance), center)
