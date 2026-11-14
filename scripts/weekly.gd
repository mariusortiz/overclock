class_name Weekly
## Seven missions a week, the same for everyone in a given week (Monday to
## Sunday), longer than the daily challenges. They come one after the other:
## only the current one counts a game's progress. Each pays its XP; the
## seventh opens the week's chest (CHEST_* below, and the Aurore banner
## the first time).

const COUNT := 7
const SAVE_KEY := "weekly"
const CHEST_GEMS := 150
const CHEST_BOOSTER := "legend"
## "stat" is a GameStats count; "text" takes the goal.
const POOL: Array[Dictionary] = [
	{"id": "kills", "stat": "kills", "goal": 300, "xp": 600, "text": "Abats %d ennemis"},
	{"id": "headshots", "stat": "headshots", "goal": 120, "xp": 600, "text": "Touche %d fois à la tête"},
	{"id": "melee", "stat": "melee_hits", "goal": 60, "xp": 600, "text": "Frappe %d fois au corps à corps"},
	{"id": "waves", "stat": "waves", "goal": 40, "xp": 700, "text": "Termine %d vagues"},
	{"id": "boss", "stat": "bosses", "goal": 4, "xp": 800, "text": "Bats %d boss"},
	{"id": "ultimates", "stat": "ultimates", "goal": 12, "xp": 600, "text": "Lance %d ultis"},
	{"id": "crates", "stat": "crates", "goal": 10, "xp": 500, "text": "Ramasse %d caisses d'armes"},
	{"id": "elites", "stat": "elites", "goal": 12, "xp": 700, "text": "Abats %d ennemis d'élite"},
	{"id": "games", "stat": "games", "goal": 10, "xp": 500, "text": "Joue %d parties"},
	{"id": "shots", "stat": "shots", "goal": 3000, "xp": 500, "text": "Tire %d balles"},
]


## The week's missions, each with "progress", "done" and "current" (the one
## that counts now).
static func missions() -> Array[Dictionary]:
	var saved := _saved()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("week-%d" % week())
	var order := range(POOL.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	var list: Array[Dictionary] = []
	for index in COUNT:
		var mission: Dictionary = POOL[order[index % order.size()]].duplicate()
		# Later missions of the week ask a little more.
		mission.goal = roundi(mission.goal * (1.0 + 0.1 * index))
		mission.text = mission.text % mission.goal
		mission.index = index
		mission.done = index < saved.step
		mission.current = index == saved.step
		mission.progress = mission.goal if mission.done else (mini(saved.progress, mission.goal) if mission.current else 0)
		list.append(mission)
	return list


## Adds a game's counts to the current mission. Returns the missions
## completed (at most one) and pays the chest after the seventh.
static func record(counts: Dictionary) -> Array[Dictionary]:
	var saved := _saved()
	var completed: Array[Dictionary] = []
	if saved.step >= COUNT:
		return completed
	var mission: Dictionary = missions()[saved.step]
	saved.progress += int(counts.get(mission.stat, 0))
	if saved.progress >= mission.goal:
		completed.append(mission)
		saved.step += 1
		saved.progress = 0
		if saved.step == COUNT:
			Wallet.add_gems(CHEST_GEMS)
			Cards.give_booster(CHEST_BOOSTER)
			Pets.give_egg()
			Wallet.give("banner_aurora")
	SaveData.save_progress(SAVE_KEY, saved)
	return completed


static func done_count() -> int:
	return _saved().step


## Days left before the new week (1 on Sunday).
static func days_left() -> int:
	return 7 - (_days() + 3) % 7


## The week number since 1970 (weeks start on Monday; 1 January 1970 was a
## Thursday, hence the 3).
static func week() -> int:
	@warning_ignore("integer_division")
	return (_days() + 3) / 7


static func _days() -> int:
	var today := Time.get_date_dict_from_system()
	@warning_ignore("integer_division")
	return int(Time.get_unix_time_from_datetime_dict(today)) / 86400


## This week's progress: {"week", "step" (missions done), "progress" (of the
## current one)}. Last week's is dropped.
static func _saved() -> Dictionary:
	var saved: Dictionary = SaveData.load_progress(SAVE_KEY, {})
	if int(saved.get("week", -1)) != week():
		saved = {"week": week(), "step": 0, "progress": 0}
	saved.step = int(saved.step)
	saved.progress = int(saved.progress)
	return saved
