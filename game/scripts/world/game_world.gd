extends Node3D
## Game World — Main scene controller for the Sims-style life simulation.
## Manages the room, player, camera, lighting, and UI connections.

var player: CharacterBody3D
var camera_pivot: Node3D
var room: Node3D
var hud: Control
var event_popup: Control
var shop_menu: Control
var jar_allocator: Control
var interaction_label: Label
var nearby_furniture: String = ""

var is_shop_open: bool = false
var is_event_open: bool = false


func _ready() -> void:
	# Build the room
	var room_builder_script = preload("res://scripts/world/room_builder.gd")
	room = Node3D.new()
	room.set_script(room_builder_script)
	room.name = "Room"
	add_child(room)

	# Create the player
	var player_script = preload("res://scripts/characters/player_controller.gd")
	player = CharacterBody3D.new()
	player.set_script(player_script)
	player.name = "Player"
	player.position = Vector3(0, 0, 2)
	add_child(player)

	# Create the camera
	var cam_script = preload("res://scripts/world/third_person_camera.gd")
	camera_pivot = Node3D.new()
	camera_pivot.set_script(cam_script)
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera_pivot.set_target(player)
	player.camera_pivot = camera_pivot

	# Lighting
	_setup_lighting()

	# Build the HUD
	_build_hud()

	# Build event popup (hidden)
	_build_event_popup()

	# Build shop menu (hidden)
	_build_shop_menu()

	# Build jar allocator (hidden)
	_build_jar_allocator()

	# Interaction hint label
	interaction_label = Label.new()
	interaction_label.text = ""
	interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_label.position = Vector2(440, 620)
	interaction_label.size = Vector2(400, 30)
	interaction_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	interaction_label.add_theme_font_size_override("font_size", 16)
	interaction_label.visible = false
	hud.add_child(interaction_label)

	# Connect event signals
	EventManager.event_triggered.connect(_on_event_triggered)
	TimeManager.time_updated.connect(_update_hud)
	TimeManager.week_changed.connect(_on_week_changed)

	_update_hud()


func _setup_lighting() -> void:
	# Main directional light
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.light_color = TimeManager.get_ambient_color()
	sun.name = "Sun"
	add_child(sun)

	# Ambient fill
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.4, 0.4, 0.45)
	environment.ambient_light_energy = 0.6
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.35, 0.55, 0.75)  # Sky blue
	environment.tonemap_mode = Environment.TONE_MAP_ACES
	env.environment = environment
	add_child(env)

	# Room light
	var room_light := OmniLight3D.new()
	room_light.position = Vector3(0, 2.5, 0)
	room_light.light_energy = 1.2
	room_light.light_color = Color(1.0, 0.95, 0.85)
	room_light.omni_range = 8.0
	room_light.omni_attenuation = 1.5
	room_light.name = "RoomLight"
	add_child(room_light)


