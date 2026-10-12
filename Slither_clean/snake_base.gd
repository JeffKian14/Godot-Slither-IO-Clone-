#extends CharacterBody2D
#class_name SnakeBase
#
## --- Action Space Variables ---
#var turn_input : float = 0.0 # Range: -1.0 (Left) to 1.0 (Right)
#var boost_input : bool = false # True or False
#
## --- Shared Variables ---
#var base_speed = 300.0
#var boost_speed = 450.0
#var speed = base_speed
#
#var shrink_timer : float = 0.0
#var shrink_rate : float = 0.5
#var min_segments : int = 10
#var turn_speed = 8.0
#
#var history : Array[Transform2D] = []
#
#var segments : Array[Node2D] = []
#
#var current_tail_z : int = -1
#var current_snake_scale : float = 1.0
#
#@export var food_scene : PackedScene
#@export var collision_increase_per_food : float = 0.02
#@export var segment_spacing : int = 2
#@export var body_scene : PackedScene
#@export var body_texture : Texture2D
#@export var map_bounds : Vector2 = Vector2(5000, 5000)
#@export var safe_spawn_distance : float = 400.0
#
#func _ready() -> void:
	## Add all snakes to a general group for easy collision checking
	#add_to_group("snake")
	#spawn()
#
#func spawn() -> void:
	#global_position = get_random_spawn_position()
	#current_snake_scale = 1.0
	#scale = Vector2.ONE
	#
	#current_tail_z = -1
	#history.clear()
	#var initial_max_history = (10 * segment_spacing) + segment_spacing
	##for i in range(initial_max_history):
		##history.append(global_position) 
		##change to this code if using model_friendly
	#for i in range(initial_max_history):
		#history.append(global_transform)
	#
	#for i in range(10):
		#grow()
		#
	## Call a virtual function so child scripts can add specific spawn logic (like camera resets)
	#_on_spawn()
#
## Virtual function to be overridden by Player/Enemy scripts
#func _on_spawn() -> void:
	#pass
#
#func get_random_spawn_position() -> Vector2:
	#var pos = Vector2.ZERO
	#while true:
		#pos = Vector2(
			#randf_range(-map_bounds.x / 2.5, map_bounds.x / 2.5),
			#randf_range(-map_bounds.y / 2.5, map_bounds.y / 2.5)
		#)
		#if prevent_collision(pos):
			#break
	#return pos
#
##func prevent_collision(pos: Vector2) -> bool:
	##var other_snakes = get_tree().get_nodes_in_group("snake")
	##for snake in other_snakes:
		##if snake != self and pos.distance_to(snake.global_position) < safe_spawn_distance:
			##return false
	##return true
##
###func _physics_process(delta: float) -> void:
	#### 1. Apply Turning from Action Space
	###rotation += turn_input * turn_speed * delta
		###
	#### 2. Apply Boosting from Action Space
	###if boost_input and segments.size() > min_segments:
		###speed = boost_speed
		###shrink_timer += delta
		###if shrink_timer >= shrink_rate:
			###shrink_timer = 0.0
			###shrink()
	###else:
		###speed = base_speed
		###shrink_timer = 0.0
		###
	#### 3. Move the Head
	###velocity = Vector2.RIGHT.rotated(rotation) * speed
	###move_and_slide()
###
	#### 4. Update History and Body Segments
	###history.insert(0, global_position)
	###var max_history = (segments.size() * segment_spacing) + segment_spacing
	###if history.size() > max_history:
		###history.pop_back()
		###
	###for i in range(segments.size()):
		###var history_index = (i + 1) * segment_spacing
		###if history_index < history.size():
			###segments[i].global_position = history[history_index]
			###if i == 0:
				###segments[i].look_at(global_position)
			###else:
				###segments[i].look_at(segments[i-1].global_position)
