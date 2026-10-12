#extends "res://Slither_clean/snake_base.gd"
#
## ---------------------------------------------------------
## VARIABLES
## ---------------------------------------------------------
#
## RL Variables
#var current_reward : float = 0.0
#var is_done : bool = false
#var previous_enemy_distance : float = -1.0 
#var kills_this_life : int = 0 # Tracks if the AI is hunting
#
## Raycast variables
#var num_rays : int = 8
#var ray_length : float = 900.0
#var rays : Array[RayCast2D] = []
#
## Throttling & Caching variables
#var physics_frame_count : int = 0
#var ray_update_frequency : int = 10
#var cached_ray_obs : Array[float] = []
#
## Perception Nodes & Caching
#@onready var food_detector: Area2D = $FoodDetector
#var cached_nearest_enemy: Node2D = null
#
## ---------------------------------------------------------
## INITIALIZATION
## ---------------------------------------------------------
#
#func _ready() -> void:
	#add_to_group("ai")
	#_setup_raycasts()
	#_update_ray_cache()
	#super._ready()
#
## Wipe the kill tracker clean every time the RL environment resets the snake
#func _on_spawn() -> void:
	#kills_this_life = 0
	#previous_enemy_distance = -1.0
#
#func _setup_raycasts() -> void:
	#for i in range(num_rays):
		#var ray = RayCast2D.new()
		#var angle = (TAU / num_rays) * i
		#ray.target_position = Vector2(cos(angle), sin(angle)) * ray_length
		#ray.collide_with_areas = true 
		#ray.collide_with_bodies = true
		#ray.enabled = false # Manual updates only to save CPU
		#
		#add_child(ray)
		#rays.append(ray)
#
## ---------------------------------------------------------
## GAMEPLAY EVENTS (The Gladiator Economy)
## ---------------------------------------------------------
#
#func _on_grow() -> void:
	#current_reward += 0.5 
	#
	## Updated to cap at 200 segments!
	#if segments.size() >= 150:
		#if kills_this_life > 0:
			## Ultimate victory: Max size + Secured a kill
			#current_reward += 100.0 
			#is_done = true 
			#print(name, " killed someone and reached max size! Reward: ", current_reward)
			#die()
		#else:
			## Reached max size but hasn't killed anyone. Do nothing. 
			## The time penalty will drain its score until it hunts!
			#pass
	#
#func die() -> void:
	## Massive penalty so it fears death and prioritizes survival
	#current_reward -= 100.0
	#is_done = true
	#print(name," dead, current reward:", current_reward)
	#super.die()
#
#func reward_for_kill(victim_size: int) -> void:
	#kills_this_life += 1 # Log the kill!
	#current_reward += 50.0 
	#print("killed")
	#if victim_size > segments.size():
		#current_reward += 30.0
#
## ---------------------------------------------------------
## OPTIMIZED PERCEPTION HELPERS
## ---------------------------------------------------------
#
## Single pass to extract BOTH nearest food and quadrant densities
#func _get_food_perception() -> Dictionary:
	#var food_counts = [0.0, 0.0, 0.0, 0.0] # [Front, Right, Back, Left]
	#var nearest_food: Node2D = null
	#var min_dist_sq = INF 
	#
	## Only checks food items within the 600px FoodDetector Area2D!
	#var nearby_areas = food_detector.get_overlapping_areas()
	#
	#for area in nearby_areas:
		#if not area.is_in_group("food"):
			#continue
			#
		#var food_pos = area.global_position
		#var dist_sq = global_position.distance_squared_to(food_pos)
		#
		## Track nearest food
		#if dist_sq < min_dist_sq:
			#min_dist_sq = dist_sq
			#nearest_food = area
			#
		## Track densities
		#var local_pos = to_local(food_pos)
		#if abs(local_pos.x) < abs(local_pos.y):
			#if local_pos.y < 0:
				#food_counts[0] += 1.0 # Front 
			#else:
				#food_counts[2] += 1.0 # Back
		#else:
			#if local_pos.x > 0:
				#food_counts[1] += 1.0 # Right
			#else:
				#food_counts[3] += 1.0 # Left
#
	#for i in range(4):
		#food_counts[i] = clamp(food_counts[i] / 20.0, 0.0, 1.0)
#
	#return {
		#"nearest": nearest_food,
		#"densities": food_counts
	#}
