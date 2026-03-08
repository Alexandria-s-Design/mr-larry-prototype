extends Node3D
## Third-Person Camera — Sims 4 style orbit camera following the player.
## Mouse right-drag to orbit, scroll to zoom, auto-follows player.

@export var target_path: NodePath
@export var distance: float = 8.0
@export var min_distance: float = 3.0
@export var max_distance: float = 15.0
@export var pitch: float = -35.0  # Degrees, looking down
@export var min_pitch: float = -70.0
@export var max_pitch: float = -10.0
@export var yaw: float = 0.0
@export var orbit_speed: float = 0.3
@export var zoom_speed: float = 1.0
@export var follow_speed: float = 8.0

var _target: Node3D
var _camera: Camera3D
var _is_orbiting: bool = false


func _ready() -> void:
	_camera = Camera3D.new()
	_camera.fov = 60.0
	_camera.near = 0.1
	_camera.far = 100.0
	add_child(_camera)
	_camera.current = true

	if not target_path.is_empty():
		_target = get_node(target_path)

	_update_camera_position()


func set_target(node: Node3D) -> void:
	_target = node


func _input(event: InputEvent) -> void:
	# Right mouse button to orbit
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_orbiting = event.pressed

		# Scroll to zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clampf(distance - zoom_speed, min_distance, max_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clampf(distance + zoom_speed, min_distance, max_distance)

	# Mouse motion for orbiting
	if event is InputEventMouseMotion and _is_orbiting:
		yaw -= event.relative.x * orbit_speed
		pitch -= event.relative.y * orbit_speed
		pitch = clampf(pitch, min_pitch, max_pitch)


func _process(delta: float) -> void:
	if _target == null:
		return

	# Smoothly follow target position
	var target_pos = _target.global_position + Vector3(0, 1.5, 0)  # Offset to character chest
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	_update_camera_position()


func _update_camera_position() -> void:
	if _camera == null:
		return

	var yaw_rad = deg_to_rad(yaw)
	var pitch_rad = deg_to_rad(pitch)

	# Calculate camera offset from orbit point
	var offset = Vector3.ZERO
	offset.x = distance * cos(pitch_rad) * sin(yaw_rad)
	offset.y = -distance * sin(pitch_rad)
	offset.z = distance * cos(pitch_rad) * cos(yaw_rad)

	_camera.position = offset
	_camera.look_at(Vector3.ZERO)  # Look at the pivot (which follows the player)
