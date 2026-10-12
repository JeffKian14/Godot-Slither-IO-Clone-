#extends "res://Slither_clean/snake_base.gd"
#
#var skin_color : Color
#var current_target : Node2D = null
#
#func _ready() -> void:
	#add_to_group("enemy")
	#super._ready()
#
#func _on_spawn() -> void:
	#skin_color = Color.from_hsv(randf(), 0.8, 1.0)
	#if has_node("Sprite2D"):
		#$Sprite2D.modulate = skin_color
	#pick_new_target()
#
#func _on_grow() -> void:
	## Color the new tail segment
	#if segments.size() > 0:
		#segments[-1].get_node("Sprite2D").modulate = skin_color
#
#func _process(_delta: float) -> void:
	#if not is_instance_valid(current_target):
		#pick_new_target()
		#
	#if is_instance_valid(current_target):
		#var target_angle = global_position.direction_to(current_target.global_position).angle()
		#var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		#turn_input = clamp(angle_diff * 5.0, -1.0, 1.0)
		#
		## Example logic: boost if we are close to food
		#if global_position.distance_to(current_target.global_position) < 200.0:
			#boost_input = true
		#else:
			#boost_input = false
#
#func pick_new_target() -> void:
	#var all_food = get_tree().get_nodes_in_group("food")
	#if all_food.size() > 0:
		#current_target = all_food[randi() % all_food.size()]
	#else:
		#current_target = null
#last test
extends "res://Slither_clean/snake_base.gd"

var current_target : Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	super._ready()

func _on_spawn() -> void:
	# 1. Pick a random bright color for the inner body
	skin_color = Color.from_hsv(randf(), 0.8, 0.5)
	
	# 2. Automatically generate a darker version of that color for the outline
	outline_color = skin_color.darkened(0.4) 
	
	pick_new_target()

func _on_grow() -> void:
	pass

func _process(_delta: float) -> void:
	if not is_instance_valid(current_target):
		pick_new_target()
		
	if is_instance_valid(current_target):
		var target_angle = global_position.direction_to(current_target.global_position).angle()
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		turn_input = clamp(angle_diff * 5.0, -1.0, 1.0)
		
		if global_position.distance_to(current_target.global_position) < 200.0:
			boost_input = true
		else:
			boost_input = false

func pick_new_target() -> void:
	var all_food = get_tree().get_nodes_in_group("food")
	if all_food.size() > 0:
		current_target = all_food[randi() % all_food.size()]
	else:
		current_target = null
