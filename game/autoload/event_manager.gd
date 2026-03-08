extends Node
## Event Manager — Triggers life events based on week, period, and conditions.
## Events are financial decisions that happen naturally during gameplay.

signal event_triggered(event_data: Dictionary)
signal event_completed(event_id: String, choice_index: int)

var event_queue: Array[Dictionary] = []
var triggered_this_period: bool = false


func _ready() -> void:
	TimeManager.period_changed.connect(_on_period_changed)


func _on_period_changed(period: String) -> void:
	triggered_this_period = false
	# Check for events each period change
	_check_triggers()


func _check_triggers() -> void:
	if triggered_this_period:
		return

	# Check curriculum events first (story progression)
	var curriculum = CurriculumData.get_available_event(
		GameState.current_week,
		GameState.current_period,
		GameState.completed_events
	)
	if not curriculum.is_empty():
		trigger_event(curriculum)
		return

	# Random events (30% chance each afternoon/evening)
	if GameState.current_period in ["afternoon", "evening"]:
		if randf() < 0.3:
			var random_event = RandomEventsData.get_random_event(GameState.completed_events)
			if not random_event.is_empty():
				trigger_event(random_event)


func trigger_event(event_data: Dictionary) -> void:
	triggered_this_period = true
	event_queue.append(event_data)
	event_triggered.emit(event_data)


func resolve_event(event_id: String, choice_index: int, option: Dictionary) -> void:
	# Apply consequences
	var budget_cost = option.get("budget_cost", 0.0)
	if budget_cost > 0:
		GameState.spend(budget_cost)
	elif budget_cost < 0:
		# Negative cost = earning money
		GameState.spend_jar += absf(budget_cost)
		GameState.total_earned += absf(budget_cost)

	# Apply needs changes
	for need_key in ["energy", "fun", "social", "hunger"]:
		var impact = option.get(need_key + "_impact", 0.0)
		if impact != 0:
			GameState.modify_need(need_key, impact)

	# Apply score / iceberg
	var score = option.get("score", 0)
	if score > 0:
		GameState.iceberg_level = mini(GameState.iceberg_level + 1, 20)

	# Mark completed
	if event_id not in GameState.completed_events:
		GameState.completed_events.append(event_id)

	# Award badge if specified
	var badge = option.get("badge", "")
	if badge != "":
		GameState.award_badge(badge)

	event_completed.emit(event_id, choice_index)
