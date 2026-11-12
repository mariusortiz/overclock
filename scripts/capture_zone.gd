class_name CaptureZone
extends Node3D
## A zone of the capture mode: a ring on the ground with its letter above.
## The side alone inside it pulls its control toward itself; when both are
## inside, it is contested and nothing moves. Control goes from -1 (the foes
## hold it) through 0 (neutral) to 1 (the player's team holds it).

signal owner_changed(zone: CaptureZone)

const RADIUS := 4.5
## Seconds for one fighter to take a neutral zone; more fighters go faster.
const CAPTURE_TIME := 5.0
const MAX_SPEEDUP := 3
const HEIGHT_TOLERANCE := 2.5
const ALLY_COLOR := Color(0.16, 0.83, 1.0)
const ENEMY_COLOR := Color(1.0, 0.25, 0.2)
const NEUTRAL_COLOR := Color(0.9, 0.9, 0.95)

var letter := "A"
var control := 0.0
## &"ally", &"enemy" or &"" (nobody).
var holder := &""
var contested := false

var _ring_material := StandardMaterial3D.new()
var _column_material := StandardMaterial3D.new()
var _label := Label3D.new()


func _ready() -> void:
	add_to_group("transient")
	add_to_group("capture_zones")
	for material: StandardMaterial3D in [_ring_material, _column_material]:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var ring := TorusMesh.new()
	ring.inner_radius = RADIUS - 0.25
	ring.outer_radius = RADIUS
	ring.material = _ring_material
	var ring_instance := MeshInstance3D.new()
	ring_instance.mesh = ring
	ring_instance.scale.y = 0.3
	ring_instance.position.y = 0.08
	add_child(ring_instance)
	var column := CylinderMesh.new()
	column.top_radius = RADIUS
	column.bottom_radius = RADIUS
	column.height = 3.0
	column.cap_top = false
	column.cap_bottom = false
	column.material = _column_material
	var column_instance := MeshInstance3D.new()
	column_instance.mesh = column
	column_instance.position.y = 1.5
	column_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(column_instance)
	_label.text = letter
	_label.font = preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
	_label.font_size = 140
	_label.outline_size = 24
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.position.y = 4.2
	add_child(_label)
	_paint()


## Moves the control according to who stands inside, for `delta` seconds.
func update(delta: float, allies: int, enemies: int) -> void:
	contested = allies > 0 and enemies > 0
	if not contested and allies + enemies > 0:
		var side := 1.0 if allies > 0 else -1.0
		var speed := float(mini(maxi(allies, enemies), MAX_SPEEDUP)) / CAPTURE_TIME
		control = clampf(control + side * speed * delta, -1.0, 1.0)
	var before := holder
	if control >= 1.0:
		holder = &"ally"
	elif control <= -1.0:
		holder = &"enemy"
	elif (holder == &"ally" and control <= 0.0) or (holder == &"enemy" and control >= 0.0):
		holder = &""
	if holder != before:
		owner_changed.emit(self)
	_paint()


## Whether `point` (a fighter's feet) is inside the zone.
func contains(point: Vector3) -> bool:
	var flat := Vector2(point.x - global_position.x, point.z - global_position.z)
	return flat.length() <= RADIUS and absf(point.y - global_position.y) <= HEIGHT_TOLERANCE


func color() -> Color:
	if control > 0.0:
		return NEUTRAL_COLOR.lerp(ALLY_COLOR, control)
	return NEUTRAL_COLOR.lerp(ENEMY_COLOR, -control)


func _paint() -> void:
	var tint := color()
	# A contested zone blinks.
	var alpha := 0.9 if not contested or int(Time.get_ticks_msec() / 200.0) % 2 == 0 else 0.35
	_ring_material.albedo_color = Color(tint, alpha)
	_column_material.albedo_color = Color(tint, 0.12)
	_label.modulate = tint
