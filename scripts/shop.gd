class_name Shop
## What the shop sells and at what price: every Loadout item marked "shop",
## plus the gem packs sold for real money (see Billing). Each day, four items
## are featured, the same for every player, one of them 30 % off.

const DAILY_COUNT := 4
const DAILY_DISCOUNT := 0.3

## Prices by kind of item: [credits, gems].
const PRICES := {
	"Personnage": [6000, 450],
	"Arme": [3500, 260],
	"Skin d'arme": [2500, 180],
}

## Gem packs, as Play Console product ids (managed products, consumed when
## bought so that they can be bought again).
const GEM_PACKS: Array[Dictionary] = [
	{"product": "gems_100", "gems": 100, "label": "Poignée"},
	{"product": "gems_550", "gems": 550, "label": "Sac (+10 %)"},
	{"product": "gems_1200", "gems": 1200, "label": "Coffre (+20 %)"},
]


## Every item for sale, as {"item", "kind", "credits", "gems"}.
static func catalog() -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	for group: Array in [["Personnage", Loadout.CHARACTERS], ["Arme", Loadout.WEAPONS], ["Skin d'arme", Loadout.SKINS]]:
		for item: Dictionary in group[1]:
			if item.get("shop", false):
				var price: Array = PRICES[group[0]]
				offers.append({"item": item, "kind": group[0], "credits": price[0], "gems": price[1], "discount": false})
	return offers


## Today's featured items: the first one is discounted.
static func daily() -> Array[Dictionary]:
	var all := catalog()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("shop " + Time.get_date_string_from_system())
	# Fisher-Yates with the day's seed: everyone sees the same offers.
	for i in range(all.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := all[i]
		all[i] = all[j]
		all[j] = swap
	var featured := all.slice(0, DAILY_COUNT)
	var deal: Dictionary = featured[0].duplicate()
	deal.credits = roundi(deal.credits * (1.0 - DAILY_DISCOUNT))
	deal.gems = roundi(deal.gems * (1.0 - DAILY_DISCOUNT))
	deal.discount = true
	featured[0] = deal
	return featured


## Seconds until the offers change (local midnight).
static func seconds_to_refresh() -> int:
	var now := Time.get_time_dict_from_system()
	return 86400 - (now.hour * 3600 + now.minute * 60 + now.second)
