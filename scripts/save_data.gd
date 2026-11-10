class_name SaveData
## Local save file (best score, selected skins). Lives in the app's private
## storage on Android and in the browser's storage on the web.

const PATH := "user://save.cfg"
const SCORES := "scores"
const HIGH_SCORE := "high_score"
const LOADOUT := "loadout"


static func load_high_score() -> int:
	return _load(SCORES, HIGH_SCORE, 0)


static func save_high_score(value: int) -> void:
	_save(SCORES, HIGH_SCORE, value)


static func load_value(key: String, default: Variant) -> Variant:
	return _load(LOADOUT, key, default)


static func save_value(key: String, value: Variant) -> void:
	_save(LOADOUT, key, value)


static func _load(section: String, key: String, default: Variant) -> Variant:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return default
	return config.get_value(section, key, default)


static func _save(section: String, key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(PATH)  # keep the other saved values
	config.set_value(section, key, value)
	config.save(PATH)
