extends Node
## Global game state singleton — persists across scenes.
## Manages family account, player progress, needs, savings, room, and simulation results.

# --- Family Account ---
var family_name: String = ""
var portal_mode: String = ""  # "parent" or "child"
var player_name: String = ""

# --- Character Appearance ---
var character_data: Dictionary = {
	"skin_color": Color(0.76, 0.58, 0.44),
	"hair_color": Color(0.15, 0.1, 0.07),
	"shirt_color": Color(0.2, 0.5, 0.8),
	"pants_color": Color(0.2, 0.2, 0.35),
}

# --- Needs (Sims-style, 0-100) ---
var needs: Dictionary = {
	"energy": 100.0,
	"fun": 80.0,
	"social": 70.0,
	"hunger": 90.0,
}

# --- Financial State ---
var savings: float = 0.0
var weekly_income: float = 10.0
var total_earned: float = 0.0
var total_spent: float = 0.0

# --- Piggy Banks (Save/Spend/Share) ---
var save_jar: float = 0.0
var spend_jar: float = 5.0  # Start with $5 spending money
var share_jar: float = 0.0

# --- Time ---
var current_week: int = 1
var current_day: int = 1  # 1-5 (Mon-Fri)
var current_period: String = "morning"  # morning, afternoon, evening, night

# --- Progress ---
var completed_events: Array[String] = []
var current_simulation: String = ""
var badges: Array[String] = []
var iceberg_level: int = 0  # 0-20

# --- Simulation/Event Results ---
var simulation_results: Dictionary = {}

# --- Grade Band ---
var grade_band: String = "3-5"

# --- Room ---
var room_items: Array[Dictionary] = []  # [{id, grid_x, grid_z, rotation}]
var owned_furniture: Array[String] = ["bed_basic", "desk_basic", "chair_basic"]

# --- Weekly Tasks (from parent portal) ---
var tasks: Array[Dictionary] = []
var completed_tasks: Array[Dictionary] = []


func _ready() -> void:
	print("Life Dreams Wealth — Game State Initialized")


func set_family(name: String, mode: String) -> void:
	family_name = name
	portal_mode = mode


# --- Needs ---
func modify_need(need_name: String, amount: float) -> void:
	if needs.has(need_name):
		needs[need_name] = clampf(needs[need_name] + amount, 0.0, 100.0)


func decay_needs(amount: float) -> void:
	for key in needs:
		needs[key] = clampf(needs[key] - amount, 0.0, 100.0)


func get_lowest_need() -> String:
	var lowest_key := "energy"
	var lowest_val := 999.0
	for key in needs:
		if needs[key] < lowest_val:
			lowest_val = needs[key]
			lowest_key = key
	return lowest_key


func is_any_need_critical() -> bool:
	for key in needs:
		if needs[key] <= 15.0:
			return true
	return false


# --- Economy ---
func add_savings(amount: float) -> void:
	savings += amount
	save_jar += amount


func spend(amount: float) -> bool:
	if spend_jar >= amount:
		spend_jar -= amount
		total_spent += amount
		return true
	return false


func earn(amount: float) -> void:
	total_earned += amount
	weekly_income = amount


func allocate_income(save_pct: float, spend_pct: float, share_pct: float) -> void:
	var total = weekly_income
	save_jar += total * save_pct
	spend_jar += total * spend_pct
	share_jar += total * share_pct
	savings += total * save_pct


func get_total_money() -> float:
	return save_jar + spend_jar + share_jar


# --- Furniture ---
func own_furniture(item_id: String) -> void:
	if item_id not in owned_furniture:
		owned_furniture.append(item_id)


func place_furniture(item_id: String, grid_x: int, grid_z: int, rotation: int = 0) -> void:
	room_items.append({"id": item_id, "grid_x": grid_x, "grid_z": grid_z, "rotation": rotation})


func remove_furniture_at(grid_x: int, grid_z: int) -> void:
	for i in range(room_items.size() - 1, -1, -1):
		if room_items[i].grid_x == grid_x and room_items[i].grid_z == grid_z:
			room_items.remove_at(i)


# --- Events / Progression ---
func complete_event(event_id: String, score: int, choices: Array, outcome: String) -> void:
	if event_id not in completed_events:
		completed_events.append(event_id)
		iceberg_level = mini(iceberg_level + 1, 20)
	simulation_results[event_id] = {
		"score": score,
		"choices": choices,
		"outcome": outcome,
		"completed_at": Time.get_datetime_string_from_system()
	}


func award_badge(badge_name: String) -> void:
	if badge_name not in badges:
		badges.append(badge_name)


func get_iceberg_percent() -> float:
	return float(iceberg_level) / 20.0 * 100.0


func get_progress_summary() -> Dictionary:
	return {
		"family": family_name,
		"mode": portal_mode,
		"grade": grade_band,
		"savings": savings,
		"earned": total_earned,
		"spent": total_spent,
		"events_completed": completed_events.size(),
		"badges": badges.size(),
		"iceberg": get_iceberg_percent()
	}


func reset() -> void:
	family_name = ""
	portal_mode = ""
	player_name = ""
	needs = {"energy": 100.0, "fun": 80.0, "social": 70.0, "hunger": 90.0}
	savings = 0.0
	weekly_income = 10.0
	total_earned = 0.0
	total_spent = 0.0
	save_jar = 0.0
	spend_jar = 5.0
	share_jar = 0.0
	current_week = 1
	current_day = 1
	current_period = "morning"
	completed_events.clear()
	current_simulation = ""
	badges.clear()
	iceberg_level = 0
	simulation_results.clear()
	room_items.clear()
	owned_furniture = ["bed_basic", "desk_basic", "chair_basic"]
	tasks.clear()
	completed_tasks.clear()
