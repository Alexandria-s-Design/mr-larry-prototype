extends Node3D
## Room Builder — Constructs the player's bedroom with walls, floor, and furniture.
## Uses procedural meshes with nice materials. Kenney models can replace later.

const GRID_SIZE := 8
const CELL_SIZE := 1.0
const WALL_HEIGHT := 3.0
const ROOM_OFFSET := Vector3(-4, 0, -4)  # Center the room

var furniture_nodes: Dictionary = {}  # "x_z" -> Node3D
var grid_occupied: Array = []  # 2D array tracking occupied cells


func _ready() -> void:
	_init_grid()
	_build_room()
	_place_default_furniture()


func _init_grid() -> void:
	grid_occupied = []
	for x in range(GRID_SIZE):
		var row: Array = []
		for z in range(GRID_SIZE):
			row.append(false)
		grid_occupied.append(row)


func _build_room() -> void:
	# Floor
	var floor_mesh := MeshInstance3D.new()
	var floor_plane := PlaneMesh.new()
	floor_plane.size = Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)
	floor_mesh.mesh = floor_plane
	floor_mesh.position = ROOM_OFFSET + Vector3(GRID_SIZE / 2.0, 0, GRID_SIZE / 2.0)
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.75, 0.6, 0.45)  # Warm wood floor
	floor_mesh.material_override = floor_mat
	floor_mesh.name = "Floor"
	add_child(floor_mesh)

	# Floor collision for CharacterBody3D
	var floor_body := StaticBody3D.new()
	floor_body.position = ROOM_OFFSET + Vector3(GRID_SIZE / 2.0, 0, GRID_SIZE / 2.0)
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(GRID_SIZE * CELL_SIZE, 0.1, GRID_SIZE * CELL_SIZE)
	floor_col.shape = floor_shape
	floor_col.position = Vector3(0, -0.05, 0)
	floor_body.add_child(floor_col)
	add_child(floor_body)

	# Walls — 4 sides
	_build_wall("back", Vector3(GRID_SIZE / 2.0, WALL_HEIGHT / 2.0, 0),
				Vector3(GRID_SIZE, WALL_HEIGHT, 0.15), Color(0.85, 0.82, 0.78))
	_build_wall("left", Vector3(0, WALL_HEIGHT / 2.0, GRID_SIZE / 2.0),
				Vector3(0.15, WALL_HEIGHT, GRID_SIZE), Color(0.8, 0.78, 0.74))
	_build_wall("right", Vector3(GRID_SIZE, WALL_HEIGHT / 2.0, GRID_SIZE / 2.0),
				Vector3(0.15, WALL_HEIGHT, GRID_SIZE), Color(0.8, 0.78, 0.74))
	# Front wall omitted (camera side) — Sims-style cutaway

	# Ceiling (subtle)
	var ceil_mesh := MeshInstance3D.new()
	ceil_mesh.mesh = floor_plane.duplicate()
	ceil_mesh.position = ROOM_OFFSET + Vector3(GRID_SIZE / 2.0, WALL_HEIGHT, GRID_SIZE / 2.0)
	ceil_mesh.rotation_degrees.x = 180
	var ceil_mat := StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.92, 0.92, 0.95)
	ceil_mesh.material_override = ceil_mat
	ceil_mesh.name = "Ceiling"
	add_child(ceil_mesh)

	# Grid lines (subtle visual guide on floor)
	_build_grid_lines()


func _build_wall(wall_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	wall.mesh = box
	wall.position = ROOM_OFFSET + pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	wall.material_override = mat
	wall.name = "Wall_" + wall_name
	add_child(wall)

	# Wall collision
	var wall_body := StaticBody3D.new()
	wall_body.position = ROOM_OFFSET + pos
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	wall_body.add_child(col)
	add_child(wall_body)


func _build_grid_lines() -> void:
	# Subtle grid overlay on the floor to help with furniture placement
	for x in range(GRID_SIZE + 1):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.02, 0.005, GRID_SIZE * CELL_SIZE)
		line.mesh = box
		line.position = ROOM_OFFSET + Vector3(x * CELL_SIZE, 0.01, GRID_SIZE / 2.0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.4, 0.3, 0.3)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		line.material_override = mat
		add_child(line)

	for z in range(GRID_SIZE + 1):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(GRID_SIZE * CELL_SIZE, 0.005, 0.02)
		line.mesh = box
		line.position = ROOM_OFFSET + Vector3(GRID_SIZE / 2.0, 0.01, z * CELL_SIZE)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.4, 0.3, 0.3)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		line.material_override = mat
		add_child(line)