func _build_hud() -> void:
	hud = Control.new()
	hud.name = "HUD"
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud)

	# Background panel for needs (bottom center, Sims-style)
	var needs_panel := Panel.new()
	needs_panel.position = Vector2(390, 640)
	needs_panel.size = Vector2(500, 70)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.6)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	needs_panel.add_theme_stylebox_override("panel", panel_style)
	hud.add_child(needs_panel)

	# Need bars
	var need_names = ["energy", "fun", "social", "hunger"]
	var need_labels = ["Energy", "Fun", "Social", "Hunger"]
	var need_colors = [
		Color(0.3, 0.5, 0.9),   # Blue
		Color(0.2, 0.8, 0.3),   # Green
		Color(0.9, 0.5, 0.2),   # Orange
		Color(0.9, 0.2, 0.3),   # Red
	]

	for i in range(4):
		var x_pos = 10 + i * 122

		var label := Label.new()
		label.text = need_labels[i]
		label.position = Vector2(x_pos, 5)
		label.size = Vector2(115, 20)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", need_colors[i])
		label.add_theme_font_size_override("font_size", 11)
		needs_panel.add_child(label)

		var bar := ProgressBar.new()
		bar.position = Vector2(x_pos, 25)
		bar.size = Vector2(115, 18)
		bar.max_value = 100
		bar.value = GameState.needs[need_names[i]]
		bar.show_percentage = false
		bar.name = "Need_" + need_names[i]
		# Style the bar
		var bar_bg := StyleBoxFlat.new()
		bar_bg.bg_color = Color(0.15, 0.15, 0.2)
		bar_bg.corner_radius_top_left = 4
		bar_bg.corner_radius_top_right = 4
		bar_bg.corner_radius_bottom_left = 4
		bar_bg.corner_radius_bottom_right = 4
		bar.add_theme_stylebox_override("background", bar_bg)
		var bar_fill := StyleBoxFlat.new()
		bar_fill.bg_color = need_colors[i]
		bar_fill.corner_radius_top_left = 4
		bar_fill.corner_radius_top_right = 4
		bar_fill.corner_radius_bottom_left = 4
		bar_fill.corner_radius_bottom_right = 4
		bar.add_theme_stylebox_override("fill", bar_fill)
		needs_panel.add_child(bar)

		var val_label := Label.new()
		val_label.text = str(int(GameState.needs[need_names[i]]))
		val_label.position = Vector2(x_pos, 44)
		val_label.size = Vector2(115, 20)
		val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		val_label.add_theme_font_size_override("font_size", 10)
		val_label.name = "NeedVal_" + need_names[i]
		needs_panel.add_child(val_label)

	# Money display (top left)
	var money_panel := Panel.new()
	money_panel.position = Vector2(10, 10)
	money_panel.size = Vector2(250, 90)
	money_panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	hud.add_child(money_panel)

	var money_label := Label.new()
	money_label.text = "MONEY"
	money_label.position = Vector2(10, 5)
	money_label.add_theme_color_override("font_color", Color(0.788, 0.659, 0.298))
	money_label.add_theme_font_size_override("font_size", 14)
	money_panel.add_child(money_label)

	var save_label := Label.new()
	save_label.name = "SaveLabel"
	save_label.text = "Save: $%.2f" % GameState.save_jar
	save_label.position = Vector2(10, 25)
	save_label.add_theme_color_override("font_color", Color(0.165, 0.616, 0.561))
	save_label.add_theme_font_size_override("font_size", 12)
	money_panel.add_child(save_label)

	var spend_label := Label.new()
	spend_label.name = "SpendLabel"
	spend_label.text = "Spend: $%.2f" % GameState.spend_jar
	spend_label.position = Vector2(10, 45)
	spend_label.add_theme_color_override("font_color", Color(0.788, 0.659, 0.298))
	spend_label.add_theme_font_size_override("font_size", 12)
	money_panel.add_child(spend_label)

	var share_label := Label.new()
	share_label.name = "ShareLabel"
	share_label.text = "Share: $%.2f" % GameState.share_jar
	share_label.position = Vector2(10, 65)
	share_label.add_theme_color_override("font_color", Color(0.42, 0.357, 0.584))
	share_label.add_theme_font_size_override("font_size", 12)
	money_panel.add_child(share_label)

	# Time display (top right)
	var time_panel := Panel.new()
	time_panel.position = Vector2(1020, 10)
	time_panel.size = Vector2(250, 60)
	time_panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	hud.add_child(time_panel)

	var time_label := Label.new()
	time_label.name = "TimeLabel"
	time_label.text = TimeManager.get_time_string()
	time_label.position = Vector2(10, 5)
	time_label.size = Vector2(230, 25)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	time_label.add_theme_font_size_override("font_size", 14)
	time_panel.add_child(time_label)

	var iceberg_label := Label.new()
	iceberg_label.name = "IcebergLabel"
	iceberg_label.text = "Iceberg: %.0f%%" % GameState.get_iceberg_percent()
	iceberg_label.position = Vector2(10, 32)
	iceberg_label.size = Vector2(230, 20)
	iceberg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	iceberg_label.add_theme_color_override("font_color", Color(0.165, 0.616, 0.561))
	iceberg_label.add_theme_font_size_override("font_size", 12)
	time_panel.add_child(iceberg_label)

	# Action buttons (bottom right)
	var btn_panel := Panel.new()
	btn_panel.position = Vector2(1050, 640)
	btn_panel.size = Vector2(220, 70)
	btn_panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	hud.add_child(btn_panel)

	var shop_btn := Button.new()
	shop_btn.text = "SHOP"
	shop_btn.position = Vector2(10, 10)
	shop_btn.size = Vector2(95, 50)
	shop_btn.pressed.connect(_toggle_shop)
	btn_panel.add_child(shop_btn)

	var action_btn := Button.new()
	action_btn.text = "ACTIONS"
	action_btn.position = Vector2(115, 10)
	action_btn.size = Vector2(95, 50)
	action_btn.name = "ActionButton"
	action_btn.pressed.connect(_show_actions_menu)
	btn_panel.add_child(action_btn)


