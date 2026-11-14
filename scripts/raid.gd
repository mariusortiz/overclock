class_name Raid
## The raid: the Léviathan (Boss.Kind.LEVIATHAN), alone in its abyss, for 2
## to 4 players over the Wi-Fi (Net mode "raid", run like the co-op waves),
## or alone with two allied bots (RaidAlly). One wave: the boss and its cores.

const ARENA := 9
const ALLIES := 2
const CLEARED_KEY := "raid_cleared"
## The first victory pays these, once.
const FIRST_GEMS := 300
const SKIN_ID := "skin_abyss"

## On for a raid game (set by the menu or the lobby, read by Main).
static var active := false


## The rewards of a victory, as lines for the end screen: the first one
## pays gems and the Abysse skin.
static func reward() -> Array:
	Achievements.set_flag("raid_win")
	if SaveData.load_progress(CLEARED_KEY, false):
		return ["Léviathan vaincu"]
	SaveData.save_progress(CLEARED_KEY, true)
	Wallet.add_gems(FIRST_GEMS)
	Wallet.give(SKIN_ID)
	return ["Léviathan vaincu : %d gemmes et le skin Abysse" % FIRST_GEMS]