func _place_default_furniture() -> void:
	# Default room: bed in corner, desk against wall, chair at desk
	place_item("bed_basic", 0, 0)
	place_item("desk_basic", 3, 0)
	place_item("chair_basic", 3, 1)


func place_item(item_id: String, grid_x: int, grid_z: int) -> bool:
	if grid_x < 0 or grid_x >= GRID_SIZE or grid_z < 0 or grid_z >= GRID_SIZE:
		return false
	if grid_occupied[grid_x][grid_z]:
		return false

	grid_occupied[grid_x][grid_z] = true

	var node := _create_furniture_mesh(item_id)
	node.position = ROOM_OFFSET + Vector3(grid_x * CELL_SIZE + 0.5, 0, grid_z * CELL_SIZE + 0.5)
	node.name = "Furniture_" + item_id + "_" + str(grid_x) + "_" + str(grid_z)
	add_child(node)

	var key = str(grid_x) + "_" + str(grid_z)
	furniture_nodes[key] = node

	# Add interaction area
	var area := Area3D.new()
	var area_col := CollisionShape3D.new()
	var area_shape := SphereShape3D.new()
	area_shape.radius = 1.2
	area_col.shape = area_shape
	area.add_child(area_col)
	area.name = "InteractArea"
	area.set_meta("item_id", item_id)
	area.set_meta("grid_x", grid_x)
	area.set_meta("grid_z", grid_z)
	node.add_child(area)

	return true


func remove_item(grid_x: int, grid_z: int) -> void:
	var key = str(grid_x) + "_" + str(grid_z)
	if furniture_nodes.has(key):
		furniture_nodes[key].queue_free()
		furniture_nodes.erase(key)
		grid_occupied[grid_x][grid_z] = false


func is_cell_free(grid_x: int, grid_z: int) -> bool:
	if grid_x < 0 or grid_x >= GRID_SIZE or grid_z < 0 or grid_z >= GRID_SIZE:
		return false
	return not grid_occupied[grid_x][grid_z]


func _create_furniture_mesh(item_id: String) -> Node3D:
	var root := Node3D.new()

	match item_id:
		"bed_basic", "bed_comfy", "bed_deluxe":
			_build_bed(root, item_id)
		"desk_basic", "desk_gamer":
			_build_desk(root, item_id)
		"chair_basic", "chair_bean", "chair_gaming":
			_build_chair(root, item_id)
		"bookshelf":
			_build_bookshelf(root)
		"tv_small", "tv_big":
			_build_tv(root, item_id)
		"game_console":
			_build_console(root)
		"poster_cool":
			_build_poster(root)
		"plant":
			_build_plant(root)
		"lamp_desk":
			_build_lamp(root)
		"rug_nice":
			_build_rug(root)
		"phone":
			_build_phone(root)
		"extra_chair":
			_build_chair(root, "chair_basic")
		"music_player":
			_build_music_player(root)
		_:
			_build_generic_box(root, Color(0.5, 0.5, 0.5))

	return root


