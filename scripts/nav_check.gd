extends Node
## Test run by the CI: checks that enemies can walk from the floor up to every
## level of every arena (the markers under NavCheckpoints, placed by
## tools/make_arena.py). Prints one NAV line per level and exits with an error
## if one cannot be reached.

const ARENAS: Array[String] = ["station", "desert", "jungle", "volcano", "city"]
const START := Vector3(0.0, 0.2, 18.0)
const MAX_WAIT_FRAMES := 600


func _ready() -> void:
	# The very first region added in a headless run never gets a usable map
	# (whichever arena it is), so a throwaway one goes first.
	var warm_up: Node = load("res://scenes/arenas/%s.tscn" % ARENAS[0]).instantiate()
	add_child(warm_up)
	for i in 30:
		await get_tree().physics_frame
	remove_child(warm_up)
	warm_up.free()

	var failed := false
	for arena_name in ARENAS:
		var arena: NavigationRegion3D = load("res://scenes/arenas/%s.tscn" % arena_name).instantiate()
		add_child(arena)
		# The navigation map is built in the background: wait until it answers.
		# (The map itself only exists once the first arena has entered the scene.)
		var map := RID()
		for i in MAX_WAIT_FRAMES:
			await get_tree().physics_frame
			OS.delay_msec(10)
			map = arena.get_navigation_map()
			if not NavigationServer3D.map_get_path(map, START, START + Vector3(0, 0, -4), true).is_empty():
				break
		print("NAV info %s: %d navigation polygons" % [arena_name, arena.navigation_mesh.get_polygon_count()])
		for marker: Marker3D in arena.get_node("NavCheckpoints").get_children():
			var level := marker.global_position
			var path := NavigationServer3D.map_get_path(map, START, level, true)
			var reached := not path.is_empty() and path[-1].distance_to(level) < 1.5
			# The end of the path tells where enemies get stuck when it fails.
			print("NAV %s %s level %s at %s: %d points, ends at %s" % [
				"OK" if reached else "FAIL", arena_name, marker.name, level, path.size(),
				path[-1] if not path.is_empty() else "nowhere"])
			failed = failed or not reached
		remove_child(arena)
		arena.free()
		await get_tree().physics_frame
	get_tree().quit(1 if failed else 0)
