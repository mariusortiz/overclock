class_name Season4Scene
extends Season4Episode
## A chapter's scene in the story mode's season 4: like Season3Scene, with
## season 4's tools (the doubles, the mirror world, see Season4Episode).
## Kept apart from scripts/anime/ so that changing it does not render the
## anime again.

signal done


func _ready() -> void:
	super()
	Music.play_track(Music.Track.STORY_3)
	# A first shot for the title card, before the set is built.
	_dolly(Vector3(0, 2, 10), Vector3(0, 2, 10), Vector3.ZERO, Vector3.ZERO, 1.0)


func _run() -> void:
	await _story()
	await _until(duration)
	done.emit()