func _build_bed(root: Node3D, variant: String) -> void:
	# Frame
	var frame := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.9, 0.3, 0.9)
	frame.mesh = box
	frame.position = Vector3(0, 0.15, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.35, 0.2)
	frame.material_override = mat
	root.add_child(frame)
	# Mattress
	var mattress := MeshInstance3D.new()
	var mbox := BoxMesh.new()
	mbox.size = Vector3(0.85, 0.15, 0.85)
	mattress.mesh = mbox
	mattress.position = Vector3(0, 0.37, 0)
	var mmat := StandardMaterial3D.new()
	match variant:
		"bed_basic": mmat.albedo_color = Color(0.9, 0.9, 0.9)
		"bed_comfy": mmat.albedo_color = Color(0.6, 0.75, 0.9)
		"bed_deluxe": mmat.albedo_color = Color(0.7, 0.5, 0.8)
	mattress.material_override = mmat
	root.add_child(mattress)
	# Pillow
	var pillow := MeshInstance3D.new()
	var pbox := BoxMesh.new()
	pbox.size = Vector3(0.35, 0.1, 0.25)
	pillow.mesh = pbox
	pillow.position = Vector3(0, 0.5, -0.25)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(1, 1, 1)
	pillow.material_override = pmat
	root.add_child(pillow)


func _build_desk(root: Node3D, variant: String) -> void:
	# Desktop surface
	var top := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.9, 0.05, 0.5)
	top.mesh = box
	top.position = Vector3(0, 0.7, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.45, 0.3) if variant == "desk_basic" else Color(0.15, 0.15, 0.2)
	top.material_override = mat
	root.add_child(top)
	# Legs
	for pos in [Vector3(-0.4, 0.35, -0.2), Vector3(0.4, 0.35, -0.2), Vector3(-0.4, 0.35, 0.2), Vector3(0.4, 0.35, 0.2)]:
		var leg := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.03
		cyl.bottom_radius = 0.03
		cyl.height = 0.7
		leg.mesh = cyl
		leg.position = pos
		leg.material_override = mat
		root.add_child(leg)
	# RGB strip for gaming desk
	if variant == "desk_gamer":
		var strip := MeshInstance3D.new()
		var sbox := BoxMesh.new()
		sbox.size = Vector3(0.88, 0.02, 0.02)
		strip.mesh = sbox
		strip.position = Vector3(0, 0.72, -0.24)
		var smat := StandardMaterial3D.new()
		smat.albedo_color = Color(0.0, 1.0, 0.8)
		smat.emission_enabled = true
		smat.emission = Color(0.0, 1.0, 0.8)
		smat.emission_energy_multiplier = 2.0
		strip.material_override = smat
		root.add_child(strip)


func _build_chair(root: Node3D, variant: String) -> void:
	if variant == "chair_bean":
		var bean := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.3
		sphere.height = 0.5
		bean.mesh = sphere
		bean.position = Vector3(0, 0.25, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.3, 0.2)
		bean.material_override = mat
		root.add_child(bean)
	else:
		# Standard chair
		var seat := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.4, 0.05, 0.4)
		seat.mesh = box
		seat.position = Vector3(0, 0.4, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.4, 0.3, 0.2) if variant == "chair_basic" else Color(0.1, 0.1, 0.12)
		seat.material_override = mat
		root.add_child(seat)
		# Back
		var back := MeshInstance3D.new()
		var bbox := BoxMesh.new()
		bbox.size = Vector3(0.4, 0.4, 0.05)
		back.mesh = bbox
		back.position = Vector3(0, 0.62, -0.17)
		back.material_override = mat
		root.add_child(back)


func _build_bookshelf(root: Node3D) -> void:
	var frame := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.8, 1.4, 0.3)
	frame.mesh = box
	frame.position = Vector3(0, 0.7, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.35, 0.2)
	frame.material_override = mat
	root.add_child(frame)
	# Books (colored blocks)
	for i in range(4):
		var book := MeshInstance3D.new()
		var bx := BoxMesh.new()
		bx.size = Vector3(0.6, 0.12, 0.2)
		book.mesh = bx
		book.position = Vector3(0, 0.2 + i * 0.35, 0)
		var bmat := StandardMaterial3D.new()
		bmat.albedo_color = [Color(0.8, 0.2, 0.2), Color(0.2, 0.6, 0.3), Color(0.2, 0.3, 0.8), Color(0.8, 0.6, 0.1)][i]
		book.material_override = bmat
		root.add_child(book)


