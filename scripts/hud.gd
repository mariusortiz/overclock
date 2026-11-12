class_name Hud
extends CanvasLayer
## On-screen UI: reticle, health, ammo, wave, score, banners, game over screen,
## FPS counter, desktop hint and touch controls.

signal replay_pressed
signal menu_pressed
## The player gave up the game from the pause menu.
signal quit_pressed
## A dance was picked in the dance wheel (index in Dances.LIST).
signal dance_chosen(index: int)
signal perk_chosen(type: Perk.Type)
## Answer to the choice offered after a boss: go on, or go home with the XP.
signal exit_chosen(leave: bool)

## How a game ended.
enum Result { DEATH, VICTORY, LEFT, QUIT }

const BANNER_TIME := 2.5
const FADE_TIME := 0.4
const ULTIMATE_READY_COLOR := Color(1.0, 0.85, 0.2)
## Below this share of health, the edges of the screen beat red.
const LOW_HEALTH := 0.3

var _is_touch := DisplayServer.is_touchscreen_available()
var _game_over := false
var _flash_tween: Tween
var _banner_tween: Tween
var _perk_options: Array = []
var _hint := Label.new()
var _health_number := Label.new()
var _dance_wheel := Control.new()
var _low_health := TextureRect.new()
var _health_ratio := 1.0
var _hurt_marks := DamageMarks.new()
var _streak := Label.new()
var _streak_tween: Tween
var _countdown := Label.new()
var _ultimate_was_ready := false
var _wheel_mouse_was_captured := false
var _hint_tween: Tween

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
@onready var _ultimate_label: Label = $UltimateLabel
@onready var _banner: Label = $Banner
@onready var _game_over_screen: Control = $GameOver
@onready var _end_title: Label = $GameOver/Center/Box/Title
@onready var _final_score: Label = $GameOver/Center/Box/Score
@onready var _best_score: Label = $GameOver/Center/Box/Best
@onready var _xp_label: Label = $GameOver/Center/Box/Xp
@onready var _replay_button: Button = $GameOver/Center/Box/Replay
@onready var _menu_button: Button = $GameOver/Center/Box/Menu
@onready var _pause_button: Button = $PauseButton
@onready var _boss_name: Label = $BossName
@onready var _fade: ColorRect = $Fade
@onready var _death_title: Label = $DeathTitle
@onready var _boss_bar: ProgressBar = $BossBar
@onready var _effects_label: RichTextLabel = $Effects
@onready var _perk_choice: Control = $PerkChoice
@onready var _exit_choice: Control = $ExitChoice
@onready var _exit_title: Label = $ExitChoice/Center/Box/Title
@onready var _continue_button: Button = $ExitChoice/Center/Box/Options/Continue
@onready var _leave_button: Button = $ExitChoice/Center/Box/Options/Leave
@onready var _perk_title: Label = $PerkChoice/Center/Box/Title
@onready var _perk_buttons: Array[Node] = $PerkChoice/Center/Box/Options.get_children()


func _ready() -> void:
	touch_controls.visible = _is_touch
	# On touch screens the ULTI button shows the gauge itself.
	_ultimate_label.visible = not _is_touch
	_build_health_number()
	_banner.modulate.a = 0.0
	_replay_button.pressed.connect(replay_pressed.emit)
	_menu_button.pressed.connect(menu_pressed.emit)
	_pause_button.pressed.connect(pause_menu.open)
	pause_menu.menu_pressed.connect(quit_pressed.emit)
	for i in _perk_buttons.size():
		_perk_buttons[i].pressed.connect(_on_perk_button_pressed.bind(i))
	_continue_button.pressed.connect(_on_exit_button_pressed.bind(false))
	_build_hint()
	_build_dance_wheel()
	_build_low_health()
	_hurt_marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hurt_marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hurt_marks)
	move_child(_hurt_marks, reticle.get_index())
	_setup_center_label(_streak, 34, Color(1.0, 0.24, 0.95), 0.62)
	_setup_center_label(_countdown, 110, Color(0.16, 0.83, 1.0), 0.4)
	_leave_button.pressed.connect(_on_exit_button_pressed.bind(true))


func _process(_delta: float) -> void:
	_fps_label.visible = Settings.show_fps
	# Low health: the edges of the screen beat red.
	var danger := clampf((LOW_HEALTH - _health_ratio) / LOW_HEALTH, 0.0, 1.0)
	_low_health.modulate.a = danger * (0.55 + 0.35 * sin(Time.get_ticks_msec() / 1000.0 * (4.0 + danger * 4.0)))
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	_desktop_hint.visible = not _is_touch and not _game_over \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED


func set_health(current: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current
	_health_number.text = str(current)
	_health_ratio = float(current) / maxi(maximum, 1)


## Health in figures, on the bar.
func _build_health_number() -> void:
	_health_number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_health_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_health_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_health_number.add_theme_font_size_override("font_size", 22)
	_health_number.add_theme_color_override("font_outline_color", Color.BLACK)
	_health_number.add_theme_constant_override("outline_size", 6)
	_health_number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_bar.add_child(_health_number)


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
	# Red when the magazine is nearly empty.
	var low := not reloading and current <= ceili(magazine * 0.25)
	_ammo_label.modulate = Color(1.0, 0.35, 0.3) if low else Color.WHITE


## `ratio`: charge of the ultimate, from 0 to 1.
func set_ultimate(ratio: float) -> void:
	touch_controls.set_ultimate(ratio)
	var is_ready := ratio >= 1.0
	if is_ready and not _ultimate_was_ready:
		show_banner("ULTI PRÊTE")
		if Settings.vibration_enabled:
			Input.vibrate_handheld(60)
	_ultimate_was_ready = is_ready
	var text := "ULTI PRÊTE" if is_ready else "ULTI  %d %%" % floori(ratio * 100.0)
	if is_ready and not _is_touch:
		text += "  [E]"
	if _ultimate_label.text != text:
		_ultimate_label.text = text
		_ultimate_label.modulate = ULTIMATE_READY_COLOR if is_ready else Color(1, 1, 1, 0.6)


func set_score(score: int) -> void:
	_score_label.text = "SCORE  %d" % score


func set_wave(number: int, enemies_left: int) -> void:
	_wave_label.text = "VAGUE %d  ·  %d ennemi%s" % [number, enemies_left, "" if enemies_left == 1 else "s"]


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


## After a boss: go on to `next_arena`, or go back to the menu with `xp`.
func show_exit_choice(next_arena: String, xp: int, endless := false) -> void:
	_exit_title.text = "TITAN VAINCU" if endless else "BOSS VAINCU"
	_continue_button.text = "CONTINUER\n\nDirection : %s\n\nMourir plus loin ne rapporte que la moitié de l'XP" % next_arena
	if endless:
		_continue_button.text = "MODE SANS FIN\n\nLes arènes reviennent,\nles boss plus forts\n\nMourir ne rapporte que la moitié de l'XP"
	_leave_button.text = "RENTRER AU MENU\n\nEncaisser toute l'XP\n\n+%d XP" % xp
	_leave_button.add_theme_color_override("font_color", ULTIMATE_READY_COLOR)
	_exit_choice.visible = true


func _on_exit_button_pressed(leave: bool) -> void:
	_exit_choice.visible = false
	exit_chosen.emit(leave)


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


## A red mark on the edge of the screen, toward where a hit came from.
func show_hurt_from(from: Vector3) -> void:
	_hurt_marks.add(from)


## "DOUBLÉ", "TRIPLÉ"…: several kills in a row.
func show_streak(text: String) -> void:
	_streak.text = text
	_streak.scale = Vector2.ONE * 1.4
	_streak.pivot_offset = _streak.size / 2.0
	if _streak_tween:
		_streak_tween.kill()
	_streak_tween = create_tween()
	_streak_tween.tween_property(_streak, "modulate:a", 1.0, 0.08)
	_streak_tween.parallel().tween_property(_streak, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	_streak_tween.tween_interval(1.0)
	_streak_tween.tween_property(_streak, "modulate:a", 0.0, 0.4)


## The big 3, 2, 1 before a wave.
func show_countdown(seconds: int) -> void:
	_countdown.text = str(seconds)
	_countdown.pivot_offset = _countdown.size / 2.0
	_countdown.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_countdown, "scale", Vector2.ONE, 0.25).from(Vector2.ONE * 1.6).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(0.35)
	tween.tween_property(_countdown, "modulate:a", 0.0, 0.3)


func _setup_center_label(label: Label, font_size: int, color: Color, anchor_y: float) -> void:
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = anchor_y
	label.anchor_bottom = anchor_y
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate.a = 0.0
	add_child(label)
	move_child(label, pause_menu.get_index())


## Red edges, shown when health is low.
func _build_low_health() -> void:
	var falloff := Gradient.new()
	falloff.set_color(0, Color(0.8, 0, 0, 0))
	falloff.set_color(1, Color(0.8, 0, 0, 0.75))
	falloff.set_offset(0, 0.6)
	var texture := GradientTexture2D.new()
	texture.gradient = falloff
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 1.0)
	_low_health.texture = texture
	_low_health.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_low_health.stretch_mode = TextureRect.STRETCH_SCALE
	_low_health.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_low_health.modulate.a = 0.0
	add_child(_low_health)
	move_child(_low_health, 0)


## Opens or closes the dance wheel; the game goes on meanwhile.
func toggle_dance_wheel() -> void:
	if _game_over:
		return
	_dance_wheel.visible = not _dance_wheel.visible
	if _dance_wheel.visible:
		_wheel_mouse_was_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif _wheel_mouse_was_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Six round buttons in a ring around the middle of the screen.
