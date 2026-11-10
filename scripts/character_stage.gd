class_name CharacterStage
extends SubViewportContainer
## 3D showcase used by the menus: the player's character holding the chosen
## weapons, on a transparent background so the 2D backdrop shows through.

const TURN_SPEED := 0.35
const TURN_RANGE := 0.5  # radians each side of facing the camera

var _time := 0.0
var _character: CharacterModel
var _right_hand: Node3D
var _left_hand: Node3D

@onready var _pivot: Node3D = $SubViewport/World/Pivot
@onready var _weapon_holder: Node3D = $SubViewport/World/Pivot/WeaponHolder
@onready var _melee_holder: Node3D = $SubViewport/World/Pivot/MeleeHolder
@onready var _extras: Node3D = $SubViewport/World/Extras


func _process(delta: float) -> void:
	# Sway around the pose facing the camera.
	_time += delta
	_pivot.rotation.y = PI + sin(_time * TURN_SPEED) * TURN_RANGE
	if _right_hand:
		_weapon_holder.global_position = _right_hand.global_position
	if _left_hand:
		_melee_holder.global_position = _left_hand.global_position


func show_character(item: Dictionary) -> void:
	if _character:
		_pivot.remove_child(_character)
		_character.queue_free()
	_character = Loadout.instantiate_character(item)
	_pivot.add_child(_character)
	_character.play(&"aim")
	_right_hand = _character.get_attachment("Fist.R")
	_left_hand = _character.get_attachment("Fist.L")


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


## Adds another animated model to the scene (enemies, a boss behind).
func add_extra(model_path: String, at: Vector3, height: float, hover := 0.0) -> void:
	var model: Node3D = load(model_path).instantiate()
	model.set_script(CharacterModel)
	var character := model as CharacterModel
	character.target_height = height
	character.hover_height = hover
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = PI
	_extras.add_child(holder)
	holder.add_child(character)
	character.play(&"idle")


func _replace(holder: Node3D, model: Node3D) -> void:
	for old in holder.get_children():
		holder.remove_child(old)
		old.queue_free()
	holder.add_child(model)