func _build_tv(root: Node3D, variant: String) -> void:
	var screen := MeshInstance3D.new()
	var box := BoxMesh.new()
	var w = 0.6 if variant == "tv_small" else 0.9
	box.size = Vector3(w, w * 0.6, 0.05)
	screen.mesh = box
	screen.position = Vector3(0, 0.5, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.3, 0.5)
	mat.emission_energy_multiplier = 0.5
	screen.material_override = mat
	root.add_child(screen)


func _build_console(root: Node3D) -> void:
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.3, 0.08, 0.25)
	body.mesh = box
	body.position = Vector3(0, 0.04, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.12)
	body.material_override = mat
	root.add_child(body)
	# Power light
	var light := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.015
	light.mesh = sphere
	light.position = Vector3(0.12, 0.09, 0)
	var lmat := StandardMaterial3D.new()
	lmat.albedo_color = Color(0, 1, 0)
	lmat.emission_enabled = true
	lmat.emission = Color(0, 1, 0)
	lmat.emission_energy_multiplier = 3.0
	light.material_override = lmat
	root.add_child(light)


func _build_poster(root: Node3D) -> void:
	var poster := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.7, 0.02)
	poster.mesh = box
	poster.position = Vector3(0, 1.5, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.4, 0.2)
	poster.material_override = mat
	root.add_child(poster)


func _build_plant(root: Node3D) -> void:
	# Pot
	var pot := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.15
	cyl.bottom_radius = 0.12
	cyl.height = 0.2
	pot.mesh = cyl
	pot.position = Vector3(0, 0.1, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.3, 0.15)
	pot.material_override = mat
	root.add_child(pot)
	# Plant
	var plant := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.2
	plant.mesh = sphere
	plant.position = Vector3(0, 0.35, 0)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(0.2, 0.65, 0.25)
	plant.material_override = pmat
	root.add_child(plant)


func _build_lamp(root: Node3D) -> void:
	var base := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.03
	cyl.bottom_radius = 0.08
	cyl.height = 0.5
	base.mesh = cyl
	base.position = Vector3(0, 0.25, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.3, 0.3)
	base.material_override = mat
	root.add_child(base)
	# Shade
	var shade := MeshInstance3D.new()
	var scyl := CylinderMesh.new()
	scyl.top_radius = 0.05
	scyl.bottom_radius = 0.15
	scyl.height = 0.2
	shade.mesh = scyl
	shade.position = Vector3(0, 0.55, 0)
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 0.95, 0.8)
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.9, 0.7)
	smat.emission_energy_multiplier = 1.0
	shade.material_override = smat
	root.add_child(shade)
	# Light source
	var omni := OmniLight3D.new()
	omni.position = Vector3(0, 0.6, 0)
	omni.light_energy = 1.0
	omni.light_color = Color(1.0, 0.9, 0.7)
	omni.omni_range = 3.0
	root.add_child(omni)


func _build_rug(root: Node3D) -> void:
	var rug := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(0.8, 0.8)
	rug.mesh = plane
	rug.position = Vector3(0, 0.01, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.2, 0.2)
	rug.material_override = mat
	root.add_child(rug)


func _build_phone(root: Node3D) -> void:
	var phone := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.08, 0.15, 0.01)
	phone.mesh = box
	phone.position = Vector3(0, 0.75, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.5, 0.9)
	mat.emission_energy_multiplier = 0.5
	phone.material_override = mat
	root.add_child(phone)


func _build_music_player(root: Node3D) -> void:
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.25, 0.15, 0.15)
	body.mesh = box
	body.position = Vector3(0, 0.08, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.25)
	body.material_override = mat
	root.add_child(body)
	# Speaker circles
	for side in [-0.08, 0.08]:
		var speaker := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.04
		cyl.bottom_radius = 0.04
		cyl.height = 0.01
		speaker.mesh = cyl
		speaker.position = Vector3(side, 0.08, 0.08)
		speaker.rotation_degrees.x = 90
		var smat := StandardMaterial3D.new()
		smat.albedo_color = Color(0.1, 0.1, 0.1)
		speaker.material_override = smat
		root.add_child(speaker)


func _build_generic_box(root: Node3D, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 0.5)
	mesh.mesh = box
	mesh.position = Vector3(0, 0.25, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	root.add_child(mesh)
