class_name MortarStrike
extends Node3D
## Artillery boss attack: a marked circle on the ground that explodes after a
## short delay, hurting the player if still inside.

const DELAY := 1.4
const RADIUS := 3.0
const WARNING_COLOR := Color(1.0, 0.15, 0.1, 0.45)
const BLAST_COLOR := Color(1.0, 0.6, 0.2, 0.5)

var damage := 20


func _ready() -> void:
	add_to_group("transient")
	var disc := CylinderMesh.new()
	disc.top_radius = RADIUS
	disc.bottom_radius = RADIUS
	disc.height = 0.05
	var marker := _add_mesh(disc, WARNING_COLOR)
	marker.position.y = 0.06
	marker.scale = Vector3(0.15, 1.0, 0.15)

	var tween := create_tween()
	tween.tween_property(marker, "scale", Vector3.ONE, DELAY)
	tween.tween_callback(_explode.bind(marker))


func _explode(marker: MeshInstance3D) -> void:
	marker.queue_free()
	var player: Player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= RADIUS:
		player.take_damage(damage)

	var sphere := SphereMesh.new()
	sphere.radius = RADIUS
	sphere.height = RADIUS * 2.0
	sphere.radial_segments = 12
	sphere.rings = 6
	var blast := _add_mesh(sphere, BLAST_COLOR)
	var tween := create_tween()
	tween.tween_property(blast, "scale", Vector3.ZERO, 0.25)
	tween.tween_callback(queue_free)


func _add_mesh(mesh: PrimitiveMesh, color: Color) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	return instance
