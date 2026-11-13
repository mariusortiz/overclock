extends Node
## Writes the card catalog for the website's card page (site/carte.html), as
## JSON: each card with its trade key (see Trade), texts, rarity and art.
##   godot --headless res://scenes/tools/export_cards.tscn -- --out=cards.json


func _ready() -> void:
	var out := "cards.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			out = argument.get_slice("=", 1)
	var cards := []
	for card: Dictionary in Cards.CATALOG:
		var rarity: Dictionary = Cards.RARITY[card.rarity]
		cards.append({
			"key": Trade.card_key(card.id).hex_encode(),
			"id": card.id, "name": card.name, "series": card.series,
			"rarity": card.rarity, "rarity_name": rarity.name, "color": (rarity.color as Color).to_html(false),
			"number": Cards.number(card), "power": Cards.power(card), "ability": Cards.ability(card),
		})
	var file := FileAccess.open(out, FileAccess.WRITE)
	file.store_string(JSON.stringify(cards))
	file.close()
	print("CARDS %d written to %s" % [cards.size(), out])
	get_tree().quit()
