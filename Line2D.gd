extends Line2D

@export var MAX_LENGTH : int
var point

func _process(_delta):
	point = get_parent().global_position
	add_point(point)
	if points.size() > MAX_LENGTH:
		remove_point(0)
		


func _on_timer_timeout():
	queue_free()

