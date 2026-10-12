#extends Node2D
#
#@export var food_scene : PackedScene
#@export var player_scene : PackedScene
#@export var enemy_scene : PackedScene
#
#@export var ai_scene : PackedScene
#
#@export var map_bounds : Vector2 = Vector2(5000, 5000)
#@export var amount_of_food : int = 1500
#@export var amount_of_enemies : int = 3
#
#func _ready() -> void:
	#create_world_border()
	#initiate_player()
	#initiate_food()
	#initiate_enemy()
#
#func create_world_border() -> void:
	#var thickness = 200
	#var wall_data = [
		#{"pos": Vector2(0, -map_bounds.y/2 - thickness/2), "size": Vector2(map_bounds.x + thickness*2, thickness)}, # Top
		#{"pos": Vector2(0, map_bounds.y/2 + thickness/2), "size": Vector2(map_bounds.x + thickness*2, thickness)},  # Bottom
		#{"pos": Vector2(-map_bounds.x/2 - thickness/2, 0), "size": Vector2(thickness, map_bounds.y)},               # Left
		#{"pos": Vector2(map_bounds.x/2 + thickness/2, 0), "size": Vector2(thickness, map_bounds.y)}                 # Right
	#]
	#
	#for data in wall_data:
		#var static_body = StaticBody2D.new()
		#
		## CRITICAL FIX: Add the dynamically generated walls to the "wall" group!
		#static_body.add_to_group("wall")
		#
		#var collision_shape = CollisionShape2D.new()
		#var rect_shape = RectangleShape2D.new()
		#rect_shape.size = data["size"]
		#collision_shape.shape = rect_shape
		#
		#static_body.position = data["pos"]
		#static_body.add_child(collision_shape)
		#add_child(static_body)
#
#func initiate_food() -> void:
	#if food_scene == null:
		#push_error("Assign Food Scene in Inspector!")
		#return
		#
	#for i in range(amount_of_food):
		#spawn_single_food()
#
#func spawn_single_food() -> void:
	#var random_x = randf_range(-map_bounds.x / 2, map_bounds.x / 2)
	#var random_y = randf_range(-map_bounds.y / 2, map_bounds.y / 2)
	#var spawn_pos = Vector2(random_x, random_y)
	#
	#var new_food = food_scene.instantiate()
	#new_food.global_position = spawn_pos
	#new_food.tree_exited.connect(func(): if is_inside_tree(): call_deferred("spawn_single_food"))
	#add_child(new_food)
#
#func initiate_player() -> void:
	#if player_scene != null:
		#var player = player_scene.instantiate()
		#add_child(player)
		#
#func initiate_enemy() -> void:
	#if ai_scene == null:
		#push_error("Assign AI Scene in Inspector!")
		#return
#
	#for i in range(amount_of_enemies):
		#var ai_snake = ai_scene.instantiate()
		#print("generating snake")
		#add_child(ai_snake)
		
#last test
extends Node2D

@export var food_scene : PackedScene
@export var player_scene : PackedScene
@export var enemy_scene : PackedScene
@export var ai_scene : PackedScene

@export var map_bounds : Vector2 = Vector2(7000, 7000)
@export var amount_of_food : int = 3000
@export var amount_of_enemies : int = 10


# --- OPTIMIZATION: Cached array for active snakes ---
var active_snakes: Array[Node] = []

# --- GAME RESET VARIABLES ---
var global_timestep : int = 0
var max_timesteps : int = 70000
# ----------------------------------------------------

# --- NEW UI VARIABLES ---
@onready var start_menu: CanvasLayer = $StartMenu
@onready var start_button: Button = $StartMenu/StartButton

var menu_camera: Camera2D

