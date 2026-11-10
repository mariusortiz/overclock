extends Node
## Test run by the CI: checks that enemies can walk from the floor up to each
## deck of every arena. Prints one NAV line per deck and exits with an error
## if a deck cannot be reached.

const ARENAS: Array[String] = ["station", "desert", "jungle", "volcano", "city"]
const START := Vector3(0.0, 0.2, 18.0)
const DECKS: Array[Vector3] = [Vector3(-24.5, 3.1, 0.0), Vector3(24.5, 3.1, 0.0)]
const FRAMES_TO_BAKE := 30


func _ready() -> void:
	var failed := false
	for arena_name in ARENAS:
		var arena: NavigationRegion3D = load("res://scenes/arenas/%s.tscn" % arena_name).instantiate()
		add_child(arena)
		for i in FRAMES_TO_BAKE:
			await get_tree().physics_frame
		for deck in DECKS:
			var path := NavigationServer3D.map_get_path(arena.get_navigation_map(), START, deck, true)
			var reached := not path.is_empty() and path[-1].distance_to(deck) < 1.5
			print("NAV %s %s deck at x=%d" % ["OK" if reached else "FAIL", arena_name, deck.x])
			failed = failed or not reached
		remove_child(arena)
		arena.free()
		await get_tree().physics_frame
	get_tree().quit(1 if failed else 0)