## Change the array type to Transform2D
#
#func prevent_collision(pos: Vector2) -> bool:
	#var other_snakes = get_tree().get_nodes_in_group("snake")
	#
	## Calculate the squared threshold ONCE
	#var safe_dist_sq = safe_spawn_distance * safe_spawn_distance 
	#
	#for snake in other_snakes:
		## Use distance_squared_to instead of distance_to
		#if snake != self and pos.distance_squared_to(snake.global_position) < safe_dist_sq:
			#return false
	#return true
	#
#
#func _physics_process(delta: float) -> void:
	## 1. Apply Turning from Action Space
	#rotation += turn_input * turn_speed * delta
	#
	## 2. Apply Boosting from Action Space
	#if boost_input and segments.size() > min_segments:
		#speed = boost_speed
		#shrink_timer += delta
		#if shrink_timer >= shrink_rate:
			#shrink_timer = 0.0
			#shrink()
	#else:
		#speed = base_speed
		#shrink_timer = 0.0
		#
	## 3. Move the Head
	#velocity = Vector2.RIGHT.rotated(rotation) * speed
	#move_and_slide()
	#
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider != null:
			#_on_head_crash(collider)
#
	## 4. Update History and Body Segments using Transforms
	#history.insert(0, global_transform)
	#
	#var max_history = (segments.size() * segment_spacing) + segment_spacing
	#if history.size() > max_history:
		#history.pop_back()
		#
	#for i in range(segments.size()):
		#var history_index = (i + 1) * segment_spacing
		#if history_index < history.size():
			## Apply position and rotation in one step
			#segments[i].global_transform = history[history_index]
			#
##func grow() -> void:
	##if body_scene == null:
		##return
##
	##current_snake_scale += collision_increase_per_food
	##scale = Vector2(current_snake_scale, current_snake_scale)
		##
	##var new_segment = body_scene.instantiate()
	##new_segment.snake_owner = self
	##new_segment.add_to_group("snake")
	##new_segment.z_index = max(-4096, current_tail_z)
	##current_tail_z -= 1
	##
	##new_segment.global_position = segments[-1].global_position if segments.size() > 0 else global_position
	##get_parent().call_deferred("add_child", new_segment)
	##
	##new_segment.scale = Vector2(current_snake_scale, current_snake_scale)
	##for seg in segments:
		##if is_instance_valid(seg):
			##seg.scale = Vector2(current_snake_scale, current_snake_scale)
	##
	##if body_texture:
		##new_segment.get_node("Sprite2D").texture = body_texture
	##
	##segments.append(new_segment)
	##
	### Call virtual function for child scripts
	##_on_grow()
#func grow() -> void:
	#if body_scene == null:
		#return
#
	## --- NEW HARD CAP LOGIC ---
	#if segments.size() >= 200:
		## The snake is at max size. 
		## Skip physical growth, but still trigger the RL event!
		#_on_grow()
		#return
	## --------------------------
#
	#current_snake_scale += collision_increase_per_food
	#scale = Vector2(current_snake_scale, current_snake_scale)
		#
	#var new_segment = body_scene.instantiate()
	#new_segment.snake_owner = self
	#new_segment.add_to_group("snake")
	#new_segment.z_index = max(-4096, current_tail_z)
	#current_tail_z -= 1
	#
	#new_segment.global_position = segments[-1].global_position if segments.size() > 0 else global_position
	#get_parent().call_deferred("add_child", new_segment)
	#
	#new_segment.scale = Vector2(current_snake_scale, current_snake_scale)
	#for seg in segments:
		#if is_instance_valid(seg):
			#seg.scale = Vector2(current_snake_scale, current_snake_scale)
	#
	#if body_texture:
		#new_segment.get_node("Sprite2D").texture = body_texture
	#
	#segments.append(new_segment)
	#
	## Call virtual function for child scripts
	#_on_grow()
#
#func _on_grow() -> void:
	#pass