func _ready() -> void:
	create_world_border()
	initiate_food()
	initiate_enemy()
	
	# Connect the start button
	start_button.pressed.connect(_on_start_button_pressed)
	
	# --- SPECTATOR CAMERA SETUP ---
	menu_camera = Camera2D.new()
	menu_camera.global_position = Vector2.ZERO
	# Zoomed out to give a wide view of the center of the map
	menu_camera.zoom = Vector2(0.2, 0.2) 
	add_child(menu_camera)
	
	# Force the game to use this static camera first
	menu_camera.make_current() 

func _on_start_button_pressed() -> void:
	# Hide the menu UI
	start_menu.hide()
	
	# Spawn the player into the game!
	initiate_player()
	
	# Destroy the spectator camera. 
	# Godot will automatically switch to the player's camera!
	if is_instance_valid(menu_camera):
		menu_camera.queue_free()

func _physics_process(_delta: float) -> void:
	# 1. Update the Spatial Grid using the cached array
	SpatialGrid.clear_grid()
	
	for snake in active_snakes:
		if is_instance_valid(snake) and snake.has_method("register_to_grid"):
			snake.register_to_grid()
			
	# 2. The Top-Up Manager
	var current_food_count = get_tree().get_node_count_in_group("food")
	
	if current_food_count < amount_of_food:
		spawn_single_food()

	# 3. GLOBAL TIMESTEP RESET
	global_timestep += 1
	if global_timestep >= max_timesteps:
		reset_entire_game()

# --- ARRAY REGISTRATION METHODS ---
func register_new_snake(snake: Node) -> void:
	if not active_snakes.has(snake):
		active_snakes.append(snake)

func unregister_dead_snake(snake: Node) -> void:
	active_snakes.erase(snake)
# ----------------------------------

func create_world_border() -> void:
	var thickness = 200
	var wall_data = [
		{"pos": Vector2(0, -map_bounds.y/2 - thickness/2), "size": Vector2(map_bounds.x + thickness*2, thickness)},
		{"pos": Vector2(0, map_bounds.y/2 + thickness/2), "size": Vector2(map_bounds.x + thickness*2, thickness)},
		{"pos": Vector2(-map_bounds.x/2 - thickness/2, 0), "size": Vector2(thickness, map_bounds.y)},
		{"pos": Vector2(map_bounds.x/2 + thickness/2, 0), "size": Vector2(thickness, map_bounds.y)}
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

func initiate_food() -> void:
	if food_scene == null: return
	for i in range(amount_of_food):
		spawn_single_food()

func spawn_single_food() -> void:
	var spawn_pos = Vector2.ZERO
	var safe = false
	var attempts = 0
	var max_attempts = 10 
	
	while not safe and attempts < max_attempts:
		var random_x = randf_range(-map_bounds.x / 2, map_bounds.x / 2)
		var random_y = randf_range(-map_bounds.y / 2, map_bounds.y / 2)
		spawn_pos = Vector2(random_x, random_y)
		
		if not SpatialGrid.has_body_near(spawn_pos, 60.0):
			safe = true
			
		attempts += 1
	
	var new_food = food_scene.instantiate()
	new_food.global_position = spawn_pos
	add_child(new_food)

func initiate_player() -> void:
	if player_scene != null:
		var player = player_scene.instantiate()
		add_child(player)
		register_new_snake(player)
		
func initiate_enemy() -> void:
	if ai_scene == null: return
	for i in range(amount_of_enemies):
		var ai_snake = ai_scene.instantiate()
		add_child(ai_snake)
		register_new_snake(ai_snake)

# --- RESET FUNCTION ---
func reset_entire_game() -> void:
	print("Reached 70,000 timesteps! Refreshing the game board...")
	global_timestep = 0 
	
	for snake in active_snakes:
		if is_instance_valid(snake) and snake.has_method("die"):
			if "current_reward" in snake:
				snake.current_reward = 0.0 
			snake.die()
	
	var all_food = get_tree().get_nodes_in_group("food")
	for food in all_food:
		if is_instance_valid(food):
			food.queue_free()
