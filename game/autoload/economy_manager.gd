extends Node
## Economy Manager — Handles purchases, income, and the furniture catalog.

signal purchase_made(item_id: String, cost: float)
signal insufficient_funds(item_id: String, cost: float)
signal income_received(amount: float)

# Furniture catalog: id -> {name, cost, category, needs_boost, description}
var furniture_catalog: Dictionary = {
	# --- Beds ---
	"bed_basic": {"name": "Basic Bed", "cost": 0, "category": "bed", "needs_boost": {"energy": 30}, "desc": "A simple bed. Gets the job done."},
	"bed_comfy": {"name": "Comfy Bed", "cost": 25, "category": "bed", "needs_boost": {"energy": 50}, "desc": "Memory foam! Restores more energy."},
	"bed_deluxe": {"name": "Deluxe Bed", "cost": 75, "category": "bed", "needs_boost": {"energy": 70}, "desc": "Sleep like royalty. Maximum energy recovery."},
	# --- Desks ---
	"desk_basic": {"name": "Basic Desk", "cost": 0, "category": "desk", "needs_boost": {}, "desc": "A place to study and do homework."},
	"desk_gamer": {"name": "Gaming Desk", "cost": 40, "category": "desk", "needs_boost": {"fun": 10}, "desc": "RGB lights! Study AND play."},
	# --- Chairs ---
	"chair_basic": {"name": "Basic Chair", "cost": 0, "category": "chair", "needs_boost": {}, "desc": "It's a chair. You sit in it."},
	"chair_bean": {"name": "Bean Bag", "cost": 15, "category": "chair", "needs_boost": {"fun": 5, "energy": 5}, "desc": "Comfy and fun. A kid classic."},
	"chair_gaming": {"name": "Gaming Chair", "cost": 50, "category": "chair", "needs_boost": {"fun": 15, "energy": 10}, "desc": "Pro gamer vibes. Very comfy."},
	# --- Fun Items ---
	"bookshelf": {"name": "Bookshelf", "cost": 20, "category": "fun", "needs_boost": {"fun": 15}, "desc": "Books = knowledge = fun!"},
	"tv_small": {"name": "Small TV", "cost": 30, "category": "fun", "needs_boost": {"fun": 25}, "desc": "Watch shows after homework."},
	"tv_big": {"name": "Big Screen TV", "cost": 80, "category": "fun", "needs_boost": {"fun": 40}, "desc": "Movie theater in your room!"},
	"game_console": {"name": "Game Console", "cost": 60, "category": "fun", "needs_boost": {"fun": 35, "social": 10}, "desc": "Play with friends online!"},
	"music_player": {"name": "Music Player", "cost": 15, "category": "fun", "needs_boost": {"fun": 10}, "desc": "Tunes make everything better."},
	# --- Social ---
	"phone": {"name": "Phone", "cost": 25, "category": "social", "needs_boost": {"social": 20}, "desc": "Text friends, stay connected."},
	"extra_chair": {"name": "Guest Chair", "cost": 10, "category": "social", "needs_boost": {"social": 10}, "desc": "For when friends visit!"},
	# --- Decorations ---
	"poster_cool": {"name": "Cool Poster", "cost": 5, "category": "decor", "needs_boost": {"fun": 3}, "desc": "Express yourself!"},
	"plant": {"name": "Potted Plant", "cost": 8, "category": "decor", "needs_boost": {"energy": 3}, "desc": "Green vibes. Calming."},
	"lamp_desk": {"name": "Desk Lamp", "cost": 10, "category": "decor", "needs_boost": {}, "desc": "Light up your workspace."},
	"rug_nice": {"name": "Nice Rug", "cost": 12, "category": "decor", "needs_boost": {"fun": 2, "energy": 2}, "desc": "Ties the room together."},
	# --- Food (consumable) ---
	"snack_cheap": {"name": "Instant Noodles", "cost": 1, "category": "food", "needs_boost": {"hunger": 15}, "desc": "Quick and cheap. Not the healthiest."},
	"snack_medium": {"name": "Sandwich", "cost": 3, "category": "food", "needs_boost": {"hunger": 30}, "desc": "Solid meal. Good nutrition."},
	"snack_fancy": {"name": "Home Cooked Meal", "cost": 6, "category": "food", "needs_boost": {"hunger": 50, "energy": 5}, "desc": "Best nutrition. Mom would be proud."},
}


func get_item(item_id: String) -> Dictionary:
	if furniture_catalog.has(item_id):
		return furniture_catalog[item_id]
	return {}


func can_afford(item_id: String) -> bool:
	var item = get_item(item_id)
	return GameState.spend_jar >= item.get("cost", 999)


func purchase(item_id: String) -> bool:
	var item = get_item(item_id)
	if item.is_empty():
		return false

	var cost = item.get("cost", 0)
	if GameState.spend(cost):
		# Food is consumable — apply needs boost immediately
		if item.get("category", "") == "food":
			var boosts = item.get("needs_boost", {})
			for need in boosts:
				GameState.modify_need(need, boosts[need])
		else:
			GameState.own_furniture(item_id)
		purchase_made.emit(item_id, cost)
		return true
	else:
		insufficient_funds.emit(item_id, cost)
		return false


func get_catalog_by_category(category: String) -> Dictionary:
	var result: Dictionary = {}
	for id in furniture_catalog:
		if furniture_catalog[id].get("category", "") == category:
			result[id] = furniture_catalog[id]
	return result


func get_shop_categories() -> Array[String]:
	return ["bed", "desk", "chair", "fun", "social", "decor", "food"]


func use_furniture(item_id: String) -> void:
	## Apply needs boost from interacting with placed furniture
	var item = get_item(item_id)
	var boosts = item.get("needs_boost", {})
	for need in boosts:
		GameState.modify_need(need, boosts[need])
