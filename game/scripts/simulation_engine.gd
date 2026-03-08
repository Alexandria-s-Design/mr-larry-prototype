extends Control
## Branching Simulation Engine — powers all phenomenon-based lessons.
## Loads simulation data (phenomenon, branches, outcomes) and presents
## an interactive branching narrative with consequences.

signal simulation_completed(sim_id: String, score: int, choices: Array, outcome: String)

@onready var title_label: Label = %SimTitle
@onready var phenomenon_text: RichTextLabel = %PhenomenonText
@onready var question_label: Label = %QuestionLabel
@onready var choice_container: VBoxContainer = %ChoiceContainer
@onready var consequence_panel: Panel = %ConsequencePanel
@onready var consequence_text: RichTextLabel = %ConsequenceText
@onready var next_btn: Button = %NextButton
@onready var budget_bar: ProgressBar = %BudgetBar
@onready var health_bar: ProgressBar = %HealthBar
@onready var score_label: Label = %ScoreLabel
@onready var phase_label: Label = %PhaseLabel
@onready var mr_larry_panel: Panel = %MrLarryPanel
@onready var mr_larry_text: RichTextLabel = %MrLarryText

var sim_data: Dictionary = {}
var current_branch: int = 0
var player_choices: Array = []
var player_score: int = 0
var budget_remaining: float = 100.0
var health_score: float = 100.0


func _ready() -> void:
	next_btn.pressed.connect(_on_next)
	consequence_panel.visible = false
	mr_larry_panel.visible = false
	_load_simulation(GameState.current_simulation)


func _load_simulation(sim_id: String) -> void:
	# Load simulation data from resource file
	var data_path = "res://resources/simulations/sim_" + sim_id + ".tres"
	if ResourceLoader.exists(data_path):
		sim_data = ResourceLoader.load(data_path).data
	else:
		# Use template data for demo
		sim_data = _get_demo_data(sim_id)

	_show_intro()


func _show_intro() -> void:
	title_label.text = sim_data.get("title", "Simulation")
	phenomenon_text.text = sim_data.get("phenomenon", "")
	question_label.text = sim_data.get("driving_question", "")
	phase_label.text = sim_data.get("phase", "LIFE")

	# Set phase color
	match sim_data.get("phase", "LIFE"):
		"LIFE": phase_label.add_theme_color_override("font_color", Color(0.165, 0.616, 0.561))
		"DREAMS": phase_label.add_theme_color_override("font_color", Color(0.788, 0.659, 0.298))
		"WEALTH": phase_label.add_theme_color_override("font_color", Color(0.42, 0.357, 0.584))

	# Show Mr. Larry intro
	_show_mr_larry(sim_data.get("mr_larry_intro",
		"Welcome! Let's explore this together. Remember — there are no wrong answers, only different paths. Let's see what happens!"))

	budget_remaining = sim_data.get("starting_budget", 100.0)
	health_score = 100.0
	_update_meters()

	# Build first set of choices
	await get_tree().create_timer(2.0).timeout
	_show_branch(0)


func _show_branch(index: int) -> void:
	current_branch = index
	var branches = sim_data.get("branches", [])

	if index >= branches.size():
		_show_results()
		return

	var branch = branches[index]
	question_label.text = branch.get("decision", "What do you choose?")
	consequence_panel.visible = false

	# Clear old choices
	for child in choice_container.get_children():
		child.queue_free()

	# Create choice buttons
	var options = branch.get("options", [])
	for i in range(options.size()):
		var option = options[i]
		var btn := Button.new()
		btn.text = option.get("label", "Option " + str(i + 1))
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(_on_choice_made.bind(index, i))

		# Style based on phase
		choice_container.add_child(btn)


func _on_choice_made(branch_index: int, choice_index: int) -> void:
	var branch = sim_data["branches"][branch_index]
	var option = branch["options"][choice_index]

	player_choices.append({
		"branch": branch_index,
		"choice": choice_index,
		"label": option.get("label", ""),
	})

	# Apply consequences
	var score_delta = option.get("score", 0)
	var budget_delta = option.get("budget_cost", 0.0)
	var health_delta = option.get("health_impact", 0.0)

	player_score += score_delta
	budget_remaining -= budget_delta
	health_score = clampf(health_score + health_delta, 0, 100)

	_update_meters()

	# Show consequence
	consequence_text.text = option.get("consequence", "Your choice has been recorded.")
	consequence_panel.visible = true

	# Disable choice buttons
	for child in choice_container.get_children():
		if child is Button:
			child.disabled = true

	# Mr. Larry commentary
	var commentary = option.get("mr_larry_says", "")
	if commentary != "":
		_show_mr_larry(commentary)


