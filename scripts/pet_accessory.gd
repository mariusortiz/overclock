class_name PetAccessory
## The accessories a pet can wear (Pets.ACCESSORIES), made of simple shapes.
## Each is built at the size of a head one unit wide, its origin on top of
## the head, facing -Z like the pets; Pet puts it on the pet's "head" point,
## scaled to the pet. "neck" ones sit lower, around the neck.


static func build(id: String) -> Node3D:
	var root := Node3D.new()
	match id:
		"acc_santa":
			var hat := _part(root, _cone(0.42, 0.85), _color(0.85, 0.08, 0.1), Vector3(0, 0.42, 0.05))
			hat.rotation.x = -0.35
			_part(root, _cylinder(0.48, 0.48, 0.16), _color(0.97, 0.97, 0.97), Vector3(0, 0.04, 0))
			_part(root, _sphere(0.13), _color(0.97, 0.97, 0.97), Vector3(0, 0.82, 0.32))
		"acc_scarf":
			var scarf := _part(root, _torus(0.34, 0.5), _color(0.8, 0.1, 0.12), Vector3.ZERO)
			scarf.rotation.x = 0.2
			_part(root, _box(Vector3(0.16, 0.45, 0.06)), _color(0.15, 0.55, 0.25), Vector3(0.18, -0.25, -0.42))
		"acc_antlers":
			for side in [-1.0, 1.0]:
				var branch := _part(root, _box(Vector3(0.09, 0.7, 0.09)), _color(0.85, 0.72, 0.52), Vector3(side * 0.28, 0.32, 0.05))
				branch.rotation.z = -side * 0.35
				var tine := _part(root, _box(Vector3(0.08, 0.38, 0.08)), _color(0.85, 0.72, 0.52), Vector3(side * 0.5, 0.52, -0.02))
				tine.rotation.z = side * 0.6
		"acc_sunglasses":
			_part(root, _box(Vector3(0.9, 0.06, 0.05)), _color(0.05, 0.05, 0.05), Vector3(0, -0.22, -0.52))
			for side in [-1.0, 1.0]:
				_part(root, _box(Vector3(0.34, 0.2, 0.04)), _color(0.08, 0.08, 0.1, 0.4), Vector3(side * 0.22, -0.3, -0.53))
		"acc_bowtie":
			for side in [-1.0, 1.0]:
				var wing := _part(root, _cone(0.14, 0.26), _color(0.8, 0.1, 0.12), Vector3(side * 0.13, 0, -0.42))
				wing.rotation.z = side * PI / 2.0
			_part(root, _sphere(0.06), _color(0.6, 0.05, 0.08), Vector3(0, 0, -0.42))
		"acc_tophat":
			_part(root, _cylinder(0.55, 0.55, 0.05), _color(0.06, 0.06, 0.08), Vector3(0, 0.02, 0))
			_part(root, _cylinder(0.32, 0.32, 0.6), _color(0.06, 0.06, 0.08), Vector3(0, 0.32, 0))
			_part(root, _cylinder(0.33, 0.33, 0.1), _color(0.75, 0.1, 0.15), Vector3(0, 0.1, 0))
		"acc_pilot":
			_part(root, _dome(0.5), _color(0.45, 0.3, 0.18), Vector3(0, -0.05, 0))
			for side in [-1.0, 1.0]:
				_part(root, _cylinder(0.13, 0.13, 0.08), _color(0.6, 0.85, 1.0, 0.7), Vector3(side * 0.18, 0.22, -0.35))
		"acc_halo":
			var halo := _part(root, _torus(0.3, 0.38), _glow(1.0, 0.85, 0.3), Vector3(0, 0.45, 0))
			halo.rotation.x = 0.15
		"acc_horns":
			for side in [-1.0, 1.0]:
				var horn := _part(root, _cone(0.14, 0.55), _color(0.85, 0.05, 0.05), Vector3(side * 0.27, 0.22, -0.05))
				horn.rotation.z = -side * 0.3
		"acc_matrix":
			_part(root, _dome(0.48), _color(0.04, 0.08, 0.05), Vector3(0, -0.05, 0))
			for side in [-1.0, 1.0]:
				_part(root, _cylinder(0.025, 0.025, 0.45), _color(0.1, 0.12, 0.1), Vector3(side * 0.22, 0.4, 0.05))
				_part(root, _sphere(0.07), _glow(0.2, 1.0, 0.45), Vector3(side * 0.22, 0.65, 0.05))
		"acc_cowboy":
			_part(root, _cylinder(0.85, 0.85, 0.06), _color(0.3, 0.18, 0.1), Vector3(0, 0.04, 0))
			_part(root, _cylinder(0.34, 0.4, 0.45), _color(0.3, 0.18, 0.1), Vector3(0, 0.27, 0))
			_part(root, _cylinder(0.41, 0.41, 0.08), _color(0.85, 0.65, 0.3), Vector3(0, 0.1, 0))
		"acc_wings":
			# Two white wings on the back, a little apart.
			for side in [-1.0, 1.0]:
				var wing := _part(root, _box(Vector3(0.75, 0.5, 0.06)), _color(1.0, 0.97, 0.98), Vector3(side * 0.42, 0.25, 0.45))
				wing.rotation = Vector3(0, side * 0.6, side * 0.4)
		"acc_roses":
			_part(root, _torus(0.36, 0.46), _color(0.2, 0.55, 0.25), Vector3(0, 0.05, 0))
			for index in 7:
				var angle := TAU * index / 7.0
				var color := _color(1.0, 0.2, 0.4) if index % 2 == 0 else _color(1.0, 0.6, 0.75)
				_part(root, _sphere(0.1), color, Vector3(cos(angle) * 0.41, 0.12, sin(angle) * 0.41))
		"acc_crown":
			var gold := _color(1.0, 0.8, 0.2)
			gold.metallic = 0.7
			gold.roughness = 0.3
			_part(root, _cylinder(0.42, 0.42, 0.24), gold, Vector3(0, 0.12, 0))
			for index in 5:
				var angle := TAU * index / 5.0
				_part(root, _cone(0.08, 0.22), gold, Vector3(cos(angle) * 0.32, 0.3, sin(angle) * 0.32))
			_part(root, _sphere(0.06), _glow(0.9, 0.1, 0.3), Vector3(0, 0.12, -0.38))
	return root


static func _part(root: Node3D, mesh: Mesh, material: Material, at: Vector3) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = at
	root.add_child(part)
	return part


static func _color(r: float, g: float, b: float, a := 1.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(r, g, b, a)
	if a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


static func _glow(r: float, g: float, b: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(r, g, b)
	return material


static func _cone(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh


static func _cylinder(top: float, bottom: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	return mesh


static func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	return mesh


static func _dome(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius
	mesh.is_hemisphere = true
	return mesh


static func _torus(inner: float, outer: float) -> TorusMesh:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner
	mesh.outer_radius = outer
	return mesh


static func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh
