extends Control
## Parent Portal — Task manager, allowance allocator, and family financial dashboard.
## Parents set tasks, review child progress, and manage the family economy.

@onready var family_label: Label = %FamilyLabel
@onready var task_list: VBoxContainer = %TaskList
@onready var add_task_btn: Button = %AddTaskButton
@onready var task_name_input: LineEdit = %TaskNameInput
@onready var task_value_input: SpinBox = %TaskValueInput
@onready var allocator_panel: Panel = %AllocatorPanel
@onready var save_slider: HSlider = %SaveSlider
@onready var spend_slider: HSlider = %SpendSlider
@onready var share_slider: HSlider = %ShareSlider
@onready var save_pct_label: Label = %SavePctLabel
@onready var spend_pct_label: Label = %SpendPctLabel
@onready var share_pct_label: Label = %SharePctLabel
@onready var income_input: SpinBox = %IncomeInput
@onready var pay_btn: Button = %PayButton
@onready var progress_panel: Panel = %ProgressPanel
@onready var progress_text: RichTextLabel = %ProgressText
@onready var back_btn: Button = %BackButton


func _ready() -> void:
	family_label.text = GameState.family_name + " Family Dashboard"
	add_task_btn.pressed.connect(_on_add_task)
	pay_btn.pressed.connect(_on_pay)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

	save_slider.value_changed.connect(_on_slider_changed)
	spend_slider.value_changed.connect(_on_slider_changed)
	share_slider.value_changed.connect(_on_slider_changed)

	# Defaults: 40/40/20
	save_slider.value = 40
	spend_slider.value = 40
	share_slider.value = 20

	_refresh_tasks()
	_refresh_progress()


func _on_add_task() -> void:
	var task_name = task_name_input.text.strip_edges()
	if task_name.is_empty():
		return
	var task = {
		"name": task_name,
		"value": task_value_input.value,
		"completed": false
	}
	GameState.tasks.append(task)
	task_name_input.text = ""
	_refresh_tasks()


func _refresh_tasks() -> void:
	for child in task_list.get_children():
		child.queue_free()

	for i in range(GameState.tasks.size()):
		var task = GameState.tasks[i]
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 40)

		var check := CheckButton.new()
		check.button_pressed = task.get("completed", false)
		check.toggled.connect(_on_task_toggled.bind(i))
		row.add_child(check)

		var label := Label.new()
		label.text = task.name + " — $%.2f" % task.value
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var del_btn := Button.new()
		del_btn.text = "X"
		del_btn.pressed.connect(_on_delete_task.bind(i))
		row.add_child(del_btn)

		task_list.add_child(row)


func _on_task_toggled(toggled: bool, index: int) -> void:
	GameState.tasks[index]["completed"] = toggled


func _on_delete_task(index: int) -> void:
	GameState.tasks.remove_at(index)
	_refresh_tasks()


func _on_slider_changed(_value: float) -> void:
	var total = save_slider.value + spend_slider.value + share_slider.value
	if total > 0:
		save_pct_label.text = "Save: %.0f%%" % (save_slider.value / total * 100)
		spend_pct_label.text = "Spend: %.0f%%" % (spend_slider.value / total * 100)
		share_pct_label.text = "Share: %.0f%%" % (share_slider.value / total * 100)


func _on_pay() -> void:
	var income = income_input.value
	if income <= 0:
		return

	GameState.earn(income)

	var total = save_slider.value + spend_slider.value + share_slider.value
	if total > 0:
		GameState.allocate_income(
			save_slider.value / total,
			spend_slider.value / total,
			share_slider.value / total
		)

	_refresh_progress()


func _refresh_progress() -> void:
	var summary = GameState.get_progress_summary()
	var text = "[b]Family Progress[/b]\n\n"
	text += "Savings: $%.2f\n" % summary.savings
	text += "Earned: $%.2f\n" % summary.earned
	text += "Spent: $%.2f\n" % summary.spent
	text += "Simulations: %d/13\n" % summary.simulations_completed
	text += "Badges: %d\n" % summary.badges
	text += "Iceberg: %.0f%%\n" % summary.iceberg
	progress_text.text = text
