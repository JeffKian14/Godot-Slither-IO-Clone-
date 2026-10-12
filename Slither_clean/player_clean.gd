extends "res://Slither_clean/snake_base.gd"

func _ready() -> void:
	add_to_group("player")
	if has_node("Camera2D"):
		$Camera2D.make_current()
		
	super._ready()

func _process(_delta: float) -> void:
	# Calculate turn_input based on mouse position
	var mouse_pos = get_local_mouse_position()
	if mouse_pos.length() > 20.0:
		var target_angle = global_position.direction_to(get_global_mouse_position()).angle()
		# Convert the angle difference into a -1 to 1 steering value
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		turn_input = clamp(angle_diff * 5.0, -1.0, 1.0)
	else:
		turn_input = 0.0
		
	# Check for boosting
	boost_input = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

# Override virtual functions for camera logic
func _on_spawn() -> void:
	if has_node("Camera2D") and $Camera2D.has_method("reset_zoom"):
		$Camera2D.reset_zoom(Vector2(0.7, 0.7))

func _on_grow() -> void:
	if has_node("Camera2D"):
		$Camera2D.zoom_out(0.01)

func _on_shrink() -> void:
	if has_node("Camera2D") and $Camera2D.has_method("zoom_in"):
		$Camera2D.zoom_in(0.01)
