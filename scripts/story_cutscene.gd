extends Node
## Plays the chapter's scene (scripts/story/chNN.gd), with a button to skip
## it, then opens the mission.

const SKIP_DELAY := 1.0

var _leaving := false
## Test option "-- --chapter=3": plays that chapter's scene alone and quits.
var _test := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--chapter="):
			Story.begin(argument.get_slice("=", 1).to_int() - 1)
			_test = true
	# A StoryScene (season 1) or a Season2Scene: both say `done` at the end.
	var scene: Node = load("res://scripts/story/ch%02d.gd" % (Story.chapter + 1)).new()
	add_child(scene)
	scene.connect(&"done", _to_mission)
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var skip := Button.new()
	skip.text = "PASSER  >"
	skip.custom_minimum_size = Vector2(200, 64)
	skip.add_theme_font_size_override("font_size", 24)
	skip.anchor_left = 1.0
	skip.anchor_right = 1.0
	skip.anchor_top = 1.0
	skip.anchor_bottom = 1.0
	skip.offset_left = -232
	skip.offset_right = -32
	skip.offset_top = -100
	skip.offset_bottom = -36
	skip.modulate.a = 0.0
	layer.add_child(skip)
	skip.create_tween().tween_property(skip, "modulate:a", 1.0, 0.3).set_delay(SKIP_DELAY)
	skip.pressed.connect(_to_mission)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_to_mission()


func _to_mission() -> void:
	if _leaving:
		return
	_leaving = true
	if _test:
		print("STORY SCENE %d done" % (Story.chapter + 1))
		get_tree().quit()
		return
	get_tree().change_scene_to_file.call_deferred(Story.mission_scene())
