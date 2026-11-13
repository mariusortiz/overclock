class_name CharacterStage
extends SubViewportContainer
## 3D showcase used by the menus: the player's character holding the chosen
## weapons, on a transparent background so the 2D backdrop shows through.
## It can also show one weapon alone, floating and spinning (see `focus`).
## The pet (Pets) sits at the hero's feet, or alone and closer (Focus.PET).

enum Focus { CHARACTER, WEAPON, MELEE, SHIP, PET }

const TURN_SPEED := 0.35
const TURN_RANGE := 0.5  # radians each side of facing the camera
const SPIN_SPEED := 0.9
const FLOAT_HEIGHT := 1.05
## A gun shown alone is scaled to this length, in meters.
const FLOAT_GUN_LENGTH := 1.5
## A melee weapon shown alone is scaled to this height, within a limit.
const FLOAT_MELEE_HEIGHT := 1.7
const FLOAT_MELEE_MAX_SCALE := 3.4
## It leans a little, so that a blade is never seen exactly edge-on.
const FLOAT_MELEE_TILT := 0.3
## A race ship shown alone is scaled down to this, and tilted to show its top.
const FLOAT_SHIP_SCALE := 0.3
const FLOAT_SHIP_TILT := 0.75
## The pet beside the hero, and alone (closer, bigger).
const PET_BESIDE := Vector3(0.62, 0, -0.35)
const PET_ALONE := Vector3(0, 0.1, 0.6)
const PET_ALONE_SCALE := 1.1

var _time := 0.0
var _character: CharacterModel
var _focus := Focus.CHARACTER
var _gun_scale := 1.0
var _melee_scale := 1.0
## Height of the middle of the melee weapon's model, above the hand.
var _melee_middle := 0.0
var _melee_tip_up := true
## Test option (see Menu): index of a Dances.LIST dance to show, -2 for the
## jump pose, or -1 for none.
var preview_pose := -1

@onready var _pivot: Node3D = $SubViewport/World/Pivot
@onready var _weapon_holder: Node3D = $SubViewport/World/Pivot/WeaponHolder
@onready var _melee_holder: Node3D = $SubViewport/World/Pivot/MeleeHolder
var _ship_holder := Node3D.new()
var _pet: Pet


func _process(delta: float) -> void:
	# Sway around the pose facing the camera.
	_time += delta
	# The pet, three-quarters on, swaying too.
	if _pet:
		_pet.rotation.y = PI - 0.6 + sin(_time * TURN_SPEED + 1.0) * TURN_RANGE
	if _focus == Focus.PET:
		return
	if _focus == Focus.SHIP:
		_pivot.rotation.y = PI
		_ship_holder.position = Vector3(0, FLOAT_HEIGHT + sin(_time * 1.6) * 0.05, 0)
		_ship_holder.rotation = Vector3(FLOAT_SHIP_TILT, _time * SPIN_SPEED, 0)
		_ship_holder.scale = Vector3.ONE * FLOAT_SHIP_SCALE
		return
	if _focus != Focus.CHARACTER:
		# One weapon alone: it floats and turns on itself.
		_pivot.rotation.y = PI
		var holder := _weapon_holder if _focus == Focus.WEAPON else _melee_holder
		holder.position = Vector3(0, FLOAT_HEIGHT + sin(_time * 1.6) * 0.05, 0)
		holder.rotation = Vector3(0, _time * SPIN_SPEED, 0)
		holder.scale = Vector3.ONE * _gun_scale
		if _focus == Focus.MELEE:
			# Held by its handle: lower it so that its middle is the one floating.
			holder.position.y -= _melee_middle * _melee_scale
			holder.rotation.x = FLOAT_MELEE_TILT
			holder.scale = Vector3.ONE * _melee_scale
		return
	_pivot.rotation.y = PI + sin(_time * TURN_SPEED) * TURN_RANGE
	if _character and preview_pose != -1:
		_pivot.rotation.y = PI
		_character.play(&"idle")
		_character.pose.weight = 1.0
		_character.pose.targets = Dances.JUMP if preview_pose == -2 else Dances.pose_at(Dances.LIST[preview_pose], _time)
	if _character:
		_character.place_in_hand(_weapon_holder, "R", false)
		_character.place_in_hand(_melee_holder, "L", true, _melee_tip_up)


## What the stage shows: the character with the loadout in hand, or one
## weapon alone.
func focus(what: Focus) -> void:
	_focus = what
	if _ship_holder.get_parent() == null:
		_pivot.add_child(_ship_holder)
	if _character:
		_character.visible = what == Focus.CHARACTER
	_weapon_holder.visible = what != Focus.MELEE and what != Focus.SHIP and what != Focus.PET
	_melee_holder.visible = what != Focus.WEAPON and what != Focus.SHIP and what != Focus.PET
	_place_pet()
	_ship_holder.visible = what == Focus.SHIP
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


## `skin` defaults to the equipped melee skin.
func show_melee(item: Dictionary, skin := {}) -> void:
	if skin.is_empty():
		skin = Loadout.selected_melee_skin()
	var bounds := Loadout.melee_bounds(item)
	_melee_scale = minf(FLOAT_MELEE_HEIGHT / bounds.size.y, FLOAT_MELEE_MAX_SCALE)
	_melee_middle = bounds.get_center().y
	_melee_tip_up = Loadout.is_carried_tip_up(item)
	_replace(_melee_holder, Loadout.instantiate_melee(item, skin))


## A race ship of Loadout.SHIPS, alone.
func show_ship(item: Dictionary) -> void:
	for old in _ship_holder.get_children():
		old.queue_free()
	var ship := RaceShip.new()
	ship.configure(item)
	_ship_holder.add_child(ship)


## Shows the player's current selection.
func show_loadout() -> void:
	show_character(Loadout.selected_character())
	show_weapon(Loadout.selected_weapon())
	show_melee(Loadout.selected_melee())
	show_pet(Pets.selected())


## A pet of Pets.LIST (none for Pets.NONE).
func show_pet(item: Dictionary) -> void:
	if _pet:
		_pet.queue_free()
	_pet = Pet.new()
	_pet.configure(item)
	$SubViewport/World.add_child(_pet)
	_place_pet()


func _place_pet() -> void:
	if _pet == null:
		return
	var alone := _focus == Focus.PET
	_pet.visible = alone or _focus == Focus.CHARACTER
	_pet.position = PET_ALONE if alone else PET_BESIDE
	_pet.scale = Vector3.ONE * (PET_ALONE_SCALE if alone else 1.0)


func _replace(holder: Node3D, model: Node3D) -> void:
	for old in holder.get_children():
		holder.remove_child(old)
		old.queue_free()
	holder.add_child(model)


## The pet jumps for joy (just hatched).
func cheer_pet() -> void:
	if _pet:
		_pet.cheer()
