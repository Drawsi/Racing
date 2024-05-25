extends Line2D

var mid_point = true

'''
func _ready():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$StaticBody2D2.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, 20)
		new_shape.shape = rect
	$StaticBody2D2.scale = Vector2(1,1)
'''

func _on_start_body_entered(body):
	if body.is_in_group("Player") and mid_point == true:
		Global.laps -= 1
	mid_point = false
	if Global.laps < 1: 
		Global.finished = true

func _on_mid_body_entered(body):
	if body.is_in_group("Player"):
		mid_point = true