#
#func die() -> void:
	#drop_food(true)
	#for seg in segments:
		#if is_instance_valid(seg):
			#seg.call_deferred("queue_free")
	#segments.clear()
	#spawn()
#
#func shrink() -> void:
	#if segments.size() <= min_segments:
		#return
#
	#var tail_segment = segments.pop_back()
	#if is_instance_valid(tail_segment):
		#drop_food(false, tail_segment.global_position)
		#tail_segment.queue_free()
		#current_tail_z += 1
#
	#current_snake_scale = max(1.0, current_snake_scale - collision_increase_per_food)
	#scale = Vector2(current_snake_scale, current_snake_scale)
	#
	#for seg in segments:
		#if is_instance_valid(seg):
			#seg.scale = Vector2(current_snake_scale, current_snake_scale)
			#
	## Call virtual function for child scripts
	#_on_shrink()
#
#func _on_shrink() -> void:
	#pass
#
#func drop_food(from_all_segments: bool, pos: Vector2 = Vector2.ZERO) -> void:
	#if food_scene == null:
		#return
		#
	#var max_scatter = 20.0 * current_snake_scale
	#if from_all_segments:
		#for i in range(0, segments.size(), 2):
			#if is_instance_valid(segments[i]):
				#_instantiate_scattered_food(segments[i].global_position, max_scatter)
	#else:
		#_instantiate_scattered_food(pos, max_scatter)
#
#func _instantiate_scattered_food(spawn_at: Vector2, max_scatter: float) -> void:
	#var dropped_food = food_scene.instantiate()
	#var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, max_scatter)
	#dropped_food.global_position = spawn_at + offset
	#get_parent().call_deferred("add_child", dropped_food)
#
##func _on_head_crash(collided_body) -> void:
	### 1. Debug print to prove the crash is triggering at all
	##print(name, " crashed into: ", collided_body.name)
	##
	### 2. Safely check if the object we hit has a "snake_owner" variable
	##if "snake_owner" in collided_body:
		##var killer_snake = collided_body.snake_owner 
		##
		### 3. Make sure the killer exists, can be rewarded, AND isn't the snake killing itself!
		##if killer_snake and killer_snake.has_method("reward_for_kill") and killer_snake != self:
			##
			##print("SUCCESS: ", killer_snake.name, " killed ", name, "!")
			##killer_snake.reward_for_kill(segments.size())
			##
	##die()
#func _on_head_crash(collided_body) -> void:
	## 1. Ignore non-lethal collisions (like food)
	#if not collided_body.is_in_group("body_segment") and not collided_body.is_in_group("snake"):
		#return
#
	## 2. Grab the owner of the body segment
	#var killer_snake = null
	#if "snake_owner" in collided_body:
		#killer_snake = collided_body.snake_owner
	#elif collided_body.is_in_group("snake"): 
		## If we hit a head directly, the collider IS the killer
		#killer_snake = collided_body
#
	## 3. Process the kill
	#if killer_snake != null:
		## Don't count suicide!
		#if killer_snake == self:
			#die()
			#return
			#
		#print("CRASH: ", self.name, " hit ", collided_body.name)
		#print("KILL REGISTERED: ", killer_snake.name, " killed ", self.name)
		#
		#if killer_snake.has_method("reward_for_kill"):
			#killer_snake.reward_for_kill(segments.size())
			#
	#die()
#last test

extends CharacterBody2D
#class_name SnakeBase

var turn_input : float = 0.0 
var boost_input : bool = false 

var max_base_speed : float = 400.0 
var min_base_speed : float = 300.0 

var max_boost_speed : float = 800.0 
var min_boost_speed : float = 600.0 

var speed : float = 0.0 

var shrink_timer : float = 0.0
var shrink_rate : float = 0.5
var min_segments : int = 10
var max_turn_speed : float = 5.0 # Tight turns when small (approx 230 degrees per sec)
var min_turn_speed : float = 4.0 # Wide, slow turns when huge (approx 85 degrees per sec)

