extends SceneTree
## Prints the animations, bones and size of imported models.
## Run: godot --headless -s tools/inspect_models.gd -- res://path/model.fbx ...

func _init() -> void:
	for path in OS.get_cmdline_user_args():
		var scene: PackedScene = load(path)
		if scene == null:
			print("MODEL ", path, " FAILED TO LOAD")
			continue
		var model: Node3D = scene.instantiate()
		root.add_child(model)
		var player: AnimationPlayer = model.find_child("AnimationPlayer", true, false)
		var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false)
		var bounds := AABB()
		var first := true
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			var box := mesh.global_transform * mesh.get_aabb()
			bounds = box if first else bounds.merge(box)
			first = false
		print("MODEL ", path)
		print("  size ", bounds.size, " position ", bounds.position)
		print("  animations ", player.get_animation_list() if player else "none")
		if skeleton:
			var bones := []
			for i in skeleton.get_bone_count():
				bones.append(skeleton.get_bone_name(i))
			print("  bones ", bones)
		model.free()
	quit()
