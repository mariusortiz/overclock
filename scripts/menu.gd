extends Node3D
## Title screen: best score, character, weapon and melee selection, play button.
## Locked items can be previewed but not played.

const GAME_SCENE := "res://scenes/main.tscn"
const SPIN_SPEED := 0.6

var _best := 0
var _character_index := 0
var _weapon_index := 0
var _melee_index := 0

@onready var _character_pivot: Node3D = $CharacterPivot
@onready var _weapon_pivot: Node3D = $WeaponPivot
@onready var _best_label: Label = $UI/Panel/Center/Box/Best
@onready var _character_name: Label = $UI/Panel/Center/Box/CharacterRow/Name
@onready var _character_info: Label = $UI/Panel/Center/Box/CharacterInfo
@onready var _weapon_name: Label = $UI/Panel/Center/Box/WeaponRow/Name
@onready var _weapon_info: Label = $UI/Panel/Center/Box/WeaponInfo
@onready var _melee_name: Label = $UI/Panel/Center/Box/MeleeRow/Name
@onready var _melee_info: Label = $UI/Panel/Center/Box/MeleeInfo
@onready var _play_button: Button = $UI/Panel/Center/Box/Play


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_best = SaveData.load_high_score()
	_best_label.text = "Record : %d" % _best
	_character_index = Loadout.CHARACTERS.find(Loadout.selected_character())
	_weapon_index = Loadout.WEAPONS.find(Loadout.selected_weapon())
	_melee_index = Loadout.MELEE.find(Loadout.selected_melee())

	$UI/Panel/Center/Box/CharacterRow/Previous.pressed.connect(_cycle_character.bind(-1))
	$UI/Panel/Center/Box/CharacterRow/Next.pressed.connect(_cycle_character.bind(1))
	$UI/Panel/Center/Box/WeaponRow/Previous.pressed.connect(_cycle_weapon.bind(-1))
	$UI/Panel/Center/Box/WeaponRow/Next.pressed.connect(_cycle_weapon.bind(1))
	$UI/Panel/Center/Box/MeleeRow/Previous.pressed.connect(_cycle_melee.bind(-1))
	$UI/Panel/Center/Box/MeleeRow/Next.pressed.connect(_cycle_melee.bind(1))
	_play_button.pressed.connect(_on_play_pressed)
	_refresh()


func _notification(what: int) -> void:
	# Android back button.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


func _process(delta: float) -> void:
	_character_pivot.rotate_y(delta * SPIN_SPEED)
	_weapon_pivot.rotate_y(-delta * SPIN_SPEED * 2.0)


func _cycle_character(step: int) -> void:
	_character_index = posmod(_character_index + step, Loadout.CHARACTERS.size())
	_refresh()


func _cycle_weapon(step: int) -> void:
	_weapon_index = posmod(_weapon_index + step, Loadout.WEAPONS.size())
	_refresh()


func _cycle_melee(step: int) -> void:
	_melee_index = posmod(_melee_index + step, Loadout.MELEE.size())
	_refresh()


func _refresh() -> void:
	var character: Dictionary = Loadout.CHARACTERS[_character_index]
	var weapon: Dictionary = Loadout.WEAPONS[_weapon_index]
	var melee: Dictionary = Loadout.MELEE[_melee_index]

	_character_name.text = character.name
	_character_info.text = _lock_text(character)
	_weapon_name.text = weapon.name
	_weapon_info.text = _lock_text(weapon) if not Loadout.is_unlocked(weapon) else \
			"Cadence %s/s · Dégâts %d · Chargeur %d" % [String.num(weapon.fire_rate, 1).trim_suffix(".0"), weapon.damage, weapon.magazine]
	_melee_name.text = melee.name
	_melee_info.text = _lock_text(melee) if not Loadout.is_unlocked(melee) else \
			"Dégâts %d · Portée %s m" % [melee.damage, String.num(melee.range, 1).trim_suffix(".0")]
	_play_button.disabled = not (Loadout.is_unlocked(character) and Loadout.is_unlocked(weapon) \
			and Loadout.is_unlocked(melee))

	_replace_child(_character_pivot, Loadout.instantiate_character(character))
	(_character_pivot.get_child(0) as CharacterModel).play(&"idle")
	_replace_child(_weapon_pivot, Loadout.instantiate_weapon(weapon))
	_weapon_pivot.get_child(0).scale = Vector3.ONE * weapon.scale


func _lock_text(item: Dictionary) -> String:
	return "" if Loadout.is_unlocked(item) else "Verrouillé · record de %d requis" % item.unlock


func _replace_child(parent: Node3D, child: Node3D) -> void:
	for old in parent.get_children():
		parent.remove_child(old)
		old.queue_free()
	parent.add_child(child)


func _on_play_pressed() -> void:
	Loadout.select(Loadout.CHARACTER_KEY, Loadout.CHARACTERS[_character_index])
	Loadout.select(Loadout.WEAPON_KEY, Loadout.WEAPONS[_weapon_index])
	Loadout.select(Loadout.MELEE_KEY, Loadout.MELEE[_melee_index])
	# Deferred: the scene must not be removed while the button handles its click.
	get_tree().change_scene_to_file.call_deferred(GAME_SCENE)
