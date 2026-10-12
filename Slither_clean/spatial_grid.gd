extends Node

const CELL_SIZE = 400.0 # Adjust based on your max snake size
var grid: Dictionary = {}

func clear_grid() -> void:
	# Clear the arrays inside the dictionary instead of discarding them
	# to minimize garbage collection overhead.
	for key in grid:
		grid[key].clear()

func register_body_point(snake: Node2D, pos: Vector2, radius: float) -> void:
	var cell_x = int(floor(pos.x / CELL_SIZE))
	var cell_y = int(floor(pos.y / CELL_SIZE))
	var key = Vector2i(cell_x, cell_y)
	
	if not grid.has(key):
		grid[key] = []
		
	# Save the pre-calculated radius directly into the dictionary!
	grid[key].append({"snake": snake, "pos": pos, "radius": radius})

# ZERO-ALLOCATION COLLISION CHECK
func check_fatal_collision(head_pos: Vector2, my_radius: float, me: Node2D) -> Node2D:
	var cell_x = int(floor(head_pos.x / CELL_SIZE))
	var cell_y = int(floor(head_pos.y / CELL_SIZE))
	
	for cx in range(cell_x - 1, cell_x + 2):
		for cy in range(cell_y - 1, cell_y + 2):
			var key = Vector2i(cx, cy)
			if grid.has(key):
				var contents = grid[key]
				
				# Iterate without creating temporary arrays
				for item in contents:
					var enemy = item["snake"]
					if enemy == me:
						continue # Don't collide with self
						
					var dist_sq = head_pos.distance_squared_to(item["pos"])
					
					# Read the enemy's radius directly from the dictionary (ultra fast)
					var combined_radius = my_radius + item["radius"]
					
					# Check if they are overlapping
					if dist_sq < combined_radius * combined_radius:
						return enemy # Return the killer
	return null

# SECTOR-BASED AI OBSERVATION
func get_sector_observations(head_pos: Vector2, head_rotation: float, view_distance: float, me: Node2D, num_sectors: int = 16) -> Array[float]:
	var sector_distances : Array[float] = []
	for i in range(num_sectors):
		sector_distances.append(1.0) # Default to 1.0 (no enemy in sight)
		
	var cell_x = int(floor(head_pos.x / CELL_SIZE))
	var cell_y = int(floor(head_pos.y / CELL_SIZE))
	
	var grid_radius = int(ceil(view_distance / CELL_SIZE))
	var view_distance_sq = view_distance * view_distance
	
	for cx in range(cell_x - grid_radius, cell_x + grid_radius + 1):
		for cy in range(cell_y - grid_radius, cell_y + grid_radius + 1):
			var key = Vector2i(cx, cy)
			if grid.has(key):
				for item in grid[key]:
					var enemy = item["snake"]
					if enemy == me:
						continue
						
					var to_enemy = item["pos"] - head_pos
					var dist_sq = to_enemy.length_squared()
					
					if dist_sq < view_distance_sq:
						# Calculate relative angle
						var angle = wrapf(to_enemy.angle() - head_rotation, -PI, PI)
						# Map angle to the new dynamic sector count
						var sector_index = int(floor((angle + PI) / (TAU / num_sectors))) % num_sectors
						
						var normalized_dist = sqrt(dist_sq) / view_distance
						if normalized_dist < sector_distances[sector_index]:
							sector_distances[sector_index] = normalized_dist
							
	return sector_distances

# Checks if a specific position overlaps with any snake bodies
func has_body_near(pos: Vector2, clearance_radius: float) -> bool:
	var cell_x = int(floor(pos.x / CELL_SIZE))
	var cell_y = int(floor(pos.y / CELL_SIZE))
	var radius_sq = clearance_radius * clearance_radius
	
	# Check the cell and its 8 neighbors
	for cx in range(cell_x - 1, cell_x + 2):
		for cy in range(cell_y - 1, cell_y + 2):
			var key = Vector2i(cx, cy)
			if grid.has(key):
				for item in grid[key]:
					# If the food spawn point is too close to a body point, reject it
					if pos.distance_squared_to(item["pos"]) < radius_sq:
						return true
	return false
