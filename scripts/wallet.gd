class_name Wallet
## The player's two currencies and what they bought in the shop.
## Credits are earned by playing; gems are earned in small amounts (bosses,
## all the daily challenges) or bought with real money (see Billing).

const CREDITS_KEY := "credits"
const GEMS_KEY := "gems"
const OWNED_KEY := "owned"
## Credits per point of score at the end of a game (half after a death).
const CREDITS_PER_SCORE_POINT := 0.1
const GEMS_PER_BOSS := 3
const GEMS_FOR_ALL_CHALLENGES := 10


static func credits() -> int:
	return SaveData.load_progress(CREDITS_KEY, 0)


static func gems() -> int:
	return SaveData.load_progress(GEMS_KEY, 0)


static func add_credits(amount: int) -> void:
	SaveData.save_progress(CREDITS_KEY, credits() + amount)


static func add_gems(amount: int) -> void:
	SaveData.save_progress(GEMS_KEY, gems() + amount)


static func owns(id: String) -> bool:
	return id in _owned()


## Pays `price` in `currency` ("credits" or "gems") and adds `id` to what the
## player owns. Returns false, changing nothing, when the balance is short.
static func buy(id: String, price: int, currency: String) -> bool:
	if owns(id):
		return false
	var balance := credits() if currency == CREDITS_KEY else gems()
	if balance < price:
		return false
	SaveData.save_progress(currency, balance - price)
	var owned := _owned()
	owned.append(id)
	SaveData.save_progress(OWNED_KEY, owned)
	return true


## Adds `id` to what the player owns, for free (a code). False if already owned.
static func give(id: String) -> bool:
	if owns(id):
		return false
	var owned := _owned()
	owned.append(id)
	SaveData.save_progress(OWNED_KEY, owned)
	return true


## Pays `price` for something used up (a booster). False if too poor.
static func spend(price: int, currency: String) -> bool:
	var balance := credits() if currency == CREDITS_KEY else gems()
	if balance < price:
		return false
	SaveData.save_progress(currency, balance - price)
	return true


static func credits_for_score(score: int) -> int:
	return roundi(score * CREDITS_PER_SCORE_POINT)


static func _owned() -> Array:
	return SaveData.load_progress(OWNED_KEY, [])
