extends Area2D

# We will set this when the head spawns the segment
var snake_owner : Node2D = null

func _ready():
	# Crucial: Make sure it's in the group so sensors can see it!
	add_to_group("body_segment")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 1. Ensure the thing that hit us is actually a snake head
	if not body.is_in_group("snake"):
		return
		
	# 2. Check if the body hitting us is our own head
	if body == snake_owner:
		return # Do nothing, let our own head pass through safely!
		
	# 3. If an ENEMY hits us, process the kill!
	if body.has_method("die"):
		print("CRASH: ", body.name, " hit a body segment belonging to ", snake_owner.name if snake_owner else "Nobody")
		
		# Give the reward to our owner
		if snake_owner != null and snake_owner.has_method("reward_for_kill"):
			# Pass the dying snake's size to the killer
			snake_owner.reward_for_kill(body.segments.size())
			print("KILL REGISTERED: ", snake_owner.name, " killed ", body.name, "!")
			
		# Finally, execute the enemy
		body.call_deferred("die")
