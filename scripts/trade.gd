class_name Trade
## Card trading with codes, without a server. Sending a card takes a copy out
## of the collection and gives a code (and a link to the website's card page,
## site/carte.html, which shows the card). Typed in the CODE field, the code
## gives the card. A code works once on a device, and never on the one that
## made it.
##
## A code is 8 bytes in base 32 (Crockford), "OC-XXXX-XXXX-XXXXX":
##   2 bytes: the card, the start of the SHA-256 of its id (stable when cards
##            are added to the catalog);
##   4 bytes: random, so that every code is different;
##   2 bytes: a check, the start of the SHA-256 of "overclock-trade:" and the
##            first 6 bytes in hex. It catches typos and casual tampering, not
##            a determined cheat: there is no server to ask.
## site/carte.html decodes them the same way.

const PREFIX := "OC"
const ALPHABET := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
const SALT := "overclock-trade:"
const PAGE := "https://overclock.randomlabs.dev/site/carte.html#"
const USED_KEY := "trade_codes_used"
const SENT_KEY := "trade_codes_sent"


## Takes a copy of `id` out of the collection and returns its code, or ""
## when the player has none.
static func send(id: String) -> String:
	var cards := Cards.owned()
	if int(cards.get(id, 0)) <= 0:
		return ""
	cards[id] = int(cards[id]) - 1
	SaveData.save_progress(Cards.SAVE_KEY, cards)
	var payload := card_key(id)
	var random := RandomNumberGenerator.new()
	random.randomize()
	for i in 4:
		payload.append(random.randi_range(0, 255))
	payload.append_array(_check(payload))
	var code := _format(_base32(payload))
	var sent: Array = SaveData.load_progress(SENT_KEY, [])
	sent.append(code)
	SaveData.save_progress(SENT_KEY, sent)
	return code


static func link(code: String) -> String:
	return PAGE + code


## Does `text` look like a trade code (rather than a promo code)?
static func is_code(text: String) -> bool:
	return _clean(text).begins_with(PREFIX) and _clean(text).length() == PREFIX.length() + 13


## Gives the card of `text`. Returns [true, the card's name] or [false, why not].
static func receive(text: String) -> Array:
	var code := _format(_clean(text).substr(PREFIX.length()))
	var bytes := _unbase32(_clean(text).substr(PREFIX.length()))
	if bytes.size() != 8 or bytes.slice(6, 8) != _check(bytes.slice(0, 6)):
		return [false, "Code d'échange invalide."]
	if code in SaveData.load_progress(SENT_KEY, []):
		return [false, "C'est ton propre code : donne-le à quelqu'un d'autre."]
	var used: Array = SaveData.load_progress(USED_KEY, [])
	if code in used:
		return [false, "Code déjà utilisé."]
	var card := card_of(bytes.slice(0, 2))
	if card.is_empty():
		return [false, "Carte inconnue (mets le jeu à jour)."]
	Cards.add(card.id)
	used.append(code)
	SaveData.save_progress(USED_KEY, used)
	return [true, "la carte %s" % card.name]


static func card_of(key: PackedByteArray) -> Dictionary:
	for card: Dictionary in Cards.all_cards():
		if card_key(card.id) == key:
			return card
	return {}


static func card_key(id: String) -> PackedByteArray:
	return id.sha256_buffer().slice(0, 2)


static func _check(payload: PackedByteArray) -> PackedByteArray:
	return (SALT + payload.hex_encode()).sha256_buffer().slice(0, 2)


## "OC" and the 13 characters, in groups: OC-XXXX-XXXX-XXXXX.
static func _format(body: String) -> String:
	return "%s-%s-%s-%s" % [PREFIX, body.substr(0, 4), body.substr(4, 4), body.substr(8)]


## Capitals, no spaces or dashes; in the code itself, letters that look like
## digits read as digits (O as 0, I and L as 1).
static func _clean(text: String) -> String:
	var clean := text.strip_edges().to_upper().replace(" ", "").replace("-", "")
	if not (clean.begins_with(PREFIX) or clean.begins_with("0C")):
		return clean
	return PREFIX + clean.substr(2).replace("O", "0").replace("I", "1").replace("L", "1")


static func _base32(bytes: PackedByteArray) -> String:
	var text := ""
	var buffer := 0
	var bits := 0
	for byte in bytes:
		buffer = (buffer << 8) | byte
		bits += 8
		while bits >= 5:
			bits -= 5
			text += ALPHABET[(buffer >> bits) & 31]
	if bits > 0:
		text += ALPHABET[(buffer << (5 - bits)) & 31]
	return text


static func _unbase32(text: String) -> PackedByteArray:
	var bytes := PackedByteArray()
	var buffer := 0
	var bits := 0
	for character in text:
		var value := ALPHABET.find(character)
		if value < 0:
			return PackedByteArray()
		buffer = ((buffer << 5) | value) & 0xFFFF
		bits += 5
		if bits >= 8:
			bits -= 8
			bytes.append((buffer >> bits) & 255)
	return bytes
