class_name Hud
extends CanvasLayer
## On-screen UI: reticle, FPS counter, desktop hint, touch controls.

var _is_touch := DisplayServer.is_touchscreen_available()

@onready var touch_controls: TouchControls = $TouchControls
@onready var reticle: Reticle = $Reticle
@onready var _fps_label: Label = $FpsLabel
@onready var _desktop_hint: Label = $DesktopHint


func _ready() -> void:
	touch_controls.visible = _is_touch


func _process(_delta: float) -> void:
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	_desktop_hint.visible = not _is_touch and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
