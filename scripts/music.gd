extends AudioStreamPlayer
## Background music, autoloaded as "Music" so it keeps playing across scenes
## and while the game is paused.

## CAPTURE and RACE are the zone capture and the ship race modes (RACE for
## the first circuit, then one track per circuit); STORY the story mode.
enum Track { MAIN, BOSS, DEATH, DESERT, JUNGLE, VOLCANO, CITY, CAPTURE, RACE, STORY, NEBULA, ASTEROIDS, RED_SUN, ICE, STORY_2, MATRIX, SHOP, ARMORY, PASS, CARDS, FIGHT_MENU, LOBBY }

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
	Track.STORY: "res://assets/audio/music/destiny_formation.ogg",
	Track.NEBULA: "res://assets/audio/music/chase.ogg",
	Track.ASTEROIDS: "res://assets/audio/music/as_fast_as_you_can.ogg",
	Track.RED_SUN: "res://assets/audio/music/cyber_runner.ogg",
	Track.ICE: "res://assets/audio/music/fields_of_ice.ogg",
	Track.STORY_2: "res://assets/audio/music/cyberpunk_moonlight_sonata.ogg",
	Track.MATRIX: "res://assets/audio/music/digital_acid.ogg",
	# Each screen of the menus has its own.
	Track.SHOP: "res://assets/audio/music/bossa_shop.ogg",
	Track.ARMORY: "res://assets/audio/music/mysterywave.ogg",
	Track.PASS: "res://assets/audio/music/synthwave_421k.ogg",
	Track.CARDS: "res://assets/audio/music/chill_menu.ogg",
	Track.FIGHT_MENU: "res://assets/audio/music/all_the_fight_left.ogg",
	Track.LOBBY: "res://assets/audio/music/electronic_outlaw.ogg",
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
