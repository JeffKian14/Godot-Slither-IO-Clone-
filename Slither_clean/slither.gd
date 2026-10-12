
# Last Test - Automatic Python AI Integration
extends Node2D

@export var food_scene : PackedScene
@export var player_scene : PackedScene
@export var enemy_scene : PackedScene
@export var ai_scene : PackedScene

@export var map_bounds : Vector2 = Vector2(7000, 7000)
@export var amount_of_food : int = 3000
@export var amount_of_enemies : int = 10

# --- PYTHON AI CONFIGURATION ---
# Change this to the full path of python.exe if necessary.
@export var python_executable: String = "python"

# Relative to the Godot project root.
@export var python_script_path: String = "res://Slither_clean/play.py"

var ai_process_id: int = -1

# --- OPTIMIZATION: Cached array for active snakes ---
var active_snakes: Array[Node] = []

# --- GAME RESET VARIABLES ---
var global_timestep : int = 0
var max_timesteps : int = 70000

# --- UI VARIABLES ---
@onready var start_menu: CanvasLayer = $StartMenu
@onready var start_button: Button = $StartMenu/StartButton

var menu_camera: Camera2D



func _ready() -> void:

	# 1. Launch Python AI first
	print("Preparing to start Python AI...")
	start_python_ai()

	# 2. Initialise the game
	create_world_border()
	initiate_food()
	initiate_enemy()

	# 3. Connect the start button
	start_button.pressed.connect(_on_start_button_pressed)

	# 4. Set up spectator camera
	menu_camera = Camera2D.new()
	menu_camera.global_position = Vector2.ZERO
	menu_camera.zoom = Vector2(0.2, 0.2)

	add_child(menu_camera)
	menu_camera.make_current()

	print("Godot game initialisation completed.")



func start_python_ai() -> void:

	# Prevent duplicate AI processes
	if ai_process_id != -1:
		if OS.is_process_running(ai_process_id):
			return

	ai_process_id = -1

	var launch_path: String
	var launch_args: PackedStringArray = PackedStringArray()

	# Running inside Godot Editor
	if OS.has_feature("editor"):

		var script_path = ProjectSettings.globalize_path(
			python_script_path
		)

		if not FileAccess.file_exists(script_path):
			push_error("AI script missing: " + script_path)
			return

		launch_path = python_executable
		launch_args.append(script_path)

	# Running as an exported Windows application
	else:

		var game_folder = OS.get_executable_path().get_base_dir()

		launch_path = game_folder.path_join(
			"AI"
		).path_join(
			"SlitherAI.exe"
		)

		if not FileAccess.file_exists(launch_path):
			push_error("Packaged AI missing: " + launch_path)
			return

	print("Starting AI: ", launch_path)

	ai_process_id = OS.create_process(
		launch_path,
		launch_args,
		false
	)

	if ai_process_id == -1:
		push_error("Unable to start AI process.")
	else:
		print("AI started. PID: ", ai_process_id)


# Terminate the Python process when Godot exits.
func _exit_tree() -> void:

	if ai_process_id != -1:

		if OS.is_process_running(ai_process_id):
			print("Stopping Python AI...")
			OS.kill(ai_process_id)

		ai_process_id = -1


# ==================================================
# START MENU
# ==================================================

func _on_start_button_pressed() -> void:

	# Hide the menu UI
	start_menu.hide()

	# Spawn the player into the game
	initiate_player()

	# Destroy the spectator camera
	# Godot will automatically switch to the player's camera
	if is_instance_valid(menu_camera):
		menu_camera.queue_free()


# ==================================================
# PHYSICS PROCESS
# ==================================================

func _physics_process(_delta: float) -> void:

	# 1. Update the Spatial Grid using the cached array
	SpatialGrid.clear_grid()

	for snake in active_snakes:
		if is_instance_valid(snake):
			if snake.has_method("register_to_grid"):
				snake.register_to_grid()

	# 2. The Top-Up Manager
	var current_food_count = get_tree().get_node_count_in_group("food")

	if current_food_count < amount_of_food:
		spawn_single_food()

	# 3. GLOBAL TIMESTEP RESET
	global_timestep += 1

	if global_timestep >= max_timesteps:
		reset_entire_game()


# ==================================================
# ARRAY REGISTRATION METHODS
# ==================================================

func register_new_snake(snake: Node) -> void:

	if not active_snakes.has(snake):
		active_snakes.append(snake)


func unregister_dead_snake(snake: Node) -> void:

	active_snakes.erase(snake)


# ==================================================
# WORLD BORDER
# ==================================================

func create_world_border() -> void:

	var thickness = 200

	var wall_data = [
		{
			"pos": Vector2(
				0,
				-map_bounds.y / 2 - thickness / 2
			),
			"size": Vector2(
				map_bounds.x + thickness * 2,
				thickness
			)
		},
		{
			"pos": Vector2(
				0,
				map_bounds.y / 2 + thickness / 2
			),
			"size": Vector2(
				map_bounds.x + thickness * 2,
				thickness
			)
		},
		{
			"pos": Vector2(
				-map_bounds.x / 2 - thickness / 2,
				0
			),
			"size": Vector2(
				thickness,
				map_bounds.y
			)
		},
		{
			"pos": Vector2(
				map_bounds.x / 2 + thickness / 2,
				0
			),
			"size": Vector2(
				thickness,
				map_bounds.y
			)
		}
	]

	for data in wall_data:

		var static_body = StaticBody2D.new()
		static_body.add_to_group("wall")

		var collision_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()

		rect_shape.size = data["size"]
		collision_shape.shape = rect_shape

		static_body.position = data["pos"]
		static_body.add_child(collision_shape)

		add_child(static_body)


# ==================================================
# FOOD SYSTEM
# ==================================================

func initiate_food() -> void:

	if food_scene == null:
		return

	for i in range(amount_of_food):
		spawn_single_food()


func spawn_single_food() -> void:

	var spawn_pos = Vector2.ZERO
	var safe = false
	var attempts = 0
	var max_attempts = 10

	while not safe and attempts < max_attempts:

		var random_x = randf_range(
			-map_bounds.x / 2,
			map_bounds.x / 2
		)

		var random_y = randf_range(
			-map_bounds.y / 2,
			map_bounds.y / 2
		)

		spawn_pos = Vector2(random_x, random_y)

		if not SpatialGrid.has_body_near(spawn_pos, 60.0):
			safe = true

		attempts += 1

	var new_food = food_scene.instantiate()
	new_food.global_position = spawn_pos

	add_child(new_food)


# ==================================================
# PLAYER SYSTEM
# ==================================================

func initiate_player() -> void:

	if player_scene != null:

		var player = player_scene.instantiate()

		add_child(player)
		register_new_snake(player)


# ==================================================
# AI ENEMY SYSTEM
# ==================================================

func initiate_enemy() -> void:

	if ai_scene == null:
		return

	for i in range(amount_of_enemies):

		var ai_snake = ai_scene.instantiate()

		add_child(ai_snake)
		register_new_snake(ai_snake)


# ==================================================
# GLOBAL GAME RESET
# ==================================================

func reset_entire_game() -> void:

	print("Reached 70,000 timesteps! Refreshing the game board...")

	global_timestep = 0

	for snake in active_snakes:

		if is_instance_valid(snake):

			if snake.has_method("die"):

				if "current_reward" in snake:
					snake.current_reward = 0.0

				snake.die()

	var all_food = get_tree().get_nodes_in_group("food")

	for food in all_food:

		if is_instance_valid(food):
			food.queue_free()