func _build_event_popup() -> void:
	event_popup = Control.new()
	event_popup.name = "EventPopup"
	event_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_popup.visible = false
	add_child(event_popup)

	# Dim overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	event_popup.add_child(overlay)

	# Event panel
	var panel := Panel.new()
	panel.position = Vector2(190, 80)
	panel.size = Vector2(900, 560)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.788, 0.659, 0.298, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	panel.name = "EventPanel"
	event_popup.add_child(panel)

	var title := Label.new()
	title.name = "EventTitle"
	title.text = "Event Title"
	title.position = Vector2(20, 15)
	title.size = Vector2(860, 35)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.788, 0.659, 0.298))
	title.add_theme_font_size_override("font_size", 24)
	panel.add_child(title)

	var desc := RichTextLabel.new()
	desc.name = "EventDesc"
	desc.position = Vector2(30, 60)
	desc.size = Vector2(840, 80)
	desc.bbcode_enabled = true
	desc.add_theme_color_override("default_color", Color(0.85, 0.85, 0.9))
	desc.add_theme_font_size_override("normal_font_size", 16)
	panel.add_child(desc)

	var mr_larry := RichTextLabel.new()
	mr_larry.name = "MrLarryText"
	mr_larry.position = Vector2(30, 145)
	mr_larry.size = Vector2(840, 60)
	mr_larry.bbcode_enabled = true
	mr_larry.add_theme_color_override("default_color", Color(0.165, 0.616, 0.561))
	mr_larry.add_theme_font_size_override("normal_font_size", 14)
	panel.add_child(mr_larry)

	var choices := VBoxContainer.new()
	choices.name = "ChoicesContainer"
	choices.position = Vector2(30, 220)
	choices.size = Vector2(840, 250)
	choices.add_theme_constant_override("separation", 12)
	panel.add_child(choices)

	var consequence := RichTextLabel.new()
	consequence.name = "ConsequenceText"
	consequence.position = Vector2(30, 470)
	consequence.size = Vector2(600, 70)
	consequence.bbcode_enabled = true
	consequence.visible = false
	consequence.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9))
	consequence.add_theme_font_size_override("normal_font_size", 14)
	panel.add_child(consequence)

	var continue_btn := Button.new()
	continue_btn.name = "ContinueBtn"
	continue_btn.text = "CONTINUE"
	continue_btn.position = Vector2(700, 490)
	continue_btn.size = Vector2(170, 50)
	continue_btn.visible = false
	continue_btn.pressed.connect(_close_event)
	panel.add_child(continue_btn)