func _on_next() -> void:
	consequence_panel.visible = false
	mr_larry_panel.visible = false
	_show_branch(current_branch + 1)


func _show_results() -> void:
	# Clear choices
	for child in choice_container.get_children():
		child.queue_free()

	# Determine outcome
	var outcome := "good"
	if player_score < 30:
		outcome = "needs_work"
	elif player_score < 60:
		outcome = "developing"
	elif player_score < 80:
		outcome = "good"
	else:
		outcome = "excellent"

	question_label.text = "Simulation Complete!"

	var result_text = ""
	result_text += "[b]Your Results:[/b]\n\n"
	result_text += "Score: %d points\n" % player_score
	result_text += "Budget Remaining: $%.2f\n" % budget_remaining
	result_text += "Health Score: %.0f%%\n\n" % health_score
	result_text += "Choices Made: %d\n" % player_choices.size()
	result_text += "\n[b]Outcome: %s[/b]" % outcome.to_upper()

	phenomenon_text.text = result_text

	# Mr. Larry closing remarks
	match outcome:
		"excellent":
			_show_mr_larry("Outstanding work! You made thoughtful choices that balanced all the important factors. That's real financial wisdom!")
		"good":
			_show_mr_larry("Great job! You showed solid financial thinking. Every smart choice adds up over time.")
		"developing":
			_show_mr_larry("Good effort! You're learning. Try replaying to see what happens with different choices.")
		"needs_work":
			_show_mr_larry("No worries — that's why we practice here! Every path teaches something. Try again and see what changes.")

	# Record in game state
	GameState.complete_simulation(
		GameState.current_simulation,
		player_score,
		player_choices,
		outcome
	)

	# Award badge
	var badge_name = sim_data.get("badge", "Simulation Complete")
	GameState.award_badge(badge_name)

	# Show return button
	next_btn.text = "RETURN TO HALLWAY"
	next_btn.pressed.disconnect(_on_next)
	next_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/hallway_3d.tscn"))


func _show_mr_larry(text: String) -> void:
	mr_larry_text.text = "[b]Mr. Larry says:[/b]\n" + text
	mr_larry_panel.visible = true


func _update_meters() -> void:
	budget_bar.value = budget_remaining
	health_bar.value = health_score
	score_label.text = "Score: %d" % player_score