@export var food_scene : PackedScene
@export var collision_increase_per_food : float = 0.02
@export var segment_spacing : int = 2
@export var map_bounds : Vector2 = Vector2(7000, 7000)
@export var safe_spawn_distance : float = 400.0

var current_snake_scale : float = 1.0
var target_length : int = 0
var segment_radius : float = 30.0
var food_energy : int = 0 # NEW: Tracks food eaten before growing

var skin_color : Color = Color(0.61, 0.11, 0.06) 
var outline_color : Color = Color(0.85, 0.25, 0.15)
var outline_thickness : float = 4.0
var render_step : int = 1 

var max_capacity : int = 2500 
var history_positions : PackedVector2Array
var write_index : int = 0
var active_history_points : int = 0

var outline_line: Line2D
var body_line: Line2D

func _ready() -> void:
	add_to_group("snake")
	z_index = 10 
	
	if has_node("CollisionShape2D") and $CollisionShape2D.shape:
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
		_update_hitbox()
	
	history_positions.resize(max_capacity)
	for i in range(max_capacity):
		history_positions[i] = Vector2.ZERO
		
	# --- THE FIX: show_behind_parent = true ---
	outline_line = Line2D.new()
	outline_line.joint_mode = Line2D.LINE_JOINT_ROUND
	outline_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outline_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	outline_line.show_behind_parent = true # Forces the outline behind the eyes
	add_child(outline_line)
	
	body_line = Line2D.new()
	body_line.joint_mode = Line2D.LINE_JOINT_ROUND
	body_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	body_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	body_line.show_behind_parent = true # Forces the body behind the eyes
	add_child(body_line)
	# ------------------------------------------
		
	spawn()

func spawn() -> void:
	global_position = get_random_spawn_position()
	current_snake_scale = 1.0
	target_length = 0
	food_energy = 0 # NEW: Reset energy
	
	# Give the snake a random starting direction
	rotation = randf() * TAU 
	
	write_index = 0
	active_history_points = 0
	
	# Calculate approx how far the snake moves per physics frame (assuming 60 FPS)
	var frame_distance = min_base_speed * (1.0 / 60.0) 
	var backward_direction = Vector2.LEFT.rotated(rotation)
	
	# Populate the history array backwards so it forms a straight line behind the head
	for i in range(max_capacity):
		var past_index = posmod(write_index - i, max_capacity)
		history_positions[past_index] = global_position + (backward_direction * (i * frame_distance))
		
	for i in range(10):
		grow()
		
	_on_spawn()

func _on_spawn() -> void:
	pass

func get_random_spawn_position() -> Vector2:
	var pos = Vector2.ZERO
	var safe = false
	while not safe:
		pos = Vector2(
			randf_range(-map_bounds.x / 2.5, map_bounds.x / 2.5),
			randf_range(-map_bounds.y / 2.5, map_bounds.y / 2.5)
		)
		safe = prevent_collision(pos)
	return pos

func prevent_collision(pos: Vector2) -> bool:
	var other_snakes = get_tree().get_nodes_in_group("snake")
	var safe_dist_sq = safe_spawn_distance * safe_spawn_distance 
	for snake in other_snakes:
		if snake != self and pos.distance_squared_to(snake.global_position) < safe_dist_sq:
			return false
	return true

var wall_contact_timer : float = 0.0
var max_wall_time : float = 0.5