func _build_shop_menu() -> void:
	shop_menu = Control.new()
	shop_menu.name = "ShopMenu"
	shop_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_menu.visible = false
	add_child(shop_menu)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.4)
	shop_menu.add_child(overlay)

	var panel := Panel.new()
	panel.position = Vector2(240, 60)
	panel.size = Vector2(800, 600)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.14)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	shop_menu.add_child(panel)

	var shop_title := Label.new()
	shop_title.text = "SHOP"
	shop_title.position = Vector2(20, 10)
	shop_title.size = Vector2(760, 35)
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_title.add_theme_color_override("font_color", Color(0.788, 0.659, 0.298))
	shop_title.add_theme_font_size_override("font_size", 24)
	panel.add_child(shop_title)

	var budget_label := Label.new()
	budget_label.name = "ShopBudget"
	budget_label.text = "Spending Money: $%.2f" % GameState.spend_jar
	budget_label.position = Vector2(20, 45)
	budget_label.size = Vector2(760, 25)
	budget_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	budget_label.add_theme_color_override("font_color", Color(0.165, 0.616, 0.561))
	budget_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(budget_label)

	# Category tabs
	var tab_row := HBoxContainer.new()
	tab_row.position = Vector2(20, 75)
	tab_row.size = Vector2(760, 35)
	tab_row.add_theme_constant_override("separation", 5)
	panel.add_child(tab_row)

	var categories = ["bed", "desk", "chair", "fun", "social", "decor", "food"]
	var cat_labels = ["Beds", "Desks", "Chairs", "Fun", "Social", "Decor", "Food"]
	for i in range(categories.size()):
		var btn := Button.new()
		btn.text = cat_labels[i]
		btn.custom_minimum_size = Vector2(100, 30)
		btn.pressed.connect(_show_shop_category.bind(categories[i]))
		tab_row.add_child(btn)

	# Item list
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 115)
	scroll.size = Vector2(760, 430)
	panel.add_child(scroll)

	var item_list := VBoxContainer.new()
	item_list.name = "ShopItemList"
	item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_list.add_theme_constant_override("separation", 8)
	scroll.add_child(item_list)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(755, 10)
	close_btn.size = Vector2(35, 35)
	close_btn.pressed.connect(_toggle_shop)
	panel.add_child(close_btn)

	# Default to showing beds
	_show_shop_category("bed")


func _build_jar_allocator() -> void:
	jar_allocator = Control.new()
	jar_allocator.name = "JarAllocator"
	jar_allocator.set_anchors_preset(Control.PRESET_FULL_RECT)
	jar_allocator.visible = false
	add_child(jar_allocator)
	# Will be populated when needed


func _process(_delta: float) -> void:
	if is_event_open or is_shop_open:
		return
	_check_nearby_furniture()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not nearby_furniture.is_empty():
		_interact_with_furniture(nearby_furniture)

	if event.is_action_pressed("ui_cancel"):
		if is_shop_open:
			_toggle_shop()
		elif is_event_open:
			pass  # Can't close events — must choose


func _check_nearby_furniture() -> void:
	if player == null or room == null:
		nearby_furniture = ""
		interaction_label.visible = false
		return

	# Check for nearby furniture interaction areas
	var closest_id := ""
	var closest_dist := 2.0

	for child in room.get_children():
		if child is Node3D:
			for sub in child.get_children():
				if sub is Area3D and sub.has_meta("item_id"):
					var dist = player.global_position.distance_to(sub.global_position)
					if dist < closest_dist:
						closest_dist = dist
						closest_id = sub.get_meta("item_id")

	nearby_furniture = closest_id
	if not closest_id.is_empty():
		var item = EconomyManager.get_item(closest_id)
		interaction_label.text = "Press E to use " + item.get("name", closest_id)
		interaction_label.visible = true
	else:
		interaction_label.visible = false


func _interact_with_furniture(item_id: String) -> void:
	EconomyManager.use_furniture(item_id)
	TimeManager.advance_period()
	_update_hud()


