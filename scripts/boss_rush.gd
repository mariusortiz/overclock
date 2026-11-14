class_name BossRush
## Boss rush: the eight bosses one after the other, each in its own arena,
## with one life and a clock. A power-up between two bosses. The best times
## are kept; the first run to the end gives the Chrono skin.

const SKIN_ID := "skin_chrono"
const TIMES_KEY := "boss_rush_times"
const TIMES_KEPT := 5
## The bosses in order, with the arena (Main.ARENAS index) of each.
const STAGES: Array[Array] = [
	[Boss.Kind.COLOSSUS, 0], [Boss.Kind.BRUTE, 1], [Boss.Kind.ARTILLERY, 2], [Boss.Kind.SUMMONER, 3],
	[Boss.Kind.VIRUS, 4], [Boss.Kind.GUARDIAN, 5], [Boss.Kind.FROST, 8], [Boss.Kind.TITAN, 6],
]

## On for a boss rush game (set by the menu, read by Main).
static var active := false
## What the last finished run gave, for the end screen.
static var last_result := ""


## The best times, in seconds, fastest first.
static func times() -> Array:
	return SaveData.load_progress(TIMES_KEY, [])


## Saves a finished run. Returns its rank (1 for the best), or 0.
static func add_time(seconds: float) -> int:
	var list := times()
	list.append(snappedf(seconds, 0.1))
	list.sort()
	list = list.slice(0, TIMES_KEPT)
	SaveData.save_progress(TIMES_KEY, list)
	var rank := list.find(snappedf(seconds, 0.1))
	return rank + 1


static func clock(seconds: float) -> String:
	return "%d:%04.1f" % [floori(seconds / 60.0), fmod(seconds, 60.0)]
