extends Season2Scene
## Chapitre 18 : Écran noir. The last fragment, at the station. The Virus
## strikes: the heroes are deleted one by one, Le Créateur falls.


func _init() -> void:
	episode_number = 18
	episode_title = "ÉCRAN NOIR"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var ids := ["sand_ghost", "ronin", "soldier", "kunoichi", "captain"]
	var squad := {}
	for index in ids.size():
		squad[ids[index]] = _hero(ids[index], STAGE + Vector3(-3.0 + 1.5 * index, 0, 3.0), 0.0)
	var creator := _creator(STAGE + Vector3(4.2, 0, 0.8), 0.0, "source_code")
	_dolly(STAGE + Vector3(-2.6, 1.6, -1.6), STAGE + Vector3(-1.6, 1.6, -1.0), STAGE + Vector3(0, 1.4, 2.6),
			STAGE + Vector3(0, 1.4, 2.6), 5.0, true)
	_narrate("La station. Le dernier fragment est là.", 3.0)
	await _until(6.2)
	_say(squad.sand_ghost, "Trop facile.", 1.8, -1.0)
	await _until(8.2)
	var virus := _virus_titan(STAGE + Vector3(0, 0, -14), TITAN_HEIGHT * 1.1)
	_rise(virus, TITAN_HEIGHT, 1.6)
	_glitch(2.0)
	_shake = 0.3
	_dolly(STAGE + Vector3(3.0, 0.8, 6.0), STAGE + Vector3(2.4, 0.6, 5.0), STAGE + Vector3(0, 2, -14),
			STAGE + Vector3(0, TITAN_HEIGHT, -14), 3.0, true)
	await _until(11.2)
	# The heroes are deleted one after the other.
	_dolly(STAGE + Vector3(0, 1.6, -1.8), STAGE + Vector3(0, 1.6, -1.2), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 6.0, true)
	for id in ["captain", "ronin", "kunoichi"]:
		_glitch(0.4)
		_narrate("%s : SUPPRIMÉ." % str(Loadout.find(id).item.name).to_upper(), 1.0)
		_vanish(squad[id], 0.5)
		await _until(_clock + 1.2)
	_say(squad.soldier, "NON !", 1.4, 1.0)
	await _until(16.4)
	_dolly(STAGE + Vector3(2.4, 1.6, -1.4), STAGE + Vector3(2.8, 1.7, -0.8), STAGE + Vector3(4.2, 1.6, 0.8),
			STAGE + Vector3(4.2, 1.7, 0.8), 4.0, true)
	_say(creator, "Partez. Je le retiens.", 2.0, 1.0)
	creator.play(&"shoot", true)
	_beam(creator.global_position + Vector3(0, 1.3, 0), virus.global_position + Vector3(0, TITAN_HEIGHT * 0.6, 0), VIRUS, 0.1)
	await _until(19.0)
	_impact_frame()
	_glitch(1.4)
	_fall(creator, 1.0)
	_narrate("LE CRÉATEUR : SUPPRIMÉ.", 2.0)
	await _until(21.6)
	_fade_shade(0.85, 1.0)
	_say(squad.soldier, "Il ne reste que nous…", 2.2, 1.0)
	await _until(24.0)
	_narrate("MISSION : survis à la station. Seul s'il le faut.", 3.8)
	await _until(28.6)
	_fade_shade(1.0, 1.0)
