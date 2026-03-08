extends Node
## Needs System — Manages Sims-style needs bars for the player.
## Needs decay over time (each period) and are restored by actions/furniture.

signal need_changed(need_name: String, value: float)
signal need_critical(need_name: String)
signal need_zero(need_name: String)

const NEED_NAMES := ["energy", "fun", "social", "hunger"]

# Decay rates per period change
const DECAY_RATES := {
	"energy": 8.0,
	"fun": 6.0,
	"social": 4.0,
	"hunger": 7.0,
}

# Actions that restore needs
const ACTIVITIES := {
	"sleep": {"energy": 40, "time_cost": 1},
	"nap": {"energy": 15, "time_cost": 0},
	"eat_cheap": {"hunger": 15, "budget_cost": 1},
	"eat_medium": {"hunger": 30, "budget_cost": 3},
	"eat_fancy": {"hunger": 50, "energy": 5, "budget_cost": 6},
	"play": {"fun": 25, "time_cost": 1},
	"study": {"time_cost": 1},
	"hangout": {"social": 20, "fun": 10, "time_cost": 1},
	"call_friend": {"social": 15},
	"read": {"fun": 10, "energy": -5},
}


func _ready() -> void:
	TimeManager.period_changed.connect(_on_period_changed)


func _on_period_changed(_period: String) -> void:
	# Apply decay based on period
	for need in NEED_NAMES:
		var decay = DECAY_RATES.get(need, 5.0)
		GameState.modify_need(need, -decay)
		need_changed.emit(need, GameState.needs[need])

		if GameState.needs[need] <= 15.0:
			need_critical.emit(need)
		if GameState.needs[need] <= 0.0:
			need_zero.emit(need)


func do_activity(activity_name: String) -> bool:
	if not ACTIVITIES.has(activity_name):
		return false

	var activity = ACTIVITIES[activity_name]

	# Check budget
	var cost = activity.get("budget_cost", 0)
	if cost > 0 and not GameState.spend(cost):
		return false

	# Apply need changes
	for need in NEED_NAMES:
		var boost = activity.get(need, 0)
		if boost != 0:
			GameState.modify_need(need, float(boost))
			need_changed.emit(need, GameState.needs[need])

	# Advance time if needed
	var time_cost = activity.get("time_cost", 0)
	for i in range(time_cost):
		TimeManager.advance_period()

	return true


func get_need_color(need_name: String) -> Color:
	var val = GameState.needs.get(need_name, 50.0)
	if val > 70:
		return Color(0.165, 0.616, 0.561)  # Teal — good
	elif val > 35:
		return Color(0.788, 0.659, 0.298)  # Gold — warning
	else:
		return Color(0.878, 0.424, 0.353)  # Red — critical


func get_need_icon_name(need_name: String) -> String:
	match need_name:
		"energy": return "ZZZ"
		"fun": return "FUN"
		"social": return "SOC"
		"hunger": return "EAT"
		_: return "???"
