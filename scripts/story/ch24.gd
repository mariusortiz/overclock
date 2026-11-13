extends Season3Scene
## Chapitre 24 : La Ceinture. Crystal for fuel, and the asteroid belt.


func _init() -> void:
	episode_number = 24
	episode_title = "LA CEINTURE"
	duration = 25.0


func _story() -> void:
	await _title_card(2.6)
	_load_space(2)
	_fade_shade(0.0, 0.6)
	var vipere := _ship("VIPÈRE", RED, -6.0, Vector2(2, 0), 1.0)
	_overlay(vipere, Color(CRYSTAL, 0.25))
	_follow(vipere, Vector3(0, 2.6, 8), Vector3(0, 0.5, -20))
	_speed(2.0)
	_narrate("Des moteurs au cristal, et la ceinture d'astéroïdes à traverser.", 3.2)
	await _until(6.8)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "Enfin un endroit où piloter pour de vrai.", 2.6, -1.0, 1.0)
	await _until(9.8)
	for index in 3:
		var drone := _ship("DRONE", Color(0.3, 0.5, 0.9), vipere.distance - 10.0 - 5.0 * index, Vector2((index % 2) * 6.0 - 3.0, 1.0), 1.2)
		_overlay(drone, Color(CRYSTAL, 0.5))
	_follow(vipere, Vector3(0, 2.0, -9), Vector3(0, 0.5, 6))
	_narrate("Des drones de cristal, dans le sillage.", 2.6)
	await _until(13.0)
	_narrate("MISSION : termine la course 2e ou mieux.", 3.0)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