#
#func _update_nearest_enemy_cache() -> void:
	#var all_enemies = get_tree().get_nodes_in_group("ai")
	#var closest: Node2D = null
	#var min_dist_sq = INF
	#
	#for enemy in all_enemies:
		#if enemy != self and is_instance_valid(enemy):
			#var dist_sq = global_position.distance_squared_to(enemy.global_position)
			#if dist_sq < min_dist_sq:
				#min_dist_sq = dist_sq
				#closest = enemy
				#
	#cached_nearest_enemy = closest
#
#func _update_ray_cache() -> void:
	#cached_ray_obs.clear() 
	#
	#for ray in rays:
		#ray.force_raycast_update()
		#
		#var dist_food = 1.0
		#var dist_enemy = 1.0
		#var dist_wall = 1.0
		#
		#if ray.is_colliding():
			#var collider = ray.get_collider()
			#var dist = clamp(ray.get_collision_point().distance_to(global_position) / ray_length, 0.0, 1.0)
			#
			#if collider.is_in_group("food"):
				#dist_food = dist
			#elif collider.is_in_group("body_segment") or collider.is_in_group("head") or collider.is_in_group("snake"):
				#if not ("snake_owner" in collider and collider.snake_owner == self) and collider != self:
					#dist_enemy = dist
			#elif collider.is_in_group("wall"):
				#dist_wall = dist
				#
		#cached_ray_obs.append(dist_food)
		#cached_ray_obs.append(dist_enemy)
		#cached_ray_obs.append(dist_wall)
#
## ---------------------------------------------------------
## UNIFIED OBSERVATION SPACE (39 Values)
## ---------------------------------------------------------
#
#func get_obs() -> Dictionary:
	#var obs : Array[float] = []
	#
	## 1. Self State (2)
	#obs.append(speed / boost_speed)
	#obs.append(segments.size() / 100.0)
	#
	## 2. Heading/Orientation (2)
	#obs.append(cos(rotation))
	#obs.append(sin(rotation))
	#
	## 3 & 5. Food Perception (Combined pass)
	#var food_data = _get_food_perception()
	#var nearest_food = food_data["nearest"]
	#
	#if nearest_food != null and is_instance_valid(nearest_food):
		#var local_food = to_local(nearest_food.global_position)
		#obs.append(clamp(local_food.length() / 1000.0, 0.0, 1.0))
		#obs.append(clamp(local_food.x / 1000.0, -1.0, 1.0))
		#obs.append(clamp(local_food.y / 1000.0, -1.0, 1.0))
	#else:
		#obs.append(1.0)
		#obs.append(0.0)
		#obs.append(0.0)
#
	## 4. Nearest Enemy Tracking (4)
	#if cached_nearest_enemy != null and is_instance_valid(cached_nearest_enemy):
		#var local_enemy = to_local(cached_nearest_enemy.global_position)
		#obs.append(clamp(local_enemy.length() / 1000.0, 0.0, 1.0))
		#obs.append(clamp(local_enemy.x / 1000.0, -1.0, 1.0))
		#obs.append(clamp(local_enemy.y / 1000.0, -1.0, 1.0))
		#obs.append(clamp(cached_nearest_enemy.segments.size() / 150.0, 0.0, 1.0))
	#else:
		#obs.append(1.0)
		#obs.append(0.0)
		#obs.append(0.0)
		#obs.append(0.0)
		#
	## 5. Food Density (4)
	#obs.append_array(food_data["densities"])
	#
	## 6. Raycasts (24)
	#obs.append_array(cached_ray_obs)
	#
	#return {"obs": obs}
#
## ---------------------------------------------------------
## PHYSICS & TIME-BASED REWARDS
## ---------------------------------------------------------
#
#func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	#
	## 1. Time penalty (forces action)
	#current_reward -= 0.1
	#
	## 2. Reward for closing distance to the CURRENTLY cached enemy (cheap math)
	#if cached_nearest_enemy == null or not is_instance_valid(cached_nearest_enemy):
		#previous_enemy_distance = -1.0
	#else:
		#var distance = global_position.distance_to(cached_nearest_enemy.global_position)
		#if previous_enemy_distance > 0:
			#if distance < previous_enemy_distance:
				#current_reward += 0.005 
			#else:
				#current_reward -= 0.002 
				#
		#previous_enemy_distance = distance
#
	## 3. Throttled Heavy Updates (Raycasts & searching the scene tree)
	#physics_frame_count += 1
	#if physics_frame_count >= ray_update_frequency:
		#_update_nearest_enemy_cache() # NOW THROTTLED!
		#_update_ray_cache()
		#physics_frame_count = 0
#last test

