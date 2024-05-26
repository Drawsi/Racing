extends StaticBody2D

var rng = RandomNumberGenerator.new()
var intensity = RandomNumberGenerator.new()
var off = RandomNumberGenerator.new()
var speed = RandomNumberGenerator.new()
@onready var shader = preload("res://Scenes/Trees.gdshader")

var tree

func _ready():
	var my_random_number = rng.randi_range(0, 9)
	var inten = intensity.randf_range(1, 5)
	var of = off.randf_range(1, 5)
	var spd = speed.randf_range(2, 8)

	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("x_intensity",inten)
	shader_material.set_shader_parameter("y_intensity",inten)
	shader_material.set_shader_parameter("offset",of)
	shader_material.set_shader_parameter("speed",spd)
	
	get_child(0).set_visible(false)
	tree = get_child(my_random_number)
	tree.set_visible(true)
	tree.material = shader_material
