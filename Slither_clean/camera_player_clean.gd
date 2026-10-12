extends Camera2D

@export var zoom_speed : float = 5.0
@export var min_zoom : float = 0.3

var target_zoom : Vector2 = Vector2(1.0, 1.0)

func _ready() -> void:
	target_zoom = zoom

func _process(delta: float) -> void:
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)

func zoom_in(amount: float) -> void:
	target_zoom += Vector2(amount, amount)

func zoom_out(amount: float) -> void:
	var new_x = max(target_zoom.x - amount, min_zoom)
	var new_y = max(target_zoom.y - amount, min_zoom)
	target_zoom = Vector2(new_x, new_y)

func reset_zoom(new_zoom: Vector2) -> void:
	target_zoom = new_zoom
	zoom = new_zoom
