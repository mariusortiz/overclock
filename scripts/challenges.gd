class_name Challenges
## Three daily challenges, the same for everyone on a given day, drawn from
## POOL. Progress adds up over the day's games; a completed challenge pays its
## XP once. A new day brings three new ones.

const PER_DAY := 3
const SAVE_KEY := "challenges"
## "stat" is a GameStats count; "text" takes the goal.
const POOL: Array[Dictionary] = [
	{"id": "kills", "stat": "kills", "goal": 60, "xp": 300, "text": "Abats %d ennemis"},
	{"id": "headshots", "stat": "headshots", "goal": 25, "xp": 300, "text": "Touche %d fois à la tête"},
	{"id": "melee", "stat": "melee_hits", "goal": 15, "xp": 300, "text": "Frappe %d fois au corps à corps"},
	{"id": "waves", "stat": "waves", "goal": 10, "xp": 350, "text": "Termine %d vagues"},
	{"id": "boss", "stat": "bosses", "goal": 1, "xp": 400, "text": "Bats %d boss"},
	{"id": "ultimates", "stat": "ultimates", "goal": 3, "xp": 300, "text": "Lance %d ultis"},
	{"id": "crates", "stat": "crates", "goal": 3, "xp": 250, "text": "Ramasse %d caisses d'armes"},
	{"id": "elites", "stat": "elites", "goal": 3, "xp": 350, "text": "Abats %d ennemis d'élite"},
	{"id": "games", "stat": "games", "goal": 3, "xp": 250, "text": "Joue %d parties"},
]


## Today's challenges, each with its "progress" and whether it is "done".
static func today() -> Array[Dictionary]:
	var saved := _saved()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_date())
	var order := range(POOL.size())
	# Fisher-Yates with the day's seed: everyone gets the same three.
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	var list: Array[Dictionary] = []
	for index: int in order.slice(0, PER_DAY):
		var challenge: Dictionary = POOL[index].duplicate()
		challenge.text = challenge.text % challenge.goal
		challenge.progress = mini(saved.progress.get(challenge.id, 0), challenge.goal)
		challenge.done = challenge.id in saved.done
		list.append(challenge)
	return list


## Adds a game's counts to today's challenges and saves them. Returns those it
## completed.
static func record(counts: Dictionary) -> Array[Dictionary]:
	var saved := _saved()
	var completed: Array[Dictionary] = []
	for challenge in today():
		if challenge.done:
			continue
		var progress: int = saved.progress.get(challenge.id, 0) + int(counts.get(challenge.stat, 0))
		saved.progress[challenge.id] = progress
		if progress >= challenge.goal:
			saved.done.append(challenge.id)
			completed.append(challenge)
	SaveData.save_progress(SAVE_KEY, saved)
	return completed


static func done_count() -> int:
	return today().filter(func(challenge: Dictionary) -> bool: return challenge.done).size()


## Today's saved progress: {"date", "progress": {id: count}, "done": [ids]}.
## Yesterday's is dropped.
static func _saved() -> Dictionary:
	var saved: Dictionary = SaveData.load_progress(SAVE_KEY, {})
	if saved.get("date", "") != _date():
		saved = {"date": _date(), "progress": {}, "done": []}
	return saved


static func _date() -> String:
	return Time.get_date_string_from_system()
