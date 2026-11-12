extends AudioStreamPlayer
## Background music, autoloaded as "Music" so it keeps playing across scenes
## and while the game is paused.

## CAPTURE and RACE are the zone capture and the ship race modes.
enum Track { MAIN, BOSS, DEATH, DESERT, JUNGLE, VOLCANO, CITY, CAPTURE, RACE }

# Loaded on demand rather than preloaded, so this script still compiles
# before the audio files have been imported for the first time.
const PATHS := {
	Track.MAIN: "res://assets/audio/music/synthwave_house_loop.ogg",
	Track.BOSS: "res://assets/audio/music/boss_battle_loop.mp3",
	Track.DEATH: "res://assets/audio/music/no_hope.ogg",
	Track.DESERT: "res://assets/audio/music/desert_travel.ogg",
	Track.JUNGLE: "res://assets/audio/music/jungle_battle.ogg",
	Track.VOLCANO: "res://assets/audio/music/fire_level.mp3",
	Track.CITY: "res://assets/audio/music/city_loop.mp3",
	Track.CAPTURE: "res://assets/audio/music/omega_droid.ogg",
	Track.RACE: "res://assets/audio/music/virtual_rush.ogg",
}

var _current := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	play_track(Track.MAIN)


## Switches track; does nothing if it is already playing. The death theme
## plays once, the others loop.
func play_track(track: Track) -> void:
	if track == _current:
		return
	_current = track
	stream = load(PATHS[track])
	stream.set("loop", track != Track.DEATH)
	play()
