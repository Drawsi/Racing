extends Node2D

func _process(_delta):
	modulate.a = $Timer.get_time_left() / $Timer.get_wait_time()


func _on_timer_timeout():
	queue_free()
