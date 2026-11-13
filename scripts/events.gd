class_name Events
## Seasonal events. Christmas runs from December 1st to January 6th, every
## year, by the device's date; the test code turns it on at any time (saved).
## During it: the Christmas waves (a short game in the snow village against
## the Père Glaçon), the shop's Christmas items, Christmas daily challenges,
## a gift every day, snow and music on the home screen, and the "Noël" cards
## in the boosters. What was bought or won stays after it.

const FORCE_KEY := "event_christmas_forced"
const GIFT_KEY := "event_christmas_gift"
const CLEARED_KEY := "event_christmas_cleared"
## The snow village (see scenes/arenas/snow.tscn), after the six arenas.
const SNOW_ARENA := 6
## Christmas waves: a boss every five, the second one ends the game.
const CHRISTMAS_WAVES := 10
const CLEAR_GEMS := 300

## Set by the menu: the game starting is the Christmas waves.
static var christmas_run := false


static func is_christmas() -> bool:
	if SaveData.load_progress(FORCE_KEY, false):
		return true
	var date := Time.get_date_dict_from_system()
	return date.month == 12 or (date.month == 1 and date.day <= 6)


## Is the item (or card) of event `event` available now? Items without one always are.
static func is_on(event: String) -> bool:
	return event == "" or (event == "christmas" and is_christmas())


## Today's gift is still to open.
static func gift_ready() -> bool:
	return is_christmas() and SaveData.load_progress(GIFT_KEY, "") != Time.get_date_string_from_system()


## Opens today's gift: a booster (a rare one on the 24th and 25th). Returns what it was.
static func open_gift() -> String:
	if not gift_ready():
		return ""
	SaveData.save_progress(GIFT_KEY, Time.get_date_string_from_system())
	var date := Time.get_date_dict_from_system()
	var kind := "rare" if date.month == 12 and date.day in [24, 25] else "standard"
	Cards.give_booster(kind)
	return "un booster rare" if kind == "rare" else "un booster"


## The Christmas waves are won: gems and a booster the first time each year.
static func clear_reward() -> String:
	# The event straddles New Year: January's days count for December's year.
	var date := Time.get_date_dict_from_system()
	var year := str(date.year if date.month == 12 else date.year - 1)
	if SaveData.load_progress(CLEARED_KEY, "") == year:
		Wallet.add_credits(200)
		return "200 crédits"
	SaveData.save_progress(CLEARED_KEY, year)
	Wallet.add_gems(CLEAR_GEMS)
	Cards.give_booster("rare")
	return "%d gemmes et un booster rare" % CLEAR_GEMS
