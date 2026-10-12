extends Area2D

func _ready():
	add_to_group("food")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Checks if it is a head, AND if it belongs to a valid snake type
	if body.is_in_group("head") and (body.is_in_group("ai") or body.is_in_group("enemy") or body.is_in_group("player")):
		body.grow()
		queue_free()
