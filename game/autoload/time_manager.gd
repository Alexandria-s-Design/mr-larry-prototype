extends Node
## Time Manager — Controls day/night cycle and week progression.
## Time advances on player ACTIONS, not real-time (kid-friendly pacing).

signal period_changed(period: String)
signal day_changed(day: int)
signal week_changed(week: int)
signal time_updated()

const PERIODS := ["morning", "afternoon", "evening", "night"]
const DAY_NAMES := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]


func get_period_index() -> int:
	return PERIODS.find(GameState.current_period)


func get_day_name() -> String:
	if GameState.current_day >= 1 and GameState.current_day <= 5:
		return DAY_NAMES[GameState.current_day - 1]
	return "Weekend"


func get_time_string() -> String:
	return get_day_name() + " " + GameState.current_period.capitalize() + " — Week " + str(GameState.current_week)


## Call this when the player completes an action (chore, school, shopping, etc.)
func advance_period() -> void:
	var idx = get_period_index()
	idx += 1

	if idx >= PERIODS.size():
		# End of day
		idx = 0
		_advance_day()

	GameState.current_period = PERIODS[idx]
	period_changed.emit(GameState.current_period)
	time_updated.emit()

	# Apply need decay each period
	GameState.decay_needs(5.0)


func _advance_day() -> void:
	GameState.current_day += 1

	if GameState.current_day > 5:
		# End of week
		GameState.current_day = 1
		_advance_week()

	day_changed.emit(GameState.current_day)


func _advance_week() -> void:
	GameState.current_week += 1

	# Apply weekly income
	GameState.total_earned += GameState.weekly_income

	# Apply interest on savings (0.5% per week for visible growth)
	var interest = GameState.save_jar * 0.005
	if interest > 0:
		GameState.save_jar += interest
		GameState.savings += interest

	week_changed.emit(GameState.current_week)


## Get the ambient light color for the current period
func get_ambient_color() -> Color:
	match GameState.current_period:
		"morning": return Color(1.0, 0.95, 0.85)
		"afternoon": return Color(1.0, 1.0, 0.95)
		"evening": return Color(0.9, 0.75, 0.6)
		"night": return Color(0.3, 0.3, 0.5)
		_: return Color(1.0, 1.0, 1.0)


## Get the light energy for the current period
func get_light_energy() -> float:
	match GameState.current_period:
		"morning": return 0.8
		"afternoon": return 1.0
		"evening": return 0.5
		"night": return 0.2
		_: return 1.0
