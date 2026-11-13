extends Season3Scene
## Chapitre 26 : L'Archive. Version 0, and the golems.


func _init() -> void:
	episode_number = 26
	episode_title = "L'ARCHIVE"
	duration = 28.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("ruins")
	_moons()
	_fade_shade(0.0, 0.6)
	var arch := Vector3(0, 0.1, -26)
	_portal(arch + Vector3(0, 4.5, 0.4), 3.6)
	var ghost := _actor(load(Loadout.CHARACTER_DIR + "Cow.fbx"), 3.2, arch + Vector3(0, 0.6, 2.2), PI)
	_tint(ghost, CRYSTAL)
	var paladin := _hero("paladin", arch + Vector3(-1, 0, 8), 0.0)
	var creator := _creator(arch + Vector3(1, 0, 8), 0.0)
	_dolly(arch + Vector3(2.4, 2, 12), arch + Vector3(2, 2.2, 11), arch + Vector3(0, 2.6, 2.2), arch + Vector3(0, 2.6, 2.2), 6.0)
	_say(ghost, "Version 0. J'ai écrit cette galaxie, puis je suis parti.", 3.2, 1.0, 3.4)
	await _until(6.6)
	_dolly(arch + Vector3(0.6, 1.7, 5.4), arch + Vector3(0.4, 1.7, 5.0), arch + Vector3(1, 1.5, 8), arch + Vector3(1, 1.5, 8), 5.0)
	creator.get_parent().rotation.y = PI
	_say(creator, "Alors je suis... une copie.", 2.2, 1.0)
	await _until(9.4)
	_say(paladin, "Copie ou pas, on te garde.", 2.0, -1.0)
	await _until(11.8)
	_shake = 0.35
	for at in [Vector3(-9, 0.1, -3), Vector3(9, 0.1, -3)]:
		var golem := _golem(at, 0.0, 4.4)
		_rise(golem, 4.0, 1.4)
	_dolly(arch + Vector3(0, 1.4, 22), arch + Vector3(0, 1.8, 19), arch + Vector3(0, 2.4, 22), arch + Vector3(0, 2.6, 23), 5.0)
	_narrate("Les gardiens de l'archive se réveillent.", 2.8)
	await _until(15.4)
	_narrate("MISSION : tiens les ruines jusqu'au dernier golem.", 3.4)
	await _until(20.0)
	_fade_shade(1.0, 1.0)
