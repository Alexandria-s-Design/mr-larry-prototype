extends Control
## Main Menu — Family login screen with Parent/Kids portal selection.
## Matches Mr. Larry's sketch: Family Name input with Parent and Kids buttons.

@onready var family_input: LineEdit = %FamilyNameInput
@onready var parent_btn: Button = %ParentButton
@onready var kids_btn: Button = %KidsButton
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var error_label: Label = %ErrorLabel
@onready var grade_selector: OptionButton = %GradeSelector


func _ready() -> void:
	parent_btn.pressed.connect(_on_parent_pressed)
	kids_btn.pressed.connect(_on_kids_pressed)
	error_label.visible = false

	# Set up grade band selector
	grade_selector.add_item("K-2 (Ages 5-8)")
	grade_selector.add_item("3-5 (Ages 8-11)")
	grade_selector.add_item("6-8 (Ages 11-14)")
	grade_selector.add_item("9-12 (Ages 14-18)")
	grade_selector.selected = 1  # Default to 3-5


func _validate_family_name() -> bool:
	if family_input.text.strip_edges().is_empty():
		error_label.text = "Please enter your Family Name"
		error_label.visible = true
		return false
	error_label.visible = false
	return true


func _get_grade_band() -> String:
	match grade_selector.selected:
		0: return "K-2"
		1: return "3-5"
		2: return "6-8"
		3: return "9-12"
		_: return "3-5"


func _on_parent_pressed() -> void:
	if not _validate_family_name():
		return
	GameState.set_family(family_input.text.strip_edges(), "parent")
	GameState.grade_band = _get_grade_band()
	get_tree().change_scene_to_file("res://scenes/parent_portal.tscn")


func _on_kids_pressed() -> void:
	if not _validate_family_name():
		return
	GameState.set_family(family_input.text.strip_edges(), "child")
	GameState.grade_band = _get_grade_band()
	get_tree().change_scene_to_file("res://scenes/hallway_3d.tscn")
