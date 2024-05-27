extends Control

func _on_day_pressed():
	Global.is_day = true
	get_tree().change_scene_to_file("res://Scenes/testing_grounds.tscn")

func _on_night_pressed():
	Global.is_day = false
	get_tree().change_scene_to_file("res://Scenes/testing_grounds.tscn")