func _get_demo_data(sim_id: String) -> Dictionary:
	# Demo data for the flagship HealthMart Foods simulation
	return {
		"title": "HealthMart Foods: The Grocery Challenge",
		"phase": "LIFE",
		"phenomenon": "Mom sends you to the grocery store with a list and $40. You need green beans, chicken, salad, bread, a drink, fruit, milk, and toilet paper. Every item has 3 versions at different prices — and the cheapest isn't always the best deal.",
		"driving_question": "How do you make smart choices when every option has a different price, quality, and trade-off?",
		"starting_budget": 40.0,
		"badge": "Smart Shopper",
		"mr_larry_intro": "Hey there! Welcome to HealthMart Foods. Today you're shopping for the family with $40. Every choice matters — price, health, and time. Let's see how you do!",
		"branches": [
			{
				"decision": "GREEN BEANS — Which do you pick?",
				"options": [
					{"label": "Fresh Green Beans — $2.50 (15 min prep, A+ health)", "score": 25, "budget_cost": 2.5, "health_impact": 10,
					 "consequence": "Fresh and nutritious! Takes more time to prepare, but your family gets the best nutrition.",
					 "mr_larry_says": "Fresh is always a great choice when you have the time! Notice the prep time though — 15 minutes adds up when you're cooking a whole meal."},
					{"label": "Frozen Green Beans — $1.75 (5 min prep, A health)", "score": 20, "budget_cost": 1.75, "health_impact": 5,
					 "consequence": "Great balance! Almost as healthy as fresh, much faster to prepare, and saves money.",
					 "mr_larry_says": "Smart thinking! Frozen vegetables are actually picked and frozen at peak freshness. Great nutrition for less money."},
					{"label": "Canned Green Beans — $1.00 (3 min prep, B health)", "score": 10, "budget_cost": 1.0, "health_impact": -5,
					 "consequence": "Cheapest option, but higher sodium and lower nutrition than fresh or frozen.",
					 "mr_larry_says": "You saved money, but check that sodium content! Canned can work in a pinch, but fresh or frozen is better for the family long-term."},
				]
			},
			{
				"decision": "CHICKEN — What's for dinner?",
				"options": [
					{"label": "Whole Chicken — $5.00 (1 hour prep, A+ health)", "score": 25, "budget_cost": 5.0, "health_impact": 10,
					 "consequence": "Best value per pound! But requires time and cooking skill. Leftovers for days.",
					 "mr_larry_says": "Now THAT's thinking ahead! A whole chicken gives you dinner tonight, chicken salad tomorrow, and bone broth after that. Three meals from one purchase!"},
					{"label": "Chicken Breast — $7.00 (1 hour prep, A+ health)", "score": 15, "budget_cost": 7.0, "health_impact": 5,
					 "consequence": "Lean and healthy, but more expensive per pound than the whole chicken.",
					 "mr_larry_says": "Healthy choice! But compare the price per pound — you're paying more for convenience. The whole chicken is usually a better deal."},
					{"label": "Rotisserie Chicken — $9.00 (0 min prep, A health)", "score": 10, "budget_cost": 9.0, "health_impact": 0,
					 "consequence": "Ready to eat! But it costs almost double the whole chicken. That's the convenience premium.",
					 "mr_larry_says": "Zero prep time is tempting! But you just paid $4 extra for someone else to cook it. That $4 could buy fruit for the whole family."},
				]
			},
			{
				"decision": "BREAD — Staff of life!",
				"options": [
					{"label": "Wheat Bread — $3.50 (A health)", "score": 20, "budget_cost": 3.5, "health_impact": 5,
					 "consequence": "Whole grain, high fiber, best nutrition. Costs a bit more but fuels the body better.",
					 "mr_larry_says": "Read those labels! Whole wheat means whole grain — more fiber, more nutrients, more energy that lasts."},
					{"label": "White Bread — $2.50 (B health)", "score": 10, "budget_cost": 2.5, "health_impact": -5,
					 "consequence": "Cheaper but less nutritious. Processed flour means less fiber and faster sugar spikes.",
					 "mr_larry_says": "It's cheaper, but think about what you're trading. Less nutrition means less sustained energy for the kids."},
					{"label": "Dinner Rolls — $2.00 (B- health)", "score": 5, "budget_cost": 2.0, "health_impact": -10,
					 "consequence": "Cheapest, but least nutritious. More processed, less fiber, won't keep you full.",
					 "mr_larry_says": "Rolls are fine for a treat, but for everyday family bread, the wheat gives you so much more nutrition per dollar."},
				]
			},
			{
				"decision": "SURPRISE! Soda is on a Buy One Get One Free sale! $4 for two 12-packs!",
				"options": [
					{"label": "Buy the BOGO deal! — $4.00", "score": -10, "budget_cost": 4.0, "health_impact": -15,
					 "consequence": "You weren't planning on soda... but it's such a good deal! Your budget just took a $4 hit for something not on your list.",
					 "mr_larry_says": "Ahh, the impulse buy! The store WANTS you to feel like you're saving money. But you just spent $4 on something you didn't need. That's not saving — that's spending on a deal."},
					{"label": "Skip it — buy water instead ($1.00)", "score": 25, "budget_cost": 1.0, "health_impact": 10,
					 "consequence": "You stuck to your list! Water is healthier and saved you $3. That's discipline.",
					 "mr_larry_says": "YES! That's financial discipline right there. The best sale in the world is still a bad deal if you don't need it. You just saved $3 AND your health."},
					{"label": "Buy juice instead — $2.50", "score": 10, "budget_cost": 2.5, "health_impact": 0,
					 "consequence": "A reasonable middle ground. Not on your list, but at least it has some nutritional value.",
					 "mr_larry_says": "Juice is okay — but check the sugar content! 100% juice is different from 'juice drink.' And remember, it wasn't on your list..."},
				]
			},
			{
				"decision": "MILK — Last aisle! How are you doing on budget?",
				"options": [
					{"label": "Non-Fat Milk — $3.50 (A+ health)", "score": 20, "budget_cost": 3.5, "health_impact": 10,
					 "consequence": "Lowest fat, highest nutrition per calorie. The healthy choice.",
					 "mr_larry_says": "Strong finish! Non-fat gives you all the calcium and protein without the extra fat. Your family's bones will thank you!"},
					{"label": "Low-Fat Milk — $3.25 (A health)", "score": 15, "budget_cost": 3.25, "health_impact": 5,
					 "consequence": "Good balance of taste and nutrition. A solid middle choice.",
					 "mr_larry_says": "Good choice! Low-fat is a great everyday option. A little fat actually helps absorb vitamins."},
					{"label": "Whole Milk — $3.00 (B+ health)", "score": 10, "budget_cost": 3.0, "health_impact": -5,
					 "consequence": "Cheapest milk option and tastes the richest, but highest in fat.",
					 "mr_larry_says": "Whole milk tastes great but has more saturated fat. For growing kids it can be fine, but for the whole family, lower fat is usually better."},
				]
			},
		]
	}
