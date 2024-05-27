extends Node2D

var img1 = preload("res://Images/1.png")
var img2 = preload("res://Images/2.png")
var img3 = preload("res://Images/3.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Driver.set_physics_process(false)
	$Enemy.set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.finished == false:
		$CanvasLayer/Lost.visible = true
		$CanvasLayer/Lap.visible = false
	elif Global.finished == true:
		$CanvasLayer/Anim.play("win")
		$CanvasLayer/Lap.visible = false
		Global.finished = null
	
	match Global.laps:
		3: $CanvasLayer/Lap/Change.texture = img1
		2: $CanvasLayer/Lap/Change.texture = img2
		1: $CanvasLayer/Lap/Change.texture = img3
	
	$CanvasLayer/Fps.set_text(str(Engine.get_frames_per_second()))
	
func _on_timer_timeout():
	$Driver.set_physics_process(true)
	$Enemy.set_physics_process(true)
	$AudioStreamPlayer.play()

func _on_retry_pressed():
	get_tree().reload_current_scene() 

func _on_menu_pressed():
	get_tree().change_scene("res://Scenes/enter.tscn")
