class_name Hud
extends CanvasLayer
## On-screen UI: reticle, health, ammo, wave, score, banners, game over screen,
## FPS counter, desktop hint and touch controls.

signal replay_pressed
signal menu_pressed

const BANNER_TIME := 2.5

var _is_touch := DisplayServer.is_touchscreen_available()
var _game_over := false
var _flash_tween: Tween
var _banner_tween: Tween

@onready var touch_controls: TouchControls = $TouchControls
@onready var reticle: Reticle = $Reticle
@onready var _fps_label: Label = $FpsLabel
@onready var _desktop_hint: Label = $DesktopHint
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _damage_flash: ColorRect = $DamageFlash
@onready var _wave_label: Label = $WaveLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _ammo_label: Label = $AmmoLabel
@onready var _banner: Label = $Banner
@onready var _game_over_screen: Control = $GameOver
@onready var _final_score: Label = $GameOver/Center/Box/Score
@onready var _best_score: Label = $GameOver/Center/Box/Best
@onready var _replay_button: Button = $GameOver/Center/Box/Replay
@onready var _menu_button: Button = $GameOver/Center/Box/Menu
@onready var _effects_label: RichTextLabel = $Effects


func _ready() -> void:
	touch_controls.visible = _is_touch
	_banner.modulate.a = 0.0
	_replay_button.pressed.connect(replay_pressed.emit)
	_menu_button.pressed.connect(menu_pressed.emit)


func _process(_delta: float) -> void:
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	_desktop_hint.visible = not _is_touch and not _game_over \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED


func set_health(current: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current


func set_ammo(current: int, magazine: int, reloading: bool) -> void:
	_ammo_label.text = "RECHARGE…" if reloading else "%d / %d" % [current, magazine]


func set_score(score: int) -> void:
	_score_label.text = "SCORE  %d" % score


func set_wave(number: int, enemies_left: int) -> void:
	_wave_label.text = "VAGUE %d  ·  %d robot%s" % [number, enemies_left, "" if enemies_left == 1 else "s"]


## `effects` maps a PowerUp.Type to its seconds left.
func set_effects(effects: Dictionary) -> void:
	var lines := PackedStringArray()
	for type: PowerUp.Type in effects:
		var info: Dictionary = PowerUp.INFO[type]
		lines.append("[color=#%s]%s  %d[/color]" % [info.color.to_html(false), info.label, ceili(effects[type])])
	var text := "\n".join(lines)
	if _effects_label.text != text:
		_effects_label.text = text


func flash_damage() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_damage_flash.color.a = 0.35
	_flash_tween = create_tween()
	_flash_tween.tween_property(_damage_flash, "color:a", 0.0, 0.3)


## Shows a short message in the upper part of the screen, then fades it out.
func show_banner(text: String) -> void:
	if _banner_tween:
		_banner_tween.kill()
	_banner.text = text
	_banner.modulate.a = 1.0
	_banner_tween = create_tween()
	_banner_tween.tween_interval(BANNER_TIME)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.5)


func show_game_over(score: int, best: int, is_record: bool) -> void:
	_game_over = true
	touch_controls.visible = false
	touch_controls.process_mode = Node.PROCESS_MODE_DISABLED
	reticle.visible = false
	_final_score.text = "Score : %d" % score
	_best_score.text = "Nouveau record !" if is_record else "Record : %d" % best
	_game_over_screen.visible = true
