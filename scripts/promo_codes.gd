class_name PromoCodes
## Codes typed on the home screen (CODE) for rewards: gems, credits, shop
## items, cards, boosters, battle pass tiers. Each code works once per save,
## except the ones marked "repeat" (the test code).
##
## The codes themselves are not written here, only their SHA-256 (the code in
## capitals, without spaces): the repository is public, the hash does not give
## the code away. To add one, see README ("Codes").

const USED_KEY := "promo_codes_used"
## What each code gives, by its hash:
##   "gems", "credits": amounts;
##   "items": shop item ids (heroes, guns, skins), or "all_shop";
##   "cards": card ids, or "all" (one of each);
##   "boosters": {"standard": n, "rare": n};
##   "pass_complete": every battle pass tier;
##   "christmas": turns the Christmas event on (see Events);
##   "repeat": usable again and again.
const CODES := {
	# The test code: everything.
	"f8e9ba92bc9d944d69bb7545813a0ebb8272c56cc99e860189087cc3261740eb": {
		"gems": 10000, "credits": 100000, "items": "all_shop", "cards": "all",
		"boosters": {"standard": 5, "rare": 5}, "pass_complete": true, "christmas": true, "repeat": true},
	# Le Créateur and all that is his, only through this code.
	"cd81d6f34c6dc2796f4fc3601ac73a3a45f9f9e57ddff4a905bbf37f3452a469": {
		"items": ["createur", "source_code", "ctrl_alt_del", "skin_matrix", "ship_mainframe", "pet_capybara"],
		"cards": ["card_createur", "card_source_code", "card_ctrl_alt_del", "card_matrix", "card_mainframe", "card_capybara"]},
	# BIENVENUE
	"6dc420a9ea8e9ba1307c227deeac5e85b59a7afe19a29e96effb926cc79f3c5b": {
		"gems": 500, "boosters": {"standard": 2}},
	# ESCOUADE
	"e4d370b3de8fa9d94cbe74342fb83fe5dce9c4394fcb190ab347d82db2e3cbe9": {
		"items": ["kunoichi"], "boosters": {"rare": 1}},
	# TITANMK2
	"8fd4dc1e2ddf85b78170bdf9c814910a036a6a8a41a85a10bec3653f15080aa4": {
		"gems": 1000, "cards": ["card_titan_mk2"], "boosters": {"rare": 1}},
}


## The code as stored: capitals, no spaces.
static func normalize(code: String) -> String:
	return code.strip_edges().to_upper().replace(" ", "")


## Gives the code's rewards. Returns [true, what was given] or [false, why not].
static func redeem(code: String) -> Array:
	var key := normalize(code).sha256_text()
	if not CODES.has(key):
		return [false, "Code inconnu."]
	var reward: Dictionary = CODES[key]
	var used: Array = SaveData.load_progress(USED_KEY, [])
	if key in used and not reward.get("repeat", false):
		return [false, "Code déjà utilisé."]
	var given: Array[String] = []
	if reward.has("gems"):
		Wallet.add_gems(reward.gems)
		given.append("%d gemmes" % reward.gems)
	if reward.has("credits"):
		Wallet.add_credits(reward.credits)
		given.append("%d crédits" % reward.credits)
	var items: Array = _shop_ids() if str(reward.get("items", "")) == "all_shop" else reward.get("items", [])
	var new_items := 0
	for id: String in items:
		if Wallet.give(id):
			new_items += 1
	if new_items > 0:
		given.append(Loadout.find(items[0]).item.name if items.size() == 1 else "%d objets" % new_items)
	var cards: Array = []
	if str(reward.get("cards", "")) == "all":
		for card: Dictionary in Cards.CATALOG + Cards.EXPANSION:
			cards.append(card.id)
	else:
		cards = reward.get("cards", [])
	for id: String in cards:
		Cards.add(id)
	if cards.size() == 1:
		given.append("la carte %s" % Cards.find(cards[0]).name)
	elif cards.size() > 1:
		given.append("%d cartes" % cards.size())
	var boosters: Dictionary = reward.get("boosters", {})
	for kind: String in boosters:
		Cards.give_booster(kind, boosters[kind])
		var plural := "s" if boosters[kind] > 1 else ""
		var adjective: String = {"rare": " rare", "legend": " légendaire"}.get(kind, "")
		given.append("%d booster%s%s" % [boosters[kind], plural, (adjective + plural) if adjective != "" else ""])
	if reward.get("christmas", false):
		SaveData.save_progress(Events.FORCE_KEY, true)
		given.append("l'événement de Noël")
	if reward.get("pass_complete", false):
		for season in BattlePass.SEASON_NAMES.size():
			var all_tiers := 0
			for tier in range(1, BattlePass.rewards(season).size() + 1):
				all_tiers += BattlePass.tier_cost(tier)
			BattlePass.add_xp(maxi(all_tiers - BattlePass.total_xp(season), 0), season)
		given.append("tout le passe de combat")
		# And an egg ready to hatch, to try it.
		if Pets.give_egg():
			SaveData.save_progress(Pets.EGG_WAVES_KEY, Pets.HATCH_WAVES)
			given.append("un œuf prêt à éclore")
	if key not in used:
		used.append(key)
		SaveData.save_progress(USED_KEY, used)
	return [true, ", ".join(given)]


static func _shop_ids() -> Array:
	var ids := []
	for group: Array in [Loadout.CHARACTERS, Loadout.WEAPONS, Loadout.SKINS, Loadout.SHIPS, Dances.LIST, Pets.LIST]:
		for item: Dictionary in group:
			# The pets of the eggs too: the test code has everything.
			if item.get("shop", false) or item.get("egg", false):
				ids.append(item.id)
	return ids
