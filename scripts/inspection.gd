class_name Inspection
extends Node3D
## Weapon inspection: brings a copy of the weapon up close in front of the
## camera and plays with it. A gun is turned over and its magazine comes out,
## spins and goes back in; a butterfly knife flips open and shut; any other
## melee weapon is turned around. Add it as a child of the camera.
##
## The copy moves on its own: the characters have no animation for this.

enum Kind { NONE, GUN, BUTTERFLY, MELEE }

## Where the weapon is shown, in the camera's space, and where it waits below.
const SHOWN := Vector3(0.14, -0.06, -0.85)
const HIDDEN := Vector3(0.14, -0.8, -0.85)
## Size of the weapon on show, in meters: a gun's length, a blade's height.
const GUN_LENGTH := 0.5
const MELEE_HEIGHT := 0.46
const DURATION := {Kind.GUN: 3.7, Kind.BUTTERFLY: 3.5, Kind.MELEE: 2.6}
## Guns loaded some other way than with a magazine: they roll over instead.
const NO_MAGAZINE: Array[String] = ["revolver", "shotgun", "bazooka"]
## Guns whose magazine is in the grip rather than ahead of it.
const MAGAZINE_IN_GRIP: Array[String] = ["blaster", "pistol"]
const BUTTERFLY_ID := "butterfly"
## Height of the butterfly knife's pivot above the hand: the 0.07 pivot of
## tools/make_melee_models.py at its scale of 1.85.
const BUTTERFLY_PIVOT := 0.1295

# Keyframes: [time, value] pairs. Angles in degrees.
# A gun's attitude is (tip around its length, turn, muzzle up).
const GUN_PLACE := [[0.0, HIDDEN], [0.35, SHOWN], [3.3, SHOWN], [3.7, HIDDEN]]
const GUN_TURN := [
	[0.0, Vector3(0, 40, -30)], [0.35, Vector3(0, 90, 0)], [0.9, Vector3(15, 90, 6)],
	[1.2, Vector3(-25, 90, 12)], [2.2, Vector3(-25, 90, 12)], [2.5, Vector3(0, 90, 0)],
	[2.9, Vector3(0, 270, 0)], [3.3, Vector3(10, 270, -6)], [3.7, Vector3(0, 300, -30)],
]
const GUN_ROLL := [
	[0.0, Vector3(0, 40, -30)], [0.35, Vector3(0, 90, 0)], [1.0, Vector3(0, 90, 8)],
	[2.2, Vector3(360, 90, 8)], [2.5, Vector3(360, 90, 0)],
	[2.9, Vector3(360, 270, 0)], [3.3, Vector3(370, 270, -6)], [3.7, Vector3(360, 300, -30)],
]
## How far the magazine is out of the gun, in magazine heights, and its spin.
const MAGAZINE_OUT := [[1.0, 0.0], [1.3, 1.3], [1.6, 2.1], [1.9, 2.1], [2.1, 1.3], [2.3, 0.0]]
const MAGAZINE_SPIN := [[1.3, 0.0], [1.95, 360.0]]
## The gun jumps a little when the magazine clicks back in.
const GUN_KICK := [[2.25, 0.0], [2.32, 0.02], [2.5, 0.0]]

const KNIFE_PLACE := [[0.0, HIDDEN], [0.3, SHOWN], [3.1, SHOWN], [3.5, HIDDEN]]
## Angle of each handle around the pivot: 0 is open, 180 folded over the blade.
const HANDLE_A := [[0.75, 180.0], [1.1, 0.0], [1.7, 0.0], [2.05, 180.0], [2.4, 180.0], [2.7, 0.0]]
const HANDLE_B := [[0.4, -180.0], [0.75, 0.0], [2.05, 0.0], [2.4, -180.0], [2.7, 0.0]]
## The whole knife spinning in its plane, and leaning toward the viewer.
const KNIFE_SPIN := [[0.4, 0.0], [0.75, -40.0], [1.1, 0.0], [1.7, 360.0], [2.4, 335.0], [2.7, 360.0]]
const KNIFE_LEAN := [[0.0, 50.0], [0.4, 15.0], [3.1, 20.0], [3.5, 60.0]]

const MELEE_PLACE := [[0.0, HIDDEN], [0.3, SHOWN], [2.2, SHOWN], [2.6, HIDDEN]]
const MELEE_TURN := [[0.0, -60.0], [0.4, 0.0], [2.2, 360.0], [2.6, 420.0]]

var _kind := Kind.NONE
var _time := 0.0
var _item: Node3D
var _item_scale := 1.0
var _no_magazine := false
var _magazine: MeshInstance3D
var _magazine_seat := Vector3.ZERO
var _magazine_height := 0.0
var _handle_a: Node3D
var _handle_b: Node3D


## Starts an inspection: the gun first, and the melee weapon if the gun is
## already being inspected.
func start(gun: Dictionary, gun_skin: Dictionary, melee: Dictionary, melee_skin: Dictionary) -> void:
	if _kind == Kind.GUN:
		start_melee(melee, melee_skin)
		return
	cancel()
	_show_gun(gun, gun_skin)
	_time = 0.0
	_pose()