func _build_dance_wheel() -> void:
	const RADIUS := 190.0
	const BUTTON_SIZE := Vector2(190, 70)
	_dance_wheel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dance_wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dance_wheel.visible = false
	add_child(_dance_wheel)
	move_child(_dance_wheel, pause_menu.get_index())
	var middle := Control.new()
	middle.anchor_left = 0.5
	middle.anchor_right = 0.5
	middle.anchor_top = 0.5
	middle.anchor_bottom = 0.5
	middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dance_wheel.add_child(middle)
	var title := Label.new()
	title.text = "DANSES"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.16, 0.83, 1.0))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 8)
	title.position = Vector2(-70, -20)
	title.size = Vector2(140, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	middle.add_child(title)
	var count := Dances.LIST.size()
	for index in count:
		var angle := -PI / 2.0 + TAU * index / count
		var button := Button.new()
		button.text = Dances.LIST[index].name
		button.add_theme_font_size_override("font_size", 20)
		button.size = BUTTON_SIZE
		button.position = Vector2(cos(angle), sin(angle)) * RADIUS * Vector2(1.5, 1.0) - BUTTON_SIZE / 2.0
		button.pressed.connect(_on_dance_button_pressed.bind(index))
		middle.add_child(button)


func _on_dance_button_pressed(index: int) -> void:
	toggle_dance_wheel()
	dance_chosen.emit(index)


## Tutorial line in the middle of the screen, until hide_hint(). `button` is
## a touch button to draw attention to, by its action.
func show_hint(text: String, button: StringName = &"") -> void:
	_hint.text = text
	touch_controls.highlight(button)
	if _hint_tween:
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint, "modulate:a", 1.0, 0.3)


func hide_hint() -> void:
	touch_controls.highlight(&"")
	if _hint_tween:
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint, "modulate:a", 0.0, 0.25)


func _build_hint() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.05, 0.16, 0.85)
	style.border_color = Color(0.16, 0.83, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(16)
	_hint.add_theme_stylebox_override("normal", style)
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.anchor_left = 0.2
	_hint.anchor_right = 0.8
	# Below the banners, above the crosshair.
	_hint.anchor_top = 0.34
	_hint.anchor_bottom = 0.34
	_hint.grow_vertical = Control.GROW_DIRECTION_BOTH
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.modulate.a = 0.0
	add_child(_hint)
	# Under the choice panels and the pause menu, which dim everything behind them.
	move_child(_hint, pause_menu.get_index())


## First beat of the death sequence: big title over the slowed-down game.
func show_death_title() -> void:
	_game_over = true
	_hint.visible = false
	_dance_wheel.visible = false
	pause_menu.enabled = false
	_pause_button.visible = false
	touch_controls.visible = false
	touch_controls.process_mode = Node.PROCESS_MODE_DISABLED
	reticle.visible = false
	_death_title.visible = true


## `unlocked` lists the names of the rewards just earned. A victory
## celebrates and only offers to go back to the menu; a death halves the XP.
func show_game_over(score: int, best: int, is_record: bool, xp: int, unlocked: Array, result := Result.DEATH,
		challenges: Array[Dictionary] = [], rank := 0, counts := {}) -> void:
	_death_title.visible = false
	_game_over = true
	pause_menu.enabled = false
	_pause_button.visible = false
	touch_controls.visible = false
	touch_controls.process_mode = Node.PROCESS_MODE_DISABLED
	reticle.visible = false
	_final_score.text = "Score : %d" % score
	_best_score.text = "Nouveau record !" if is_record else "Record : %d" % best
	_xp_label.text = "+%d XP" % xp
	if not counts.is_empty():
		var shots: float = counts.get("shots", 0)
		var accuracy := 0 if shots == 0 else roundi(100.0 * minf(counts.get("hits", 0) / shots, 1.0))
		_final_score.text += "\n%d élim.  ·  %d à la tête  ·  %d %% de précision" % [
				counts.get("kills", 0), counts.get("headshots", 0), accuracy]
	if rank > 0:
		_best_score.text += "  ·  %de du classement" % rank if rank > 1 else "  ·  1er du classement"
	if result == Result.DEATH:
		_xp_label.text += "  (moitié : tu es mort)"
	elif result == Result.QUIT:
		_xp_label.text += "  (moitié : partie quittée)"
	for challenge in challenges:
		_xp_label.text += "\nDéfi réussi : %s  +%d XP" % [challenge.text, challenge.xp]
	if not unlocked.is_empty():
		_xp_label.text += "\nDébloqué : " + ", ".join(unlocked)
	if result == Result.QUIT:
		_end_title.text = "PARTIE QUITTÉE"
	elif result != Result.DEATH:
		_end_title.text = "VICTOIRE" if result == Result.VICTORY else "XP ENCAISSÉE"
		_end_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		_replay_button.visible = result == Result.LEFT
	_game_over_screen.visible = true


## Shop money earned by the game, under the XP.
func show_rewards(credits: int, gems: int) -> void:
	var text := "+%d crédits" % credits
	if gems > 0:
		text += "  ·  +%d gemmes" % gems
	_xp_label.text = text + "\n" + _xp_label.text
