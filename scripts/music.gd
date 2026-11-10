extends AudioStreamPlayer
## Background music, autoloaded as "Music" so it keeps playing across scenes
## and while the game is paused.

enum Track { MAIN, BOSS, DEATH }

const STREAMS := {
	Track.MAIN: preload("res://assets/audio/music/synthwave_house_loop.ogg"),
	Track.BOSS: preload("res://assets/audio/music/boss_battle_loop.mp3"),
	Track.DEATH: preload("res://assets/audio/music/no_hope.ogg"),
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
	stream = STREAMS[track]
	stream.set("loop", track != Track.DEATH)
	play()
