extends Season2Episode
## Épisode 18 : Écran noir. At the station, the last fragment. The Virus
## strikes: the heroes are deleted one after the other, Le Créateur fights it
## alone and falls. Only the Soldier and Vipère remain.


func _init() -> void:
	episode_number = 18
	episode_title = "ÉCRAN NOIR"
	duration = 106.0


func _story() -> void:
	_load_arena(0)
	var ids := ["captain", "ronin", "kunoichi", "soldier", "sand_ghost", "paladin"]
	var squad := {}
	for index in ids.size():
		squad[ids[index]] = _hero(ids[index], STAGE + Vector3(-3.0 + 1.2 * index, 0, 1.0 + absf(index - 2.5) * 0.3), 0.0)
	var creator := _creator(STAGE + Vector3(0, 0, -2.5), PI, "source_code")
	_dolly(STAGE + Vector3(0, 2.2, -8), STAGE + Vector3(0, 2.0, -7), STAGE + Vector3(0, 1.3, 0), STAGE + Vector3(0, 1.3, 0), 8.0, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La station. Le dernier fragment est caché sous le hangar.", 3.2)
	await _until(5.2)
	_say(creator, "Quand je l'aurai, tout sera fini. Restez groupés.", 3.0, 1.0)
	await _until(8.6)
	await _title_card(5.0)

	# 13.6 s: the fragment.
	var fragment := STAGE + Vector3(0, 1.2, -6)
	_ring(fragment, VIRUS, 2.0, 2.0)
	_dolly(STAGE + Vector3(2, 1.6, -2), STAGE + Vector3(1.6, 1.6, -2.6), fragment, fragment, 5.0, true)
	creator.play(&"walk", true)
	_move(creator.get_parent() as Node3D, Vector3(0, 0, -0.8))
	await _until(17.0)
	_movers.clear()
	creator.play(&"idle")
	_narrate("Le dernier fragment.", 2.4)
	await _until(20.0)

	# 20 s: the screens go black.
	_glitch(2.0)
	_impact_frame()
	_shade.color = Color(0, 0, 0, 0)
	_fade_shade(0.9, 0.2)
	await _until(20.6)
	_fade_shade(0.0, 0.4)
	_narrate("ERREUR. ERREUR. ERREUR.", 2.4, true)
	var virus := _virus_titan(STAGE + Vector3(0, 0, -14), TITAN_HEIGHT * 1.1)
	_appear(virus, 1.0)
	_dolly(STAGE + Vector3(-3, 0.6, 5), STAGE + Vector3(-2.4, 0.8, 4.4), STAGE + Vector3(0, 3, -14), STAGE + Vector3(0, TITAN_HEIGHT, -14), 5.0, true)
	await _until(24.4)
	_say(squad.captain, "Il était là depuis le début !", 2.2, -1.0)
	await _until(27.0)

	# 27 s: they are deleted, one after the other.
	for id in ["captain", "ronin", "paladin", "kunoichi"]:
		var hero: CharacterModel = squad[id]
		_dolly(hero.global_position + Vector3(1.6, 1.5, -2.6), hero.global_position + Vector3(1.4, 1.5, -2.2), hero.global_position + Vector3.UP * 1.2, hero.global_position + Vector3.UP * 1.2, 2.4, true)
		_beam(virus.global_position + Vector3.UP * TITAN_HEIGHT, hero.global_position + Vector3.UP, VIRUS, 0.1)
		_glitch(0.4)
		_vanish(hero, 0.8)
		await _until(_clock + 1.4)
		_narrate("%s : supprimé." % Loadout.find(id).item.name, 1.2)
		await _until(_clock + 1.0)
	await _until(37.0)

	# 37 s: Le Créateur, alone against it.
	_dolly(STAGE + Vector3(3, 1.4, 0), STAGE + Vector3(2.6, 1.5, -0.6), STAGE + Vector3(0, 1.6, -3.3), STAGE + Vector3(0, 1.6, -3.3), 4.0, true)
	_face(creator, virus)
	_say(creator, "C'est moi que tu veux. Laisse-les.", 2.6, 1.0)
	await _until(40.0)
	creator.play(&"shoot", true)
	_narrate("ACCÈS ROOT", 1.4, true)
	_beam(creator.global_position + Vector3.UP * 1.4, virus.global_position + Vector3.UP * TITAN_HEIGHT * 0.8, VIRUS, 0.3)
	_ring(virus.global_position + Vector3.UP * 4.0, VIRUS, 18.0, 0.8)
	_impact_frame()
	_shake = 0.3
	await _until(42.0)
	_glitch(1.6)
	_dolly(STAGE + Vector3(0, 4, 8), STAGE + Vector3(0, 5, 7), STAGE + Vector3(0, 6, -14), STAGE + Vector3(0, 4, -8), 4.0, true)
	_narrate("La clé... retournée contre lui.", 2.6)
	await _until(45.0)
	_beam(virus.global_position + Vector3.UP * TITAN_HEIGHT, creator.global_position + Vector3.UP, VIRUS, 0.3)
	creator.play(&"die", true)
	_impact_frame()
	await _until(46.4)
	_dolly(STAGE + Vector3(1.2, 0.8, -1.2), STAGE + Vector3(1.0, 0.7, -1.6), STAGE + Vector3(0, 0.6, -3.3), STAGE + Vector3(0, 0.6, -3.3), 4.0, true)
	_say(creator, "J'ai écrit... une ligne de trop...", 2.6, 1.0, 1.0)
	await _until(49.4)
	_vanish(creator, 1.2)
	await _until(51.0)

	# 51 s: two left.
	_dolly(STAGE + Vector3(0, 1.4, 6), STAGE + Vector3(0, 1.5, 5), STAGE + Vector3(0, 1.4, 1.2), STAGE + Vector3(0, 1.4, 1.2), 8.0, true)
	_face(squad.soldier, squad.sand_ghost)
	_face(squad.sand_ghost, squad.soldier)
	_say(squad.sand_ghost, "Il... a disparu. Lui aussi.", 2.4, 1.0)
	await _until(54.0)
	_say(squad.soldier, "Il ne reste que nous deux.", 2.2, -1.0)
	await _until(56.6)
	_glitch(2.5)
	_shake = 0.2
	await _until(57.4)
	_fade_shade(1.0, 2.0)
	_narrate("ÉCRAN NOIR.", 2.6, true)
	await _until(61.0)
	await _to_be_continued(90.0)
