class_name Hud
extends CanvasLayer
## On-screen UI: reticle, health bar, damage flash, FPS counter, desktop hint, touch controls.

var _is_touch := DisplayServer.is_touchscreen_available()
var _flash_tween: Tween

@onready var touch_controls: TouchControls = $TouchControls
@onready var reticle: Reticle = $Reticle
@onready var _fps_label: Label = $FpsLabel
@onready var _desktop_hint: Label = $DesktopHint
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _damage_flash: ColorRect = $DamageFlash
@onready var _death_label: Label = $DeathLabel


func _ready() -> void:
	touch_controls.visible = _is_touch


func _process(_delta: float) -> void:
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	_desktop_hint.visible = not _is_touch and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED


func set_health(current: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current


func flash_damage() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_damage_flash.color.a = 0.35
	_flash_tween = create_tween()
	_flash_tween.tween_property(_damage_flash, "color:a", 0.0, 0.3)


func show_death() -> void:
	_death_label.visible = true
