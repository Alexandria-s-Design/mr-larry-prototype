extends Node
## Global game state singleton — persists across scenes.
## Manages family account, player progress, savings, and simulation results.

# --- Family Account ---
var family_name: String = ""
var portal_mode: String = ""  # "parent" or "child"
var player_name: String = ""

# --- Financial State ---
var savings: float = 0.0
var weekly_income: float = 0.0
var total_earned: float = 0.0
var total_spent: float = 0.0

# --- Progress ---
var completed_simulations: Array[String] = []
var current_simulation: String = ""
var badges: Array[String] = []
var iceberg_level: int = 0  # 0-20, each sim completion raises it

# --- Simulation Results ---
var simulation_results: Dictionary = {}  # sim_id -> {score, choices, outcome}

# --- Grade Band ---
var grade_band: String = "3-5"  # "K-2", "3-5", "6-8", "9-12"

# --- Piggy Banks (Save/Spend/Share) ---
var save_jar: float = 0.0
var spend_jar: float = 0.0
var share_jar: float = 0.0

# --- Weekly Tasks (from parent portal) ---
var tasks: Array[Dictionary] = []
var completed_tasks: Array[Dictionary] = []


func _ready() -> void:
	print("Life Dreams Wealth — Game State Initialized")


func set_family(name: String, mode: String) -> void:
	family_name = name
	portal_mode = mode


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


func complete_simulation(sim_id: String, score: int, choices: Array, outcome: String) -> void:
	if sim_id not in completed_simulations:
		completed_simulations.append(sim_id)
		iceberg_level = mini(iceberg_level + 1, 20)
	simulation_results[sim_id] = {
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
		"simulations_completed": completed_simulations.size(),
		"badges": badges.size(),
		"iceberg": get_iceberg_percent()
	}


func reset() -> void:
	family_name = ""
	portal_mode = ""
	player_name = ""
	savings = 0.0
	weekly_income = 0.0
	total_earned = 0.0
	total_spent = 0.0
	completed_simulations.clear()
	current_simulation = ""
	badges.clear()
	iceberg_level = 0
	simulation_results.clear()
	save_jar = 0.0
	spend_jar = 0.0
	share_jar = 0.0
	tasks.clear()
	completed_tasks.clear()
