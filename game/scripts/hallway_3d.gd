extends Node3D
## 3D Financial Hallway — Mr. Larry's vision of walking through subjects on walls.
## Players navigate a corridor with numbered subject boards. Completed subjects glow gold.

const HALLWAY_LENGTH := 50.0
const HALLWAY_WIDTH := 6.0
const HALLWAY_HEIGHT := 4.0
const SUBJECT_COUNT := 13
const MOVE_SPEED := 5.0
const MOUSE_SENSITIVITY := 0.002

var camera_rotation := Vector2.ZERO
var is_mouse_captured := true

# Simulation data for each subject board
var subjects := [
	{"id": "01", "title": "Mindset Reset", "phase": "LIFE", "desc": "Define Life, Dreams & Wealth"},
	{"id": "02", "title": "Financial Reality", "phase": "LIFE", "desc": "Where are you now?"},
	{"id": "03", "title": "Grocery Challenge", "phase": "LIFE", "desc": "Needs vs. Wants at HealthMart"},
	{"id": "04", "title": "The Paycheck", "phase": "LIFE", "desc": "Understanding Income"},
	{"id": "05", "title": "Short-Term Goals", "phase": "DREAMS", "desc": "The 4-Week Sprint"},
	{"id": "06", "title": "Bigger Goals", "phase": "DREAMS", "desc": "Compound Interest & Patience"},
	{"id": "07", "title": "Long-Term Dreams", "phase": "DREAMS", "desc": "The 26-Week Vision"},
	{"id": "08", "title": "Breaking Barriers", "phase": "DREAMS", "desc": "Financial Equity & Access"},
	{"id": "09", "title": "Entrepreneur", "phase": "DREAMS", "desc": "The Business Mindset"},
	{"id": "10", "title": "Savings Strategy", "phase": "WEALTH", "desc": "Pay Yourself First"},
	{"id": "11", "title": "Investing 101", "phase": "WEALTH", "desc": "Making Money Work"},
	{"id": "12", "title": "Action Plan", "phase": "WEALTH", "desc": "Your Family Financial Plan"},
	{"id": "13", "title": "Graduation", "phase": "WEALTH", "desc": "Wealth Review & Next Steps"},
]

@onready var camera: Camera3D = $PlayerCamera
@onready var hud: Control = $HUD
@onready var iceberg_bar: ProgressBar = $HUD/IcebergBar
@onready var info_panel: Panel = $HUD/InfoPanel
@onready var info_title: Label = $HUD/InfoPanel/VBox/InfoTitle
@onready var info_desc: Label = $HUD/InfoPanel/VBox/InfoDesc
@onready var info_phase: Label = $HUD/InfoPanel/VBox/InfoPhase
@onready var enter_btn: Button = $HUD/InfoPanel/VBox/EnterButton
@onready var savings_label: Label = $HUD/SavingsLabel
@onready var progress_label: Label = $HUD/ProgressLabel

var nearby_subject: int = -1


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_hallway()
	_update_hud()
	info_panel.visible = false
	enter_btn.pressed.connect(_on_enter_simulation)


func _build_hallway() -> void:
	# Floor
	var floor_mesh := MeshInstance3D.new()
	var floor_box := BoxMesh.new()
	floor_box.size = Vector3(HALLWAY_WIDTH, 0.1, HALLWAY_LENGTH)
	floor_mesh.mesh = floor_box
	floor_mesh.position = Vector3(0, -0.05, -HALLWAY_LENGTH / 2.0)
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.15, 0.12, 0.1)
	floor_mesh.material_override = floor_mat
	add_child(floor_mesh)

	# Ceiling
	var ceil_mesh := MeshInstance3D.new()
	ceil_mesh.mesh = floor_box.duplicate()
	ceil_mesh.position = Vector3(0, HALLWAY_HEIGHT, -HALLWAY_LENGTH / 2.0)
	var ceil_mat := StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.85, 0.9, 0.95)
	ceil_mesh.material_override = ceil_mat
	add_child(ceil_mesh)

	# Walls
	_build_wall(Vector3(-HALLWAY_WIDTH / 2.0, HALLWAY_HEIGHT / 2.0, -HALLWAY_LENGTH / 2.0),
				Vector3(0.15, HALLWAY_HEIGHT, HALLWAY_LENGTH), Color(0.55, 0.32, 0.18))
	_build_wall(Vector3(HALLWAY_WIDTH / 2.0, HALLWAY_HEIGHT / 2.0, -HALLWAY_LENGTH / 2.0),
				Vector3(0.15, HALLWAY_HEIGHT, HALLWAY_LENGTH), Color(0.55, 0.32, 0.18))

	# Subject boards on walls
	for i in range(SUBJECT_COUNT):
		var subject = subjects[i]
		var z_pos = -3.0 - (i * (HALLWAY_LENGTH - 6.0) / float(SUBJECT_COUNT - 1))
		var side = 1 if i % 2 == 0 else -1  # Alternate walls
		var x_pos = side * (HALLWAY_WIDTH / 2.0 - 0.2)

		_create_subject_board(subject, Vector3(x_pos, HALLWAY_HEIGHT * 0.55, z_pos), side, i)

	# Lighting
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.light_energy = 0.8
	light.shadow_enabled = true
	add_child(light)

	# Ambient light
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.3, 0.3, 0.35)
	environment.ambient_light_energy = 0.6
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.059, 0.059, 0.102)
	env.environment = environment
	add_child(env)

	# Point lights along hallway for warmth
	for i in range(7):
		var point := OmniLight3D.new()
		point.position = Vector3(0, HALLWAY_HEIGHT - 0.5, -3.0 - i * 7.0)
		point.light_energy = 1.5
		point.light_color = Color(1.0, 0.9, 0.7)
		point.omni_range = 6.0
		point.omni_attenuation = 1.5
		add_child(point)


