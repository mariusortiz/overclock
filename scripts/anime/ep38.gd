extends Season4Episode
## Épisode 38 : Le Reflet. The tower's top. Le Reflet copies whoever faces
## him: the soldier's gun, the kunoichi's speed, the ronin's blade. Every
## attack comes back. Le Créateur understands: he copies what he sees. So
## they must show him something he cannot copy.


func _init() -> void:
	episode_number = 38
	episode_title = "LE REFLET"
	duration = 53.0


func _story() -> void:
	_load_mirror_world()
	var reflect := _reflect(STAGE + Vector3(0, 0, -5), PI, 3.4)
	var heroes := _squad(STAGE + Vector3(0, 0, 2), 0.0, ["soldier", "kunoichi", "ronin"], 2.0, true)
	var creator := _creator(STAGE + Vector3(0, 0, 4.2), 0.0)
	_dolly(STAGE + Vector3(5, 2.4, -1), STAGE + Vector3(4.4, 2.2, -1.6), STAGE + Vector3(0, 1.8, -5), STAGE + Vector3(0, 2.0, -5), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Le sommet de la tour.", 2.2)
	await _until(4.0)
	_say(reflect, "Montrez-moi ce que vous savez faire.", 2.4, 1.0, 3.6)
	await _until(6.8)
	await _title_card(5.0)

	# 11.8 s: every attack comes back.
	_dolly(STAGE + Vector3(4.6, 1.8, -1), STAGE + Vector3(4.2, 1.8, -1.4), STAGE + Vector3(0, 1.4, -1.5), STAGE + Vector3(0, 1.4, -1.5), 10.0)
	var soldier: CharacterModel = heroes.soldier
	soldier.play(&"shoot", true)
	_beam(soldier.global_position + Vector3.UP * 1.3, reflect.global_position + Vector3.UP * 2.4, GOLD, 0.07)
	await _until(12.6)
	reflect.play(&"shoot", true)
	_beam(reflect.global_position + Vector3.UP * 2.4, soldier.global_position + Vector3.UP * 1.3, GOLD, 0.07)
	_shake = 0.2
	await _until(13.6)
	_narrate("Le même tir. Renvoyé.", 2.2, true)
	await _until(16.0)
	var ronin: CharacterModel = heroes.ronin
	ronin.play(&"melee", true)
	await _until(16.6)
	reflect.play(&"melee", true)
	Effects.burst(_set, ronin.global_position + Vector3.UP * 1.4, MIRROR, 40)
	_say(ronin, "Ma lame. Il a pris ma lame.", 2.0, -1.0)
	await _until(19.0)
	_say(heroes.kunoichi, "Et ma vitesse. C'est vexant.", 2.0, 1.0)
	await _until(21.4)
	_say(reflect, "Tout ce que vous me montrez devient à moi.", 2.6, 1.0, 3.6)
	await _until(24.4)

	# 24.4 s: Le Créateur sees it.
	# From above the squad's heads, down onto him.
	_dolly(STAGE + Vector3(0.4, 3.4, 0.4), STAGE + Vector3(0.3, 3.3, 0.7), STAGE + Vector3(0, 1.5, 4.2), STAGE + Vector3(0, 1.5, 4.2), 8.0)
	_say(creator, "Il copie ce qu'il voit. Seulement ce qu'il voit.", 2.8, 1.0)
	await _until(27.6)
	_say(creator, "Alors il faut lui montrer quelque chose qu'il ne peut pas copier.", 3.2, 1.0)
	await _until(31.2)
	_say(heroes.soldier, "Comme quoi ?", 1.4, -1.0)
	await _until(33.0)
	_say(creator, "Comme nous tous. En même temps.", 2.2, 1.0)
	await _until(35.6)

	# 35.6 s: he grows.
	_dolly(STAGE + Vector3(0, 2, 6), STAGE + Vector3(0, 4, 10), STAGE + Vector3(0, 2, -5), STAGE + Vector3(0, 7, -8), 6.0)
	var grow := create_tween()
	grow.tween_property(_pivot_of(reflect), "scale", Vector3.ONE * 2.6, 3.0).set_ease(Tween.EASE_IN_OUT)
	_shake = 0.3
	await _until(36.6)
	_narrate("Le Reflet a vu le Titan, autrefois.", 2.6, true)
	await _until(39.6)
	_say(reflect, "Moi aussi, je peux être grand.", 2.2, 1.0, 9.0)
	await _until(42.2)
	await _to_be_continued(42.6)
