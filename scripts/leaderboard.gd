class_name Leaderboard
## The ten best games played on this device: score, wave reached, hero, day,
## and whether the game went on in endless mode.

const SIZE := 10
const SAVE_KEY := "leaderboard"


static func entries() -> Array:
	return SaveData.load_progress(SAVE_KEY, [])


## Adds a game; returns its rank (1 is the best), or 0 if it is not in the ten.
static func add(score: int, wave: int, hero: String, endless: bool) -> int:
	if score <= 0:
		return 0
	var list := entries()
	var entry := {"score": score, "wave": wave, "hero": hero, "endless": endless,
			"date": Time.get_date_string_from_system()}
	var rank := list.size()
	for index in list.size():
		if score > list[index].score:
			rank = index
			break
	if rank >= SIZE:
		return 0
	list.insert(rank, entry)
	SaveData.save_progress(SAVE_KEY, list.slice(0, SIZE))
	return rank + 1
