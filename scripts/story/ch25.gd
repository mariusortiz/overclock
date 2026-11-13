extends Season3Scene
## Chapitre 25 : Les Ruines stellaires. A gold statue with a cow's head on the
## arch, and looters in the ruins.


func _init() -> void:
	episode_number = 25
	episode_title = "LES RUINES STELLAIRES"
	duration = 27.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("ruins")
	_moons()
	_statue(Vector3(0, 10.7, -26), PI, 4.0)
	_fade_shade(0.0, 0.6)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0, 0, 0), 0.0)
	_dolly(STAGE + Vector3(0, 1.4, 4), STAGE + Vector3(0, 1.2, 3), STAGE + Vector3(0, 2, -10), Vector3(0, 12, -26), 5.0)
	_narrate("Les ruines. Sur l'arche, une statue d'or à tête de vache.", 3.2)
	await _until(7.0)
	_dolly(STAGE + Vector3(1.4, 1.7, -2.4), STAGE + Vector3(1.1, 1.7, -2.8), STAGE + Vector3(0, 1.5, 0), STAGE + Vector3(0, 1.5, 0), 5.0)
	kunoichi.get_parent().rotation.y = PI
	_say(kunoichi, "« Le Premier Codeur. » Je savais lire ça, avant.", 3.0, 1.0)
	await _until(10.6)
	for index in 3:
		var looter := _npc("Pirate_Male.fbx", STAGE + Vector3(-4 + 4.0 * index, 0, -8), PI)
		looter.play(&"walk")
	_dolly(STAGE + Vector3(-3, 1.6, 3), STAGE + Vector3(-2.4, 1.6, 2.4), STAGE + Vector3(0, 1.2, -8), STAGE + Vector3(0, 1.2, -8), 5.0)
	_narrate("Des pillards fouillent les ruines. Et la pierre se met à trembler.", 3.4)
	await _until(14.6)
	_narrate("MISSION : repousse les pillards jusqu'au golem qui s'éveille.", 3.6)
	await _until(19.6)
	_fade_shade(1.0, 1.0)
