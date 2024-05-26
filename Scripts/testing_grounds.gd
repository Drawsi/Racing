extends Node2D
var img1 = preload("res://Images/1.png")
var img2 = preload("res://Images/2.png")
var img3 = preload("res://Images/3.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	$Driver.set_physics_process(false)
	$Enemy.set_physics_process(false)
	#var t = $SubViewport.get_texture()
	#$Screen.get_surface_material(0).albedo_texture = t


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.finished:
		$CanvasLayer/Anim.play("win")
		Global.finished = false
	match Global.laps:
		3: $CanvasLayer/Lap/Change.texture = img1
		2: $CanvasLayer/Lap/Change.texture = img2
		1: $CanvasLayer/Lap/Change.texture = img3
	
	$CanvasLayer/Label.set_text(str(Engine.get_frames_per_second()))
	
func _on_timer_timeout():
	$Driver.set_physics_process(true)
	$Enemy.set_physics_process(true)
