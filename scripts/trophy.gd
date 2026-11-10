class_name Trophy
extends Node3D
## Golden cup that rises where the final boss fell. Built from simple shapes.

const GOLD := Color(1.0, 0.8, 0.25)
const SPIN_SPEED := 1.2


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = GOLD
	material.metallic = 0.9
	material.roughness = 0.25
	material.emission_enabled = true
	material.emission = GOLD
	material.emission_energy_multiplier = 0.6

	# Base, stem, bowl and rim: (bottom radius, top radius, height, center height).
	for part: Array in [[0.55, 0.45, 0.2, 0.1], [0.12, 0.12, 0.7, 0.55], [0.2, 0.65, 0.9, 1.35], [0.7, 0.7, 0.08, 1.84]]:
		var mesh := CylinderMesh.new()
		mesh.bottom_radius = part[0]
		mesh.top_radius = part[1]
		mesh.height = part[2]
		mesh.radial_segments = 16
		mesh.material = material
		var piece := MeshInstance3D.new()
		piece.mesh = mesh
		piece.position.y = part[3]
		add_child(piece)

	var light := OmniLight3D.new()
	light.position.y = 2.2
	light.light_color = GOLD
	light.light_energy = 4.0
	light.omni_range = 10.0
	add_child(light)

	# Grows out of the ground.
	scale = Vector3.ONE * 0.01
	create_tween().tween_property(self, "scale", Vector3.ONE * 1.6, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	rotate_y(delta * SPIN_SPEED)
