extends Season2Scene
## Chapitre 17 : Mise à jour. In the volcano, the Directeur is back, taken by
## the Virus, with a corrupted dragon. Le Créateur frees him.


func _init() -> void:
	episode_number = 17
	episode_title = "MISE À JOUR"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(3)
	_fade_shade(0.0, 0.6)
	var paladin := _hero("paladin", STAGE + Vector3(-0.9, 0, 3.0), 0.0)
	var soldier := _hero("soldier", STAGE + Vector3(0.9, 0, 3.0), 0.0)
	_embers(true)
	_dolly(STAGE + Vector3(0, 1.6, -1.6), STAGE + Vector3(0, 1.6, -0.6), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 5.0, true)
	_narrate("Le volcan. Le deuxième fragment est au fond de la base.", 3.0)
	await _until(6.2)
	_say(paladin, "Quelqu'un nous attend.", 2.0, -1.0)
	await _until(8.4)
	var directeur := _npc("Suit_Male.fbx", STAGE + Vector3(0, 0, -4.0), PI)
	_corrupt(directeur)
	var dragon := _spawn_boss(Boss.Kind.COLOSSUS, STAGE + Vector3(0, 0, -11), 4.2)
	_corrupt(dragon)
	_glitch(1.0)
	_dolly(STAGE + Vector3(1.6, 1.5, -0.8), STAGE + Vector3(1.2, 1.6, -1.6), STAGE + Vector3(0, 1.5, -4),
			STAGE + Vector3(0, 1.8, -4), 4.0, true)
	_narrate("Le Directeur. Et le Virus parle par sa bouche.", 3.0)
	await _until(11.8)
	_say(directeur, "MISE À JOUR EN COURS.", 2.2, 1.0)
	await _until(14.2)
	_dolly(STAGE + Vector3(2.6, 1.0, 5.2), STAGE + Vector3(2.0, 0.8, 4.4), STAGE + Vector3(0, 2, -11),
			STAGE + Vector3(0, 3, -11), 3.0, true)
	_stomp(STAGE + Vector3(0, 0, -11), 1.2)
	_impact_frame()
	_shake = 0.2
	await _until(16.4)
	var creator := _creator(STAGE + Vector3(2.0, 0, -2.6), PI / 2.0)
	_appear(creator)
	_dolly(STAGE + Vector3(0.6, 1.6, -0.2), STAGE + Vector3(0.9, 1.6, -0.6), STAGE + Vector3(1.0, 1.5, -3.4),
			STAGE + Vector3(1.0, 1.5, -3.4), 5.0, true)
	await _until(17.4)
	_say(creator, "Annuler la mise à jour.", 2.0, 1.0)
	creator.play(&"melee")
	await _until(19.0)
	_glitch(0.8)
	_ring(STAGE + Vector3(0, 0.1, -4.0), VIRUS, 4.0, 0.8)
	for mesh: MeshInstance3D in directeur.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = null
	_fall(directeur, 1.0)
	await _until(20.4)
	_say(soldier, "Il est… redevenu lui-même ?", 2.2, 1.0)
	await _until(22.8)
	_narrate("MISSION : le dragon est toujours là. Traverse le volcan et abats-le.", 4.0)
	await _until(27.6)
	_fade_shade(1.0, 1.0)
