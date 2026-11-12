class_name Billing
extends Node
## Buying gems with real money through Google Play, using the Godot Google
## Play Billing plugin (godot-sdk-integrations/godot-google-play-billing, 3.x)
## when it is installed in addons/. Without it (web, desktop, or before the
## Play Console is set up) `available` stays false and the shop says so.
## The plugin is loaded by path, not by class name, so that the game still
## runs without it. Setup steps: README, section "Paiements".

## The gem packs' prices as Google Play formats them, or a reason they
## cannot be bought.
signal status_changed
## `gems` were added to the wallet.
signal gems_granted(gems: int)

const CLIENT_SCRIPT := "res://addons/GodotGooglePlayBilling/BillingClient.gd"
## The plugin's enum values (Google Play Billing Library), used when the
## script does not expose them.
const RESPONSE_OK := 0
const PURCHASED := 1

var available := false
## Product id -> price text, once Google Play answered.
var prices := {}
var status := "Achat de gemmes : bientôt sur Android"

var _client: Object
var _product_type := 0  # INAPP
## Purchase token -> product ids, between payment and consumption.
var _pending := {}


func _ready() -> void:
	if OS.get_name() != "Android" or not ResourceLoader.exists(CLIENT_SCRIPT):
		return
	var script: Script = load(CLIENT_SCRIPT)
	_client = script.new()
	if _client is Node:
		add_child(_client)
	var types: Variant = script.get_script_constant_map().get("ProductType", {})
	if types is Dictionary:
		_product_type = (types as Dictionary).get("INAPP", 0)
	_client.connect("connected", _on_connected)
	_client.connect("connect_error", _on_connect_error)
	_client.connect("query_product_details_response", _on_product_details)
	_client.connect("query_purchases_response", _on_purchases)
	_client.connect("on_purchase_updated", _on_purchases)
	_client.connect("consume_purchase_response", _on_consumed)
	status = "Connexion à Google Play…"
	_client.call("start_connection")


## Opens Google Play's payment sheet for a pack of Shop.GEM_PACKS.
func buy(product: String) -> void:
	if available:
		_client.call("purchase", product)


func _on_connected() -> void:
	var ids := PackedStringArray()
	for pack in Shop.GEM_PACKS:
		ids.append(pack.product)
	_client.call("query_product_details", ids, _product_type)
	# Purchases paid but not yet credited (the game closed in between).
	_client.call("query_purchases", _product_type)


func _on_connect_error(_code: int, message: String) -> void:
	status = "Google Play indisponible (%s)" % message
	status_changed.emit()


func _on_product_details(response: Dictionary) -> void:
	if response.get("response_code", -1) != RESPONSE_OK:
		status = "Produits introuvables sur Google Play"
		status_changed.emit()
		return
	for details: Dictionary in response.get("product_details", []):
		prices[details.get("product_id", "")] = _find_price(details)
	available = not prices.is_empty()
	status = "" if available else "Produits introuvables sur Google Play"
	status_changed.emit()


## A finished purchase is consumed first (so it can be bought again), then
## the gems are given: never twice for the same payment.
func _on_purchases(response: Dictionary) -> void:
	if response.get("response_code", -1) != RESPONSE_OK:
		return
	for purchase: Dictionary in response.get("purchases", []):
		if purchase.get("purchase_state", 0) == PURCHASED:
			_client.call("consume_purchase", purchase.purchase_token)
			_pending[purchase.purchase_token] = purchase.get("product_ids", PackedStringArray())


func _on_consumed(response: Dictionary) -> void:
	var token: String = response.get("token", "")
	if response.get("response_code", -1) != RESPONSE_OK or not _pending.has(token):
		return
	var gems := 0
	for product: String in _pending[token]:
		for pack in Shop.GEM_PACKS:
			if pack.product == product:
				gems += pack.gems
	_pending.erase(token)
	if gems > 0:
		Wallet.add_gems(gems)
		gems_granted.emit(gems)


## The formatted price in a product's details, wherever the plugin puts it.
func _find_price(details: Dictionary) -> String:
	for key: String in details:
		var value: Variant = details[key]
		if key == "formatted_price":
			return str(value)
		if value is Dictionary:
			var found := _find_price(value)
			if found != "":
				return found
	return ""