func _build_wall(pos: Vector3, size: Vector3, color: Color) -> void:
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	wall.mesh = box
	wall.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	wall.material_override = mat
	add_child(wall)


func _create_subject_board(subject: Dictionary, pos: Vector3, side: int, index: int) -> void:
	# Board background (white/cream panel)
	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(0.05, 1.8, 2.5)
	board.mesh = board_mesh
	board.position = pos

	var is_completed = subject.id in _get_completed_ids()

	var mat := StandardMaterial3D.new()
	if is_completed:
		mat.albedo_color = Color(0.788, 0.659, 0.298, 1.0)  # Gold for completed
		mat.emission_enabled = true
		mat.emission = Color(0.788, 0.659, 0.298)
		mat.emission_energy_multiplier = 0.3
	else:
		mat.albedo_color = Color(0.95, 0.93, 0.88)  # Cream for available

	board.material_override = mat
	board.name = "Board_" + subject.id
	add_child(board)

	# 3D text for subject number
	var label_3d := Label3D.new()
	label_3d.text = "#" + subject.id + "\n" + subject.title
	label_3d.font_size = 48
	label_3d.position = pos + Vector3(-side * 0.1, 0.2, 0)
	label_3d.rotation_degrees.y = 90.0 * side
	label_3d.pixel_size = 0.005
	label_3d.modulate = Color(0.1, 0.1, 0.15)
	if is_completed:
		label_3d.modulate = Color(0.06, 0.06, 0.1)
	add_child(label_3d)

	# Phase indicator below title
	var phase_3d := Label3D.new()
	phase_3d.text = subject.phase
	phase_3d.font_size = 32
	phase_3d.position = pos + Vector3(-side * 0.1, -0.4, 0)
	phase_3d.rotation_degrees.y = 90.0 * side
	phase_3d.pixel_size = 0.004

	match subject.phase:
		"LIFE": phase_3d.modulate = Color(0.165, 0.616, 0.561)  # Teal
		"DREAMS": phase_3d.modulate = Color(0.788, 0.659, 0.298)  # Gold
		"WEALTH": phase_3d.modulate = Color(0.42, 0.357, 0.584)  # Purple

	add_child(phase_3d)

	# Collision area for interaction
	var area := Area3D.new()
	area.position = pos
	area.name = "Area_" + str(index)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 2.5, 3.0)
	collision.shape = shape
	area.add_child(collision)

	area.body_entered.connect(_on_subject_area_entered.bind(index))
	area.body_exited.connect(_on_subject_area_exited.bind(index))
	add_child(area)


func _get_completed_ids() -> Array:
	var ids: Array = []
	for sim_id in GameState.completed_simulations:
		ids.append(sim_id)
	return ids


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_mouse_captured:
		camera_rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_rotation.x = clampf(camera_rotation.x, -PI / 3.0, PI / 3.0)
		camera.rotation = Vector3(camera_rotation.x, camera_rotation.y, 0)

	if event.is_action_pressed("ui_cancel"):
		if is_mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			is_mouse_captured = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			is_mouse_captured = true

	if event.is_action_pressed("interact") and nearby_subject >= 0:
		_show_subject_info(nearby_subject)


func _process(delta: float) -> void:
	# First-person movement
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var forward = -camera.global_transform.basis.z
		var right = camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		var move = (forward * input_dir.z + right * input_dir.x).normalized()
		# Keep within hallway bounds
		var new_pos = camera.position + move * MOVE_SPEED * delta
		new_pos.x = clampf(new_pos.x, -HALLWAY_WIDTH / 2.0 + 0.5, HALLWAY_WIDTH / 2.0 - 0.5)
		new_pos.z = clampf(new_pos.z, -HALLWAY_LENGTH + 2.0, -1.0)
		new_pos.y = 1.6  # Eye height
		camera.position = new_pos


func _on_subject_area_entered(_body: Node3D, index: int) -> void:
	nearby_subject = index
	_show_subject_info(index)


func _on_subject_area_exited(_body: Node3D, _index: int) -> void:
	nearby_subject = -1
	info_panel.visible = false


func _show_subject_info(index: int) -> void:
	var subject = subjects[index]
	info_title.text = "#" + subject.id + " — " + subject.title
	info_desc.text = subject.desc
	info_phase.text = "Phase: " + subject.phase
	var is_completed = subject.id in _get_completed_ids()
	if is_completed:
		enter_btn.text = "REPLAY"
	else:
		enter_btn.text = "ENTER"
	info_panel.visible = true


func _on_enter_simulation() -> void:
	if nearby_subject < 0:
		return
	var subject = subjects[nearby_subject]
	GameState.current_simulation = subject.id
	# Load the simulation scene
	var scene_path = "res://scenes/simulations/sim_" + subject.id + ".tscn"
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		# Load the generic branching sim template
		get_tree().change_scene_to_file("res://scenes/simulation_template.tscn")


func _update_hud() -> void:
	iceberg_bar.value = GameState.get_iceberg_percent()
	savings_label.text = "Savings: $%.2f" % GameState.savings
	progress_label.text = "%d/13 Complete" % GameState.completed_simulations.size()
