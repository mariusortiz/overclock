extends Node
## Test run by the CI: checks that enemies can walk from the floor up to each
## deck of every arena. Prints one NAV line per deck and exits with an error
## if a deck cannot be reached.

const ARENAS: Array[String] = ["station", "desert", "jungle", "volcano", "city"]
const START := Vector3(0.0, 0.2, 18.0)
const DECKS: Array[Vector3] = [Vector3(-24.5, 3.1, 0.0), Vector3(24.5, 3.1, 0.0)]
const MAX_WAIT_FRAMES := 600


func _ready() -> void:
	var failed := false
	for arena_name in ARENAS:
		var arena: NavigationRegion3D = load("res://scenes/arenas/%s.tscn" % arena_name).instantiate()
		add_child(arena)
		# The navigation map is built in the background: wait until it answers.
		var map := arena.get_navigation_map()
		for i in MAX_WAIT_FRAMES:
			await get_tree().physics_frame
			OS.delay_msec(10)
			if not NavigationServer3D.map_get_path(map, START, START + Vector3(0, 0, -4), true).is_empty():
				break
		for deck in DECKS:
			var path := NavigationServer3D.map_get_path(map, START, deck, true)
			var reached := not path.is_empty() and path[-1].distance_to(deck) < 1.5
			# The end of the path tells where enemies get stuck when it fails.
			print("NAV %s %s deck at x=%d: %d points, ends at %s" % [
				"OK" if reached else "FAIL", arena_name, deck.x, path.size(),
				path[-1] if not path.is_empty() else "nowhere"])
			failed = failed or not reached
		remove_child(arena)
		arena.free()
		await get_tree().physics_frame
	get_tree().quit(1 if failed else 0)
