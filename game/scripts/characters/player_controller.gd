extends CharacterBody3D
## Player Controller — WASD movement with third-person camera.
## Character is a procedural mesh (capsule + sphere head) for now.

@export var move_speed: float = 4.0
@export var rotation_speed: float = 10.0

var camera_pivot: Node3D  # Reference to the camera pivot for directional movement

# Visual components
var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var shadow_mesh: MeshInstance3D


func _ready() -> void:
	_build_character()


func _build_character() -> void:
	# Body — capsule
	body_mesh = MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.25
	capsule.height = 0.9
	body_mesh.mesh = capsule
	body_mesh.position = Vector3(0, 0.55, 0)
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = GameState.character_data.get("shirt_color", Color(0.2, 0.5, 0.8))
	body_mesh.material_override = body_mat
	add_child(body_mesh)

	# Head — sphere
	head_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	head_mesh.mesh = sphere
	head_mesh.position = Vector3(0, 1.15, 0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = GameState.character_data.get("skin_color", Color(0.76, 0.58, 0.44))
	head_mesh.material_override = head_mat
	add_child(head_mesh)

	# Hair — slightly larger hemisphere on top
	var hair_mesh := MeshInstance3D.new()
	var hair := SphereMesh.new()
	hair.radius = 0.23
	hair.height = 0.3
	hair_mesh.mesh = hair
	hair_mesh.position = Vector3(0, 1.3, 0)
	var hair_mat := StandardMaterial3D.new()
	hair_mat.albedo_color = GameState.character_data.get("hair_color", Color(0.15, 0.1, 0.07))
	hair_mesh.material_override = hair_mat
	add_child(hair_mesh)

	# Legs — two small cylinders
	for side in [-0.12, 0.12]:
		var leg := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.08
		cyl.bottom_radius = 0.1
		cyl.height = 0.4
		leg.mesh = cyl
		leg.position = Vector3(side, 0.2, 0)
		var leg_mat := StandardMaterial3D.new()
		leg_mat.albedo_color = GameState.character_data.get("pants_color", Color(0.2, 0.2, 0.35))
		leg.material_override = leg_mat
		add_child(leg)

	# Shadow blob on ground
	shadow_mesh = MeshInstance3D.new()
	var shadow_plane := PlaneMesh.new()
	shadow_plane.size = Vector2(0.6, 0.6)
	shadow_mesh.mesh = shadow_plane
	shadow_mesh.position = Vector3(0, 0.02, 0)
	var shadow_mat := StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0, 0, 0, 0.3)
	shadow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_mesh.material_override = shadow_mat
	add_child(shadow_mesh)

	# Collision shape
	var col := CollisionShape3D.new()
	var col_shape := CapsuleShape3D.new()
	col_shape.radius = 0.3
	col_shape.height = 1.2
	col.shape = col_shape
	col.position = Vector3(0, 0.6, 0)
	add_child(col)


func _physics_process(delta: float) -> void:
	# Get input direction
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

		# Get camera's forward and right vectors (flattened to XZ plane)
		var cam_forward := Vector3.ZERO
		var cam_right := Vector3.ZERO

		if camera_pivot:
			var cam = camera_pivot.get_node("Camera3D") if camera_pivot.has_node("Camera3D") else null
			if cam == null:
				# Camera is a child — find it
				for child in camera_pivot.get_children():
					if child is Camera3D:
						cam = child
						break

			if cam:
				cam_forward = -cam.global_transform.basis.z
				cam_right = cam.global_transform.basis.x
			else:
				cam_forward = Vector3(0, 0, -1)
				cam_right = Vector3(1, 0, 0)
		else:
			cam_forward = Vector3(0, 0, -1)
			cam_right = Vector3(1, 0, 0)

		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		var move_dir = (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()

		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed

		# Rotate character to face movement direction
		var target_angle = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

		# Simple walk animation — bob up and down
		body_mesh.position.y = 0.55 + sin(Time.get_ticks_msec() * 0.01) * 0.03
		head_mesh.position.y = 1.15 + sin(Time.get_ticks_msec() * 0.01) * 0.03
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * delta * 8)
		velocity.z = move_toward(velocity.z, 0, move_speed * delta * 8)

	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	move_and_slide()
