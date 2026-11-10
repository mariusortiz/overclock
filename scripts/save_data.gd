class_name SaveData
## Local save file (best score). Lives in the app's private storage on
## Android and in the browser's storage on the web.

const PATH := "user://save.cfg"
const SECTION := "scores"
const KEY := "high_score"


static func load_high_score() -> int:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return 0
	return config.get_value(SECTION, KEY, 0)


static func save_high_score(value: int) -> void:
	var config := ConfigFile.new()
	config.load(PATH)  # keep other saved values, if any
	config.set_value(SECTION, KEY, value)
	config.save(PATH)
