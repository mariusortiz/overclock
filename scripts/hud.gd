class_name Hud
extends CanvasLayer
## On-screen UI: reticle, health, ammo, wave, score, banners, game over screen,
## FPS counter, desktop hint and touch controls.

signal replay_pressed
signal menu_pressed
signal perk_chosen(type: Perk.Type)

const BANNER_TIME := 2.5
const FADE_TIME := 0.4

var _is_touch := DisplayServer.is_touchscreen_available()
var _game_over := false
var _flash_tween: Tween
var _banner_tween: Tween
var _perk_options: Array = []

@onready var touch_controls: TouchControls = $TouchControls
@onready var reticle: Reticle = $Reticle
@onready var pause_menu: PauseMenu = $PauseMenu
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
@onready var _pause_button: Button = $PauseButton
@onready var _boss_name: Label = $BossName
@onready var _fade: ColorRect = $Fade
@onready var _death_title: Label = $DeathTitle
@onready var _boss_bar: ProgressBar = $BossBar
@onready var _effects_label: RichTextLabel = $Effects
@onready var _perk_choice: Control = $PerkChoice
@onready var _perk_title: Label = $PerkChoice/Center/Box/Title
@onready var _perk_buttons: Array[Node] = $PerkChoice/Center/Box/Options.get_children()


func _ready() -> void:
	touch_controls.visible = _is_touch
	_banner.modulate.a = 0.0
	_replay_button.pressed.connect(replay_pressed.emit)
	_menu_button.pressed.connect(menu_pressed.emit)
	_pause_button.pressed.connect(pause_menu.open)
	pause_menu.menu_pressed.connect(menu_pressed.emit)
	for i in _perk_buttons.size():
		_perk_buttons[i].pressed.connect(_on_perk_button_pressed.bind(i))


func _process(_delta: float) -> void:
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	_desktop_hint.visible = not _is_touch and not _game_over \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED


func set_health(current: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current


## Darkens the whole screen; await it before changing what is behind.
func fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, FADE_TIME)
	await tween.finished


func fade_from_black() -> void:
	create_tween().tween_property(_fade, "color:a", 0.0, FADE_TIME)


func show_boss(boss_name: String) -> void:
	_boss_name.text = boss_name
	_boss_name.visible = true
	_boss_bar.visible = true


func set_boss_health(current: int, maximum: int) -> void:
	_boss_bar.max_value = maximum
	_boss_bar.value = current


func hide_boss() -> void:
	_boss_name.visible = false
	_boss_bar.visible = false


func set_ammo(current: int, magazine: int, reloading: bool) -> void:
	_ammo_label.text = "RECHARGE…" if reloading else "%d / %d" % [current, magazine]


func set_score(score: int) -> void:
	_score_label.text = "SCORE  %d" % score


func set_wave(number: int, enemies_left: int) -> void:
	_wave_label.text = "VAGUE %d  ·  %d robot%s" % [number, enemies_left, "" if enemies_left == 1 else "s"]


## Shows the timed power-ups (`effects`: PowerUp.Type -> seconds left) and the
## perks owned (`perks`: Perk.Type -> level).
func set_status(effects: Dictionary, perks: Dictionary) -> void:
	var lines := PackedStringArray()
	for type: PowerUp.Type in effects:
		var info: Dictionary = PowerUp.INFO[type]
		lines.append("[color=#%s]%s  %d[/color]" % [info.color.to_html(false), info.label, ceili(effects[type])])
	for type: Perk.Type in perks:
		var info: Dictionary = Perk.INFO[type]
		lines.append("[font_size=18][color=#%s]%s %d[/color][/font_size]" % [info.color.to_html(false), info.name, perks[type]])
	var text := "\n".join(lines)
	if _effects_label.text != text:
		_effects_label.text = text


## Offers perks to pick from. `levels` (Perk.Type -> level) are the ones already owned.
func show_perk_choice(title: String, options: Array, levels: Dictionary) -> void:
	_perk_options = options
	_perk_title.text = title
	for i in _perk_buttons.size():
		var button: Button = _perk_buttons[i]
		var info: Dictionary = Perk.INFO[options[i]]
		button.text = "%s\n\n%s\n\nNiveau %d" % [info.name, info.description, levels.get(options[i], 0) + 1]
		button.add_theme_color_override("font_color", info.color)
	_perk_choice.visible = true


func _on_perk_button_pressed(index: int) -> void:
	_perk_choice.visible = false
	perk_chosen.emit(_perk_options[index])


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


## First beat of the death sequence: big title over the slowed-down game.
func show_death_title() -> void:
	_game_over = true
	pause_menu.enabled = false
	_pause_button.visible = false
	touch_controls.visible = false
	touch_controls.process_mode = Node.PROCESS_MODE_DISABLED
	reticle.visible = false
	_death_title.visible = true


func show_game_over(score: int, best: int, is_record: bool) -> void:
	_death_title.visible = false
	_game_over = true
	pause_menu.enabled = false
	_pause_button.visible = false
	touch_controls.visible = false
	touch_controls.process_mode = Node.PROCESS_MODE_DISABLED
	reticle.visible = false
	_final_score.text = "Score : %d" % score
	_best_score.text = "Nouveau record !" if is_record else "Record : %d" % best
	_game_over_screen.visible = true