func _update_hud() -> void:
	# Update need bars
	for need in ["energy", "fun", "social", "hunger"]:
		var bar_path = "HUD/Need_" + need
		var bar = _find_in_children(hud, "Need_" + need)
		if bar and bar is ProgressBar:
			bar.value = GameState.needs[need]
		var val = _find_in_children(hud, "NeedVal_" + need)
		if val and val is Label:
			val.text = str(int(GameState.needs[need]))

	# Update money
	var save_l = _find_in_children(hud, "SaveLabel")
	if save_l: save_l.text = "Save: $%.2f" % GameState.save_jar
	var spend_l = _find_in_children(hud, "SpendLabel")
	if spend_l: spend_l.text = "Spend: $%.2f" % GameState.spend_jar
	var share_l = _find_in_children(hud, "ShareLabel")
	if share_l: share_l.text = "Share: $%.2f" % GameState.share_jar

	# Update time
	var time_l = _find_in_children(hud, "TimeLabel")
	if time_l: time_l.text = TimeManager.get_time_string()
	var ice_l = _find_in_children(hud, "IcebergLabel")
	if ice_l: ice_l.text = "Iceberg: %.0f%%" % GameState.get_iceberg_percent()


func _find_in_children(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _find_in_children(child, target_name)
		if found:
			return found
	return null


func _toggle_shop() -> void:
	is_shop_open = not is_shop_open
	shop_menu.visible = is_shop_open
	if is_shop_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var budget = _find_in_children(shop_menu, "ShopBudget")
		if budget: budget.text = "Spending Money: $%.2f" % GameState.spend_jar
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _show_shop_category(category: String) -> void:
	var item_list = _find_in_children(shop_menu, "ShopItemList")
	if not item_list:
		return

	# Clear existing items
	for child in item_list.get_children():
		child.queue_free()

	# Populate with category items
	var items = EconomyManager.get_catalog_by_category(category)
	for id in items:
		var item = items[id]
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 50)

		var name_label := Label.new()
		name_label.text = item.name
		name_label.custom_minimum_size = Vector2(150, 0)
		name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		row.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = item.desc
		desc_label.custom_minimum_size = Vector2(300, 0)
		desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
		desc_label.add_theme_font_size_override("font_size", 12)
		row.add_child(desc_label)

		var price_label := Label.new()
		price_label.text = "$%.2f" % item.cost if item.cost > 0 else "FREE"
		price_label.custom_minimum_size = Vector2(80, 0)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_label.add_theme_color_override("font_color", Color(0.165, 0.616, 0.561))
		row.add_child(price_label)

		var owned = id in GameState.owned_furniture
		var buy_btn := Button.new()
		if category == "food":
			buy_btn.text = "EAT" if EconomyManager.can_afford(id) else "CAN'T AFFORD"
		elif owned:
			buy_btn.text = "OWNED"
			buy_btn.disabled = true
		elif EconomyManager.can_afford(id):
			buy_btn.text = "BUY"
		else:
			buy_btn.text = "CAN'T AFFORD"
			buy_btn.disabled = true
		buy_btn.custom_minimum_size = Vector2(120, 0)
		buy_btn.pressed.connect(_on_buy_pressed.bind(id, category))
		row.add_child(buy_btn)

		item_list.add_child(row)


func _on_buy_pressed(item_id: String, category: String) -> void:
	if EconomyManager.purchase(item_id):
		# For non-food items, place in room at next free spot
		if category != "food":
			_auto_place_furniture(item_id)
		_update_hud()
		_show_shop_category(category)  # Refresh shop
		var budget = _find_in_children(shop_menu, "ShopBudget")
		if budget: budget.text = "Spending Money: $%.2f" % GameState.spend_jar


func _auto_place_furniture(item_id: String) -> void:
	# Find first free grid cell
	for x in range(room.GRID_SIZE):
		for z in range(room.GRID_SIZE):
			if room.is_cell_free(x, z):
				room.place_item(item_id, x, z)
				return


func _on_event_triggered(event_data: Dictionary) -> void:
	_show_event(event_data)


