class_name Shockwave
extends Node3D
## Ring that spreads along the ground from the final boss. It hurts the player
## as it passes, unless they are in the air or up on a deck.

const SPEED := 9.0
const MAX_RADIUS := 24.0
const THICKNESS := 0.9
## The player is safe this far above the ring's height.
const SAFE_HEIGHT := 0.6
const COLOR := Color(1.0, 0.5, 0.15, 0.75)

var damage := 25

var _radius := 0.5
var _has_hit := false
var _ring := MeshInstance3D.new()


func _ready() -> void:
	add_to_group("transient")
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = COLOR
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.0
	torus.rings = 48
	torus.ring_segments = 6
	torus.material = material
	_ring.mesh = torus
	_ring.position.y = 0.25
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring)


func _physics_process(delta: float) -> void:
	_radius += SPEED * delta
	_ring.scale = Vector3(_radius, 4.0, _radius)
	if _radius >= MAX_RADIUS:
		queue_free()
		return
	if _has_hit:
		return
	var player: Player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var offset := player.global_position - global_position
	var on_ring := absf(Vector2(offset.x, offset.z).length() - _radius) <= THICKNESS
	if on_ring and offset.y < SAFE_HEIGHT:
		_has_hit = true
		player.take_damage(damage)
