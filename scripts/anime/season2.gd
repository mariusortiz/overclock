class_name Season2Episode
extends AnimeDirector
## What the episodes of season 2 share (episodes 11 to 20, "Le Créateur"):
## the Virus that corrupts the world, shown as screen glitches and green-black
## corrupted enemies, and Le Créateur, the cow-headed man who wrote the game,
## who appears and vanishes like a glitch himself.
##
## Kept apart from AnimeDirector so that season 1 is not rendered again when
## season 2 changes (see .github/workflows/anime.yml).

const VIRUS := Color(0.2, 1.0, 0.45)
const VIRUS_DARK := Color(0.05, 0.12, 0.07)

var _glitch_left := 0.0
var _glitch_bands: Array[ColorRect] = []


func _ready() -> void:
	super()
	for i in 6:
		var band := ColorRect.new()
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.visible = false
		_layer.add_child(band)
		_glitch_bands.append(band)


func _process(delta: float) -> void:
	super(delta)
	_glitch_left = maxf(_glitch_left - delta, 0.0)
	var screen := get_viewport().get_visible_rect().size
	for band in _glitch_bands:
		band.visible = _glitch_left > 0.0 and randf() < 0.7
		if band.visible:
			# Torn strips of the picture, in the Virus' colors.
			band.position = Vector2(randf_range(-80, 80), randf() * screen.y)
			band.size = Vector2(screen.x + 160, randf_range(4, 38))
			band.color = Color([VIRUS, MAGENTA, Color.BLACK, Color.WHITE].pick_random(), randf_range(0.25, 0.6))


## An arena after space: the camera's reach back to an arena's, or the
## ground can drop out of the picture.
func _load_arena(index: int) -> void:
	super(index)
	_camera.far = 400.0


## Narration, smaller than season 1's and wrapped when too long for the
## screen (a long line used to run off it).
func _narrate(text: String, seconds: float, big := false) -> void:
	var screen := get_viewport().get_visible_rect().size
	var font_size := 44 if big else 24
	var room := screen.x - 160.0
	_narration.text = text
	_narration.add_theme_font_size_override("font_size", font_size)
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if big else HORIZONTAL_ALIGNMENT_LEFT
	var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_narration.custom_minimum_size.x = minf(width + 4.0, room)
	_narration_box.reset_size()
	_layer.move_child(_narration_box, -1)
	var box := _narration_box.get_combined_minimum_size()
	_narration_box.position = (screen - box) / 2.0 if big else Vector2(60, 110)
	var tween := create_tween()
	tween.tween_property(_narration_box, "modulate:a", 1.0, 0.25)
	tween.tween_interval(seconds - 0.5)
	tween.tween_property(_narration_box, "modulate:a", 0.0, 0.25)


## The picture tears and jumps for `seconds`: the Virus is near.
func _glitch(seconds: float) -> void:
	_glitch_left = seconds
	_shake = maxf(_shake, 0.12)


## Le Créateur, standing at `at`. He carries his gun only when asked.
func _creator(at: Vector3, facing: float, gun := "none") -> CharacterModel:
	return _hero("createur", at, facing, gun)


## An enemy taken by the Virus: a green glow over it.
func _corrupted(at: Vector3, facing: float, action: StringName) -> Enemy:
	var enemy := _enemy(at, facing, action)
	_corrupt(enemy)
	return enemy


func _corrupt(node: Node) -> void:
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(VIRUS, 0.35)
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = glow


## What to show or hide for `model`: its own pivot (characters, enemies,
## bosses), or the model itself when it sits right in the set (ships):
## hiding the set would hide everything.
func _pivot_of(model: Node3D) -> Node3D:
	var parent := model.get_parent()
	if parent is Node3D and parent != _set:
		return parent
	return model


## Someone appears like a glitch: he flickers into view in a burst of green.
func _appear(model: Node3D, seconds := 0.6) -> void:
	var pivot := _pivot_of(model)
	Effects.burst(_set, model.global_position + Vector3.UP, VIRUS, 40)
	var tween := create_tween()
	for i in 6:
		tween.tween_callback(func() -> void: pivot.visible = i % 2 == 1)
		tween.tween_interval(seconds / 6.0)
	tween.tween_callback(func() -> void: pivot.visible = true)


## He flickers out of view and is gone.
func _vanish(model: Node3D, seconds := 0.6) -> void:
	var pivot := _pivot_of(model)
	var tween := create_tween()
	for i in 6:
		tween.tween_callback(func() -> void: pivot.visible = i % 2 == 1)
		tween.tween_interval(seconds / 6.0)
	tween.tween_callback(func() -> void:
		pivot.visible = false
		Effects.burst(_set, model.global_position + Vector3.UP, VIRUS, 40))


## The Virus itself, given a body: a black Titan with a green glow.
func _virus_titan(at: Vector3, height := TITAN_HEIGHT) -> CharacterModel:
	var titan := _spawn_titan(at, height, Color(0.12, 0.16, 0.13))
	_corrupt(titan)
	return titan


## A ship of Loadout.SHIPS (its hull and colors) on the current circuit.
func _ship_of(id: String, display_name: String, distance: float, offset: Vector2, pace := 1.0) -> RaceShip:
	var ship := RaceShip.new()
	ship.configure(Loadout.find(id).item)
	ship.display_name = display_name
	ship.skill = pace
	ship.distance = distance
	ship.offset = offset
	_set.add_child(ship)
	ship.speed = RaceShip.BASE_SPEED * pace
	ship.fly(0.0, Vector2.ZERO, _track)
	_toon(ship)
	_flyers.append([ship, offset])
	return ship
