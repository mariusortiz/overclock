class_name Weather
## Time of day and weather, drawn for each arena of a game (the "Météo"
## setting turns them off). Day, dusk or night; clear, rain, fog or storm.
## A light touch on the game: at night the enemies glow red; in the fog the
## aim assist does not reach far targets. Never in the Matrice, the snow
## village, the abyss, nor in the story mode (see Weather.allowed).

enum Hour { DAY, DUSK, NIGHT }
enum Clouds { CLEAR, RAIN, FOG, STORM }

const NIGHT_GLOW := Color(1.0, 0.15, 0.1, 0.18)
## In the fog, the aim assist ignores targets farther than this.
const FOG_ASSIST_RANGE := 22.0
const NAMES := {Hour.DUSK: "CRÉPUSCULE", Hour.NIGHT: "NUIT"}
const SKY_NAMES := {Clouds.RAIN: "PLUIE", Clouds.FOG: "BROUILLARD", Clouds.STORM: "ORAGE"}

## What is playing now (read by Enemy and Weapon).
static var time := Hour.DAY
static var sky := Clouds.CLEAR


static func reset() -> void:
	time = Hour.DAY
	sky = Clouds.CLEAR


static func fog() -> bool:
	return sky == Clouds.FOG


## Whether this arena may change with the weather.
static func allowed(arena: Arena) -> bool:
	if not Settings.weather or Story.is_active() or Events.christmas_run or Events.valentine_run:
		return false
	return not arena.corrupted and not arena.display_name in ["VILLAGE ENNEIGÉ", "ABYSSE", "JARDIN DES CŒURS"]


## Draws a time and a weather for the arena and dresses it; returns what was
## drawn, to announce ("" for a clear day). `forced` (tests): "night", "rain",
## "fog", "storm" or "dusk".
static func apply(arena: Arena, forced := "") -> String:
	reset()
	if not allowed(arena) and forced == "":
		return ""
	var roll := randf()
	time = Hour.DAY if roll < 0.55 else (Hour.DUSK if roll < 0.8 else Hour.NIGHT)
	roll = randf()
	sky = Clouds.CLEAR if roll < 0.55 else (Clouds.RAIN if roll < 0.75 else (Clouds.FOG if roll < 0.9 else Clouds.STORM))
	match forced:
		"night":
			time = Hour.NIGHT
		"dusk":
			time = Hour.DUSK
		"rain":
			sky = Clouds.RAIN
		"fog":
			sky = Clouds.FOG
		"storm":
			sky = Clouds.STORM
	# The scene's environment is shared by every copy of the arena: change a
	# copy of it.
	var world := arena.get_node("WorldEnvironment") as WorldEnvironment
	var environment: Environment = world.environment.duplicate(true)
	world.environment = environment
	var sun := arena.get_node("Sun") as DirectionalLight3D
	var sky_material: ProceduralSkyMaterial = null
	if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
		sky_material = environment.sky.sky_material
	match time:
		Hour.DUSK:
			sun.light_color = Color(1.0, 0.6, 0.35)
			sun.light_energy *= 0.6
			environment.ambient_light_color = environment.ambient_light_color.lerp(Color(0.85, 0.5, 0.45), 0.6)
			environment.fog_light_color = Color(0.75, 0.42, 0.3)
			_paint_sky(sky_material, Color(0.25, 0.15, 0.35), Color(1.0, 0.5, 0.25))
		Hour.NIGHT:
			sun.light_color = Color(0.55, 0.65, 1.0)
			sun.light_energy *= 0.3
			environment.ambient_light_color = Color(0.3, 0.36, 0.6)
			environment.ambient_light_energy *= 0.7
			environment.fog_light_color = Color(0.03, 0.04, 0.09)
			environment.glow_bloom = 0.0
			_paint_sky(sky_material, Color(0.0, 0.0, 0.03), Color(0.04, 0.06, 0.15))
	if sky != Clouds.CLEAR:
		sun.light_energy *= 0.7
		if sky_material:
			var share := 0.6 if time == Hour.DAY else 0.2
			_paint_sky(sky_material, sky_material.sky_top_color.lerp(Color(0.3, 0.32, 0.36), share),
					sky_material.sky_horizon_color.lerp(Color(0.45, 0.47, 0.5), share))
		if time == Hour.DAY:
			environment.fog_light_color = environment.fog_light_color.lerp(Color(0.5, 0.52, 0.56), 0.6)
	if sky == Clouds.FOG:
		environment.fog_enabled = true
		environment.fog_light_color = Color(0.6, 0.63, 0.68) if time == Hour.DAY else Color(0.15, 0.16, 0.2)
		environment.fog_density = 0.045
	if sky in [Clouds.RAIN, Clouds.STORM]:
		var weather := WeatherFx.new()
		weather.storm = sky == Clouds.STORM
		weather.sun = sun
		arena.add_child(weather)
	var parts: Array[String] = []
	if NAMES.has(time):
		parts.append(NAMES[time])
	if SKY_NAMES.has(sky):
		parts.append(SKY_NAMES[sky])
	return "  ·  ".join(parts)


## The sky's top and horizon, the ground below the horizon alike.
static func _paint_sky(material: ProceduralSkyMaterial, top: Color, horizon: Color) -> void:
	if material == null:
		return
	material.sky_top_color = top
	material.sky_horizon_color = horizon
	material.ground_bottom_color = top
	material.ground_horizon_color = horizon