func _physics_process(delta: float) -> void:
	# Calculate how big the snake is (0.0 is tiny, 1.0 is max size)
	var size_ratio = clamp(float(target_length) / 200.0, 0.0, 1.0)
	
	# Interpolate turn speed based on size
	var current_turn_speed = lerp(max_turn_speed, min_turn_speed, size_ratio)
	
	# Apply the new slower turning math
	rotation += turn_input * current_turn_speed * delta
	
	# Interpolate movement speeds based on size
	var current_base = lerp(max_base_speed, min_base_speed, size_ratio)
	var current_boost = lerp(max_boost_speed, min_boost_speed, size_ratio)
	if boost_input and target_length > min_segments:
		speed = current_boost
		shrink_timer += delta
		if shrink_timer >= shrink_rate:
			shrink_timer = 0.0
			shrink()
	else:
		speed = current_base
		shrink_timer = 0.0
		
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()
	
	# --- NEW: WALL DEATH PENALTY ---
	var is_hitting_wall = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider != null and collider.is_in_group("wall"):
			is_hitting_wall = true
			break # Stop checking if we found at least one wall
			
	if is_hitting_wall:
		wall_contact_timer += delta
		if wall_contact_timer >= max_wall_time:
			print("DEATH: ", name, " burned up against the wall!")
			
			# Apply a heavy RL penalty so the AI learns to avoid the borders
			if "current_reward" in self:
				self.current_reward -= 50.0 
				
			die()
			wall_contact_timer = 0.0 # Reset for the next life
	else:
		# The moment they steer away from the wall, reset the timer to zero
		wall_contact_timer = 0.0
	# -------------------------------
	
	write_index = (write_index + 1) % max_capacity
	history_positions[write_index] = global_position
	
	var needed_points = (target_length * segment_spacing) + segment_spacing
	
	# Gradually build history until enough points exist
	if active_history_points < needed_points:
		active_history_points = min(
			active_history_points + 1, 
			needed_points
		)
	
	_update_rendering()
	
	var my_radius = (segment_radius + outline_thickness) * current_snake_scale
	var killer = SpatialGrid.check_fatal_collision(global_position, my_radius, self)
	
	if killer != null:
		if killer.has_method("reward_for_kill"):
			killer.reward_for_kill(target_length)
		die()

func register_to_grid() -> void:
	# Calculate how thick this specific snake's body is
	var my_radius = (segment_radius + outline_thickness) * current_snake_scale
	
	for i in range(target_length):
		var offset = (i + 1) * segment_spacing
		if offset < active_history_points:
			var read_index = posmod(write_index - offset, max_capacity)
			var pos = history_positions[read_index]
			
			# Add 'my_radius' as the third argument!
			SpatialGrid.register_body_point(self, pos, my_radius)

func _update_rendering() -> void:
	var visual_points = PackedVector2Array()
	visual_points.append(Vector2.ZERO)
	
	for i in range(0, target_length, render_step):
		var offset = (i + 1) * segment_spacing
		if offset < active_history_points:
			var read_index = posmod(write_index - offset, max_capacity)
			visual_points.append(to_local(history_positions[read_index]))
			
	outline_line.points = visual_points
	body_line.points = visual_points
	
	var inner_width = (segment_radius * current_snake_scale) * 2.0
	var outer_width = inner_width + ((outline_thickness * current_snake_scale) * 2.0)
	
	body_line.width = inner_width
	outline_line.width = outer_width
	
	body_line.default_color = skin_color
	outline_line.default_color = outline_color
	
	queue_redraw()

func _draw() -> void:
	var head_radius = segment_radius * current_snake_scale
	
	var eye_offset_x = head_radius * 0.4
	var eye_offset_y = head_radius * 0.65
	var eye_radius = head_radius * 0.35
	var pupil_radius = eye_radius * 0.5
	
	draw_circle(Vector2(eye_offset_x, eye_offset_y), eye_radius, Color.WHITE)
	draw_circle(Vector2(eye_offset_x + (eye_radius * 0.3), eye_offset_y), pupil_radius, Color.BLACK)
	
	draw_circle(Vector2(eye_offset_x, -eye_offset_y), eye_radius, Color.WHITE)
	draw_circle(Vector2(eye_offset_x + (eye_radius * 0.3), -eye_offset_y), pupil_radius, Color.BLACK)
func _on_grow() -> void:
	pass
