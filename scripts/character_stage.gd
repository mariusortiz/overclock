class_name CharacterStage
extends SubViewportContainer
## 3D showcase used by the menus: the player's character holding the chosen
## weapons, on a transparent background so the 2D backdrop shows through.
## It can also show one weapon alone, floating and spinning (see `focus`).

enum Focus { CHARACTER, WEAPON, MELEE }

const TURN_SPEED := 0.35
const TURN_RANGE := 0.5  # radians each side of facing the camera
const SPIN_SPEED := 0.9
const FLOAT_HEIGHT := 1.05
## A gun shown alone is scaled to this length, in meters.
const FLOAT_GUN_LENGTH := 1.25
const FLOAT_MELEE_SCALE := 1.6

var _time := 0.0
var _character: CharacterModel
var _focus := Focus.CHARACTER
var _gun_scale := 1.0

@onready var _pivot: Node3D = $SubViewport/World/Pivot
@onready var _weapon_holder: Node3D = $SubViewport/World/Pivot/WeaponHolder
@onready var _melee_holder: Node3D = $SubViewport/World/Pivot/MeleeHolder


func _process(delta: float) -> void:
	# Sway around the pose facing the camera.
	_time += delta
	if _focus != Focus.CHARACTER:
		# One weapon alone: it floats and turns on itself.
		_pivot.rotation.y = PI
		var holder := _weapon_holder if _focus == Focus.WEAPON else _melee_holder
		holder.position = Vector3(0, FLOAT_HEIGHT + sin(_time * 1.6) * 0.05, 0)
		holder.rotation = Vector3(0, _time * SPIN_SPEED, 0)
		holder.scale = Vector3.ONE * (_gun_scale if _focus == Focus.WEAPON else FLOAT_MELEE_SCALE)
		return
	_pivot.rotation.y = PI + sin(_time * TURN_SPEED) * TURN_RANGE
	if _character:
		_character.place_in_hand(_weapon_holder, "R", false)
		_character.place_in_hand(_melee_holder, "L", true, true)


## What the stage shows: the character with the loadout in hand, or one
## weapon alone.
func focus(what: Focus) -> void:
	_focus = what
	if _character:
		_character.visible = what == Focus.CHARACTER
	_weapon_holder.visible = what != Focus.MELEE
	_melee_holder.visible = what != Focus.WEAPON
	for holder: Node3D in [_weapon_holder, _melee_holder]:
		holder.transform = Transform3D.IDENTITY


func show_character(item: Dictionary) -> void:
	if _character:
		_pivot.remove_child(_character)
		_character.queue_free()
	_character = Loadout.instantiate_character(item)
	_pivot.add_child(_character)
	_character.play(&"aim")
	_character.visible = _focus == Focus.CHARACTER


## `skin` defaults to the equipped one.
func show_weapon(item: Dictionary, skin := {}) -> void:
	_gun_scale = FLOAT_GUN_LENGTH / item.length
	_replace(_weapon_holder, Loadout.instantiate_weapon(item, skin))


func show_melee(item: Dictionary) -> void:
	_replace(_melee_holder, Loadout.instantiate_melee(item))


## Shows the player's current selection.
func show_loadout() -> void:
	show_character(Loadout.selected_character())
	show_weapon(Loadout.selected_weapon())
	show_melee(Loadout.selected_melee())


func _replace(holder: Node3D, model: Node3D) -> void:
	for old in holder.get_children():
		holder.remove_child(old)
		old.queue_free()
	holder.add_child(model)