func _show_event(event_data: Dictionary) -> void:
	is_event_open = true
	event_popup.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var panel = _find_in_children(event_popup, "EventPanel")
	var title = _find_in_children(panel, "EventTitle")
	var desc = _find_in_children(panel, "EventDesc")
	var mr_larry = _find_in_children(panel, "MrLarryText")
	var choices = _find_in_children(panel, "ChoicesContainer")
	var consequence = _find_in_children(panel, "ConsequenceText")
	var continue_btn = _find_in_children(panel, "ContinueBtn")

	title.text = event_data.get("title", "Life Event")
	desc.text = event_data.get("description", "")
	mr_larry.text = "[b]Mr. Larry says:[/b] " + event_data.get("mr_larry_intro", "")
	consequence.visible = false
	continue_btn.visible = false

	# Clear old choices
	for child in choices.get_children():
		child.queue_free()

	# Create choice buttons
	var options = event_data.get("options", [])
	for i in range(options.size()):
		var option = options[i]
		var btn := Button.new()
		btn.text = option.get("label", "Option " + str(i + 1))
		btn.custom_minimum_size = Vector2(0, 55)
		btn.add_theme_font_size_override("font_size", 15)
		btn.pressed.connect(_on_event_choice.bind(event_data, i))
		choices.add_child(btn)


func _on_event_choice(event_data: Dictionary, choice_index: int) -> void:
	var option = event_data.options[choice_index]
	var panel = _find_in_children(event_popup, "EventPanel")

	# Disable all choice buttons
	var choices = _find_in_children(panel, "ChoicesContainer")
	for child in choices.get_children():
		if child is Button:
			child.disabled = true

	# Show consequence
	var consequence = _find_in_children(panel, "ConsequenceText")
	consequence.text = option.get("consequence", "Choice recorded.")
	consequence.visible = true

	# Update Mr. Larry text
	var mr_larry = _find_in_children(panel, "MrLarryText")
	var says = option.get("mr_larry_says", "")
	if says != "":
		mr_larry.text = "[b]Mr. Larry says:[/b] " + says

	# Show continue button
	var continue_btn = _find_in_children(panel, "ContinueBtn")
	continue_btn.visible = true

	# Apply consequences
	EventManager.resolve_event(event_data.id, choice_index, option)
	_update_hud()


func _close_event() -> void:
	is_event_open = false
	event_popup.visible = false
	_update_hud()


func _on_week_changed(week: int) -> void:
	# Show weekly income notification (simple for now)
	_update_hud()


func _show_actions_menu() -> void:
	# Quick actions popup — eat, sleep, study, play, call friend
	var actions_popup = _find_in_children(hud, "ActionsPopup")
	if actions_popup:
		actions_popup.queue_free()

	var popup := Panel.new()
	popup.name = "ActionsPopup"
	popup.position = Vector2(900, 440)
	popup.size = Vector2(220, 200)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	popup.add_theme_stylebox_override("panel", style)
	hud.add_child(popup)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(10, 10)
	vbox.size = Vector2(200, 180)
	vbox.add_theme_constant_override("separation", 5)
	popup.add_child(vbox)

	var actions = [
		["Sleep (restore energy)", "sleep"],
		["Eat — $3 sandwich", "eat_medium"],
		["Play (restore fun)", "play"],
		["Call a friend", "call_friend"],
		["Study", "study"],
	]

	for action in actions:
		var btn := Button.new()
		btn.text = action[0]
		btn.custom_minimum_size = Vector2(0, 30)
		btn.pressed.connect(func():
			var needs_sys = NeedsSystem
			if needs_sys:
				needs_sys.do_activity(action[1])
			_update_hud()
			popup.queue_free()
		)
		vbox.add_child(btn)

	# Auto-close after 5 seconds
	get_tree().create_timer(5.0).timeout.connect(func():
		if is_instance_valid(popup):
			popup.queue_free()
	)
