#extends AIController2D
#
#@onready var snake = $".." # Gets the parent AIAgent node
#
## 1. Define the Action Space
#func get_action_space() -> Dictionary:
	#return {
		#"turn_action": { "size": 1, "action_type": "continuous" }, # -1.0 to 1.0
		#"boost_action": { "size": 1, "action_type": "discrete" }   # 0 (off) or 1 (on)
	#}
#
## 2. Receive the Action from Python
## 2. Receive the Action from Python
#func set_action(action) -> void:
	## Handle turn action (checking if Python sent an array or a raw float)
	#if typeof(action["turn_action"]) == TYPE_ARRAY:
		#snake.turn_input = clamp(action["turn_action"][0], -1.0, 1.0)
	#else:
		#snake.turn_input = clamp(action["turn_action"], -1.0, 1.0)
	#
	## Handle boost action
	#if typeof(action["boost_action"]) == TYPE_ARRAY:
		#snake.boost_input = int(action["boost_action"][0]) == 1
	#else:
		#snake.boost_input = int(action["boost_action"]) == 1
#
## 3. Define the Observation Space
#func get_obs() -> Dictionary:
	#var obs : Array[float] = []
	#
	## Self Information
	#obs.append(snake.speed / snake.boost_speed)
	#obs.append(snake.segments.size() / 100.0) 
	#
	## Target Information
	#var nearest_food = snake.get_nearest_food()
	#if nearest_food != null:
		#var distance = snake.global_position.distance_to(nearest_food.global_position)
		#var direction = snake.global_position.direction_to(nearest_food.global_position)
		#
		#obs.append(distance / 1000.0)
		#obs.append(direction.x)
		#obs.append(direction.y)
	#else:
		#obs.append(0.0)
		#obs.append(0.0)
		#obs.append(0.0)
	#
	#return { "obs": obs }
#
## 4. Return the Reward
#func get_reward() -> float:
	#var reward_to_send = snake.current_reward
	#snake.current_reward = 0.0 # Reset after sending
	#return reward_to_send
#
## 5. Tell Python if the episode is over
#func get_done() -> bool:
	#return snake.is_done
#
## 6. Reset the AI environment
#func set_done_false() -> void:
	#snake.is_done = false
	
extends AIController2D

@onready var snake = $".." # Gets the parent AIAgent node

# 1. Define the Action Space
func get_action_space() -> Dictionary:
	return {
		"turn_action": { "size": 1, "action_type": "continuous" }, # -1.0 to 1.0
		"boost_action": { "size": 1, "action_type": "discrete" }   # 0 (off) or 1 (on)
	}

# 2. Receive the Action from Python
func set_action(action) -> void:
	# Handle turn action
	if typeof(action["turn_action"]) == TYPE_ARRAY:
		snake.turn_input = clamp(action["turn_action"][0], -1.0, 1.0)
	else:
		snake.turn_input = clamp(action["turn_action"], -1.0, 1.0)
	
	# Temporarily force boost off so the AI learns to steer and avoid danger first.
	if typeof(action["boost_action"]) == TYPE_ARRAY:
		snake.boost_input = int(action["boost_action"][0]) == 1
	else:
		snake.boost_input = int(action["boost_action"]) == 1 

# 3. Define the Observation Space
func get_obs() -> Dictionary:
	# We delegate this entirely to the agent script now to keep all perception logic together
	return snake.get_obs()

# 4. Return the Reward
func get_reward() -> float:
	var reward_to_send = snake.current_reward
	snake.current_reward = 0.0 # Reset after sending
	return reward_to_send

# 5. Tell Python if the episode is over
func get_done() -> bool:
	return snake.is_done

# 6. Reset the AI environment
func set_done_false() -> void:
	snake.is_done = false