## Inspects a melee weapon straight away.
func start_melee(melee: Dictionary, skin: Dictionary) -> void:
	cancel()
	if melee.id == BUTTERFLY_ID:
		_show_butterfly(skin)
	else:
		_show_melee(melee, skin)
	_time = 0.0
	_pose()


func cancel() -> void:
	_kind = Kind.NONE
	if _item:
		_item.queue_free()
		_item = null


func is_playing() -> bool:
	return _kind != Kind.NONE


func _process(delta: float) -> void:
	if _kind == Kind.NONE:
		return
	_time += delta
	if _time >= DURATION[_kind]:
		cancel()
	else:
		_pose()


# --- What is shown ----------------------------------------------------------

func _show_gun(gun: Dictionary, skin: Dictionary) -> void:
	_kind = Kind.GUN
	_item = Node3D.new()
	add_child(_item)
	var model := Loadout.instantiate_weapon(gun, skin)
	var length: float = gun.length
	model.scale = Vector3.ONE * (GUN_LENGTH / length)
	# Turn around the middle of the gun rather than around its grip.
	model.position.z = GUN_LENGTH * 0.4
	_item.add_child(model)

	var id: String = gun.id
	_no_magazine = NO_MAGAZINE.any(func(prefix: String) -> bool: return id.begins_with(prefix))
	if _no_magazine:
		return
	var in_grip: bool = MAGAZINE_IN_GRIP.any(func(prefix: String) -> bool: return id.begins_with(prefix))
	var box := BoxMesh.new()
	box.size = Vector3(0.022, 0.1, 0.045) if in_grip else Vector3(0.026, 0.13, 0.055)
	box.material = Loadout.magazine_material(skin)
	_magazine = MeshInstance3D.new()
	_magazine.mesh = box
	_magazine_height = box.size.y
	_magazine_seat = model.position + Vector3(0, -0.02, 0.0 if in_grip else -GUN_LENGTH * 0.2)
	_item.add_child(_magazine)


func _show_butterfly(skin: Dictionary) -> void:
	_kind = Kind.BUTTERFLY
	_item = Node3D.new()
	add_child(_item)
	_item_scale = MELEE_HEIGHT / Loadout.melee_bounds(Loadout.find(BUTTERFLY_ID).item).size.y
	_item.add_child(Loadout.melee_part("butterfly_blade", skin))
	_handle_a = Node3D.new()
	_handle_a.add_child(Loadout.melee_part("butterfly_handle_a", skin))
	_item.add_child(_handle_a)
	_handle_b = Node3D.new()
	_handle_b.add_child(Loadout.melee_part("butterfly_handle_b", skin))
	_item.add_child(_handle_b)


func _show_melee(melee: Dictionary, skin: Dictionary) -> void:
	_kind = Kind.MELEE
	_item = Node3D.new()
	add_child(_item)
	var bounds := Loadout.melee_bounds(melee)
	var model := Loadout.instantiate_melee(melee, skin)
	var scale_factor := MELEE_HEIGHT / bounds.size.y
	model.scale = Vector3.ONE * scale_factor
	# Turn around the middle of the weapon rather than around the hand.
	model.position.y = -bounds.get_center().y * scale_factor
	_item.add_child(model)


# --- Animation --------------------------------------------------------------

func _pose() -> void:
	match _kind:
		Kind.GUN:
			var attitude: Vector3 = _at(GUN_ROLL if _no_magazine else GUN_TURN)
			var kick: float = _at(GUN_KICK)
			_item.position = (_at(GUN_PLACE) as Vector3) + Vector3.UP * kick
			_item.basis = Basis(Vector3.BACK, deg_to_rad(attitude.z)) * Basis(Vector3.UP, deg_to_rad(attitude.y)) \
					* Basis(Vector3.FORWARD, deg_to_rad(attitude.x))
			if not _no_magazine:
				var out: float = _at(MAGAZINE_OUT)
				var spin: float = _at(MAGAZINE_SPIN)
				_magazine.position = _magazine_seat + Vector3.DOWN * out * _magazine_height
				_magazine.rotation.y = deg_to_rad(spin)
		Kind.BUTTERFLY:
			var spin: float = _at(KNIFE_SPIN)
			var lean: float = _at(KNIFE_LEAN)
			var angle_a: float = _at(HANDLE_A)
			var angle_b: float = _at(HANDLE_B)
			_item.position = _at(KNIFE_PLACE)
			_item.basis = (Basis(Vector3.UP, deg_to_rad(lean)) * Basis(Vector3.BACK, deg_to_rad(spin))).scaled(Vector3.ONE * _item_scale)
			_handle_a.rotation.z = deg_to_rad(angle_a)
			_handle_b.rotation.z = deg_to_rad(angle_b)
		Kind.MELEE:
			var turn: float = _at(MELEE_TURN)
			_item.position = _at(MELEE_PLACE)
			_item.basis = Basis(Vector3.BACK, deg_to_rad(-20.0)) * Basis(Vector3.UP, deg_to_rad(turn))


## Value of a keyframe track at the current time, eased between its keys.
func _at(track: Array) -> Variant:
	if _time <= track[0][0]:
		return track[0][1]
	for index in range(1, track.size()):
		var after: Array = track[index]
		if _time < after[0]:
			var before: Array = track[index - 1]
			var progress := smoothstep(before[0], after[0], _time)
			return lerp(before[1], after[1], progress)
	return track[-1][1]