extends "res://Slither_clean/snake_base.gd"
var frames_since_last_kill : int = 0
# ---------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------
var current_reward : float = 0.0
var is_done : bool = false
var kills_this_life : int = 0 

# Perception Settings
var view_distance : float = 900.0
var cached_sector_obs : Array[float] = []

@onready var food_detector: Area2D = $FoodDetector

# ---------------------------------------------------------
# INITIALIZATION
# ---------------------------------------------------------
func _ready() -> void:
	add_to_group("ai")
	
	# Initialize default sector data
	for i in range(8):
		cached_sector_obs.append(1.0)
		
	super._ready()

func _on_spawn() -> void:
	kills_this_life = 0
	frames_since_last_kill = 0 # Reset timer on spawn
	
	skin_color = Color.from_hsv(randf(), 0.8, 0.6)
	outline_color = skin_color.darkened(0.4)

func reward_for_kill(victim_size: int) -> void:
	kills_this_life += 1 
	frames_since_last_kill = 0 # Reset timer upon successful hunt!
	current_reward += 50.0 
	if victim_size > target_length:
		current_reward += 30.0

# --- Update your physics process ---
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	current_reward -= 0.1 # Standard time penalty
	
	# THE 600-FRAME INACTIVITY RULE
	frames_since_last_kill += 1
	if frames_since_last_kill >= 2000 and target_length > 150:
		frames_since_last_kill = 0 # Reset so it has another 600 frames to try again
		
		# Give a massive RL penalty for cowardice
		current_reward -= 50.0 
		halve_size()
		print(name, " was penalized for inactivity! Size cut in half.")
# ---------------------------------------------------------
# GAMEPLAY EVENTS
# ---------------------------------------------------------
func _on_grow() -> void:
	current_reward += 0.5 
	if target_length >= 150:
		if kills_this_life > 0:
			current_reward += 100.0 
			is_done = true 
			print(name, " win")
			die()
	
func die() -> void:
	current_reward -= 100.0
	is_done = true
	super.die()


# ---------------------------------------------------------
# OPTIMIZED PERCEPTION HELPERS
# ---------------------------------------------------------
func _get_food_perception() -> Dictionary:
	var food_counts = [0.0, 0.0, 0.0, 0.0] 
	var nearest_food: Node2D = null
	var min_dist_sq = INF 
	
	var nearby_areas = food_detector.get_overlapping_areas()
	
	for area in nearby_areas:
		if not area.is_in_group("food"):
			continue
			
		var food_pos = area.global_position
		var dist_sq = global_position.distance_squared_to(food_pos)
		
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_food = area
			
		var local_pos = to_local(food_pos)
		if abs(local_pos.x) < abs(local_pos.y):
			if local_pos.y < 0:
				food_counts[0] += 1.0 # Front 
			else:
				food_counts[2] += 1.0 # Back
		else:
			if local_pos.x > 0:
				food_counts[1] += 1.0 # Right
			else:
				food_counts[3] += 1.0 # Left

	for i in range(4):
		food_counts[i] = clamp(food_counts[i] / 20.0, 0.0, 1.0)

	return {
		"nearest": nearest_food,
		"densities": food_counts
	}

# ---------------------------------------------------------
# UNIFIED OBSERVATION SPACE
# ---------------------------------------------------------
func get_obs() -> Dictionary:
	var obs : Array[float] = []
	
	# 1. Self State (2)
	obs.append(speed / max_boost_speed)
	obs.append(target_length / 100.0)
	
	# 2. Heading/Orientation (2)
	obs.append(cos(rotation))
	obs.append(sin(rotation))
	
	# 3. Food Perception
	var food_data = _get_food_perception()
	var nearest_food = food_data["nearest"]
	
	if nearest_food != null and is_instance_valid(nearest_food):
		var local_food = to_local(nearest_food.global_position)
		obs.append(clamp(local_food.length() / 1000.0, 0.0, 1.0))
		obs.append(clamp(local_food.x / 1000.0, -1.0, 1.0))
		obs.append(clamp(local_food.y / 1000.0, -1.0, 1.0))
	else:
		obs.append(1.0)
		obs.append(0.0)
		obs.append(0.0)
		
	# 4. Food Density (4)
	obs.append_array(food_data["densities"])
	
	# 5. Zero-Allocation Sector Radar (16)
	var sector_data = SpatialGrid.get_sector_observations(global_position, rotation, view_distance, self, 16)
	obs.append_array(sector_data)
	
	return {"obs": obs}

# ---------------------------------------------------------
# PHYSICS
# ---------------------------------------------------------
