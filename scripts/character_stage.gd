class_name CharacterStage
extends SubViewportContainer
## 3D showcase used by the menus: the player's character holding the chosen
## weapons, on a transparent background so the 2D backdrop shows through.

const TURN_SPEED := 0.35
const TURN_RANGE := 0.5  # radians each side of facing the camera

var _time := 0.0
var _character: CharacterModel

@onready var _pivot: Node3D = $SubViewport/World/Pivot
@onready var _weapon_holder: Node3D = $SubViewport/World/Pivot/WeaponHolder
@onready var _melee_holder: Node3D = $SubViewport/World/Pivot/MeleeHolder


func _process(delta: float) -> void:
	# Sway around the pose facing the camera.
	_time += delta
	_pivot.rotation.y = PI + sin(_time * TURN_SPEED) * TURN_RANGE
	if _character:
		_character.place_in_hand(_weapon_holder, "R", false)
		_character.place_in_hand(_melee_holder, "L", true)


func show_character(item: Dictionary) -> void:
	if _character:
		_pivot.remove_child(_character)
		_character.queue_free()
	_character = Loadout.instantiate_character(item)
	_pivot.add_child(_character)
	_character.play(&"aim")


## `skin` defaults to the equipped one.
func show_weapon(item: Dictionary, skin := {}) -> void:
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