func grow() -> void:
	# Even if at max size, we still call _on_grow() so the RL agent gets its reward for eating!
	if target_length >= 200:
		_on_grow()
		return
	
	# 1. Calculate the required food for the next segment.
	# size_ratio goes from 0.0 (length 0) to 1.0 (length 100+)
	var size_ratio = clamp(float(target_length) / 100.0, 0.0, 1.0)
	
	# Lerp smoothly transitions the requirement from 1 food to 5 food based on the ratio
	var food_needed = int(lerp(1.0, 3.0, size_ratio))
	
	# 2. Add energy for the food just eaten
	food_energy += 1
	
	# 3. Check if we have enough energy to physically grow
	if food_energy >= food_needed:
		# Subtract the required cost (leaving any leftover energy)
		food_energy -= food_needed 
		
		current_snake_scale += collision_increase_per_food
		target_length += 1
		var needed_points = (target_length * segment_spacing) + segment_spacing
		
		if active_history_points < needed_points:
			# Immediately jump the active points forward to match the target length.
			# Because we pre-filled the array in spawn(), these read valid coordinates!
			active_history_points = min(needed_points, max_capacity)
		
		call_deferred("_update_hitbox")
		
	# We call this outside the energy check so the AI gets rewarded for EVERY piece of food eaten,
	# even if it didn't cause a physical growth bump this specific frame.
	_on_grow()

func die() -> void:
	drop_food(true)
	spawn()

func shrink() -> void:
	if target_length <= min_segments:
		return
		
	food_energy = 0 # NEW: Reset energy so they have to start earning the next segment from scratch!
	
	var tail_offset = target_length * segment_spacing
	var tail_pos = global_position
	if tail_offset < active_history_points:
		var read_index = posmod(write_index - tail_offset, max_capacity)
		tail_pos = history_positions[read_index]
		
	drop_food(false, tail_pos)
	
	target_length -= 1
	current_snake_scale = max(1.0, current_snake_scale - collision_increase_per_food)
	
	call_deferred("_update_hitbox")
		
	_on_shrink()

func _on_shrink() -> void:
	pass

func drop_food(from_all_segments: bool, pos: Vector2 = Vector2.ZERO) -> void:
	if food_scene == null: return
	var max_scatter = 20.0 * current_snake_scale
	
	if from_all_segments:
		var max_drops = 120
		var step = max(1, target_length / max_drops)
		
		for i in range(0, target_length, step):
			var offset = (i + 1) * segment_spacing
			if offset < active_history_points:
				var read_index = posmod(write_index - offset, max_capacity)
				_instantiate_scattered_food(history_positions[read_index], max_scatter)
	else:
		_instantiate_scattered_food(pos, max_scatter)

func halve_size() -> void:
	#remove this line if wan to train
	return
	
	if target_length <= min_segments:
		return
		
	var segments_lost = int(target_length / 2.0)
	target_length -= segments_lost
	current_snake_scale = max(1.0, current_snake_scale - (segments_lost * collision_increase_per_food))
	
	call_deferred("_update_hitbox")
		
	_on_shrink()

func _update_hitbox() -> void:
	# 1. Check if the node exists exactly where we expect it
	if not has_node("CollisionShape2D"):
		print("ERROR on ", name, ": Cannot find a direct child node named 'CollisionShape2D'!")
		return
		
	var col_shape = $CollisionShape2D
	
	# 2. Check if the shape is actually a circle
	if not col_shape.shape is CircleShape2D:
		print("ERROR on ", name, ": The CollisionShape2D is NOT a CircleShape2D!")
		return
		
	# If it passes both checks, apply the new size
	col_shape.shape.radius = (segment_radius + outline_thickness) * current_snake_scale				

func _instantiate_scattered_food(spawn_at: Vector2, max_scatter: float) -> void:
	var dropped_food = food_scene.instantiate()
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, max_scatter)
	dropped_food.global_position = spawn_at + offset
	get_parent().call_deferred("add_child", dropped_food)
