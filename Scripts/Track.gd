extends Line2D

var mid_point = true

func _ready():
	if Global.is_day:
		$Darken.visible = false
		$LightPosts.visible = false
		$Birds.playing = true
		$Birds2.playing = true
	else:
		$Darken.visible = true
		$LightPosts.visible = true
		$Birds.playing = false
		$Birds2.playing = false

func _on_start_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered start area.")
		if Global.laps < 1:
			Global.finished = true
			print("Player finished the race. Global.finished set to true.")
		elif mid_point:
			Global.laps -= 1
			mid_point = false
			print("Lap decremented. Remaining laps: %d" % Global.laps)
	elif body.is_in_group("Bots"):
		print("Bot entered start area.")
		if Global.laps < 1:
			Global.finished = false
			print("Bot finished the race. Global.finished set to false.")

func _on_mid_body_entered(body):
	if body.is_in_group("Player"):
		mid_point = true
		print("Midpoint reached. mid_point set to true.")
