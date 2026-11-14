class_name Mastery
## Mastery of each gun and blade, counted in eliminations. Three tiers:
## bronze (a mention in the arsenal), gold and diamond (a finish of their own,
## worn by that weapon when the "mastery finish" option is on and no other
## skin is chosen, see Loadout.mastery_skin).

const SAVE_KEY := "mastery"
const FINISH_KEY := "mastery_finish"
## Eliminations needed for bronze, gold and diamond.
const TIERS := [100, 500, 2000]
const TIER_NAMES := ["Aucune", "Bronze", "Or", "Diamant"]
const TIER_COLORS := [Color(1, 1, 1, 0.6), Color(0.85, 0.55, 0.3), Color(1.0, 0.82, 0.3), Color(0.7, 0.95, 1.0)]
## The finishes (shaders/skin_fx.gdshader modes 11 and 12), shaped like
## Loadout.SKINS entries but not sold nor listed.
const GOLD := {"id": "mastery_gold", "name": "Maîtrise Or", "pattern": true, "fx": 11,
		"colors": [Color(1.0, 0.82, 0.3), Color(0.45, 0.28, 0.05)], "glow": 0.0, "scope": true, "silencer": false,
		"shot": Color(1.0, 0.85, 0.35), "kill": &"statue"}
const DIAMOND := {"id": "mastery_diamond", "name": "Maîtrise Diamant", "pattern": true, "fx": 12,
		"colors": [Color(0.85, 0.97, 1.0), Color(0.35, 0.55, 0.75)], "glow": 0.0, "scope": true, "silencer": true,
		"shot": Color(0.75, 0.95, 1.0), "kill": &"shatter"}


static func kills(id: String) -> int:
	return int(SaveData.load_progress(SAVE_KEY, {}).get(id, 0))


## 0 (none) to 3 (diamond).
static func tier(id: String) -> int:
	var count := kills(id)
	var reached := 0
	for goal: int in TIERS:
		if count >= goal:
			reached += 1
	return reached


## "Or · 734 / 2000 éliminations" for the arsenal.
static func text(id: String) -> String:
	var reached := tier(id)
	var count := kills(id)
	if reached >= TIERS.size():
		return "Maîtrise %s · %d éliminations" % [TIER_NAMES[reached], count]
	return "Maîtrise %s · %d / %d éliminations" % [TIER_NAMES[reached], count, TIERS[reached]]


## Adds a game's eliminations (gun id -> count, blade id -> count).
static func record(guns: Dictionary, blades: Dictionary) -> void:
	var saved: Dictionary = SaveData.load_progress(SAVE_KEY, {})
	for source: Dictionary in [guns, blades]:
		for id: String in source:
			if id != "":
				saved[id] = int(saved.get(id, 0)) + int(source[id])
	SaveData.save_progress(SAVE_KEY, saved)


static func finish_on() -> bool:
	return SaveData.load_value(FINISH_KEY, true)


static func set_finish_on(on: bool) -> void:
	SaveData.save_value(FINISH_KEY, on)


## The mastery finish the weapon wears, or {} (none, or the option is off).
static func finish(id: String) -> Dictionary:
	if not finish_on():
		return {}
	match tier(id):
		3:
			return DIAMOND
		2:
			return GOLD
	return {}
