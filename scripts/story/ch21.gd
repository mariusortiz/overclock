extends Season3Scene
## Chapitre 21 : Le Portail. A ring of light over the station; creatures of
## crystal come through it.


func _init() -> void:
	episode_number = 21
	episode_title = "LE PORTAIL"
	duration = 26.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var heroes := _squad(STAGE + Vector3(0, 0, 2), PI, ["kunoichi", "soldier", "captain"], 1.6, true)
	_dolly(STAGE + Vector3(0, 1.6, 8), STAGE + Vector3(0, 1.6, 7), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 5.0)
	_narrate("La station, une semaine après le redémarrage.", 2.8)
	await _until(6.0)
	var portal := _portal(STAGE + Vector3(0, 9, -10), 4.0)
	_open(portal, 1.4)
	_dolly(STAGE + Vector3(0, 1.2, 8), STAGE + Vector3(0, 1.0, 7), STAGE + Vector3(0, 2, 0), STAGE + Vector3(0, 9, -10), 3.0)
	_narrate("Un anneau de lumière s'ouvre au-dessus du hangar.", 3.0)
	await _until(9.6)
	for index in 4:
		var creature := _crystal_creature(STAGE + Vector3(-4.5 + 3.0 * index, 0, -6), 0.0, &"aim")
		(creature.get_parent() as Node3D).rotation.y = PI
		Effects.burst(_set, creature.global_position + Vector3.UP, CRYSTAL, 20)
	_dolly(STAGE + Vector3(-3, 1.6, 5), STAGE + Vector3(-2.4, 1.6, 4.4), STAGE + Vector3(0, 1.2, -6), STAGE + Vector3(0, 1.2, -6), 5.0)
	await _until(11.0)
	_say(heroes.soldier, "Des créatures de cristal ! Par l'anneau !", 2.6, -1.0)
	await _until(14.0)
	_say(heroes.captain, "Protégez les zones, je veux comprendre ce truc.", 2.8, 1.0)
	await _until(17.4)
	_narrate("MISSION : tiens les zones de la station pendant que l'anneau grandit.", 4.0)
	await _until(22.0)
	_fade_shade(1.0, 1.0)
