extends Node2D

var slide_length = 100

func _ready():
	visible = false

func death_animation(sliced : bool, right_slide : bool):
	visible = true
	var start_pos = $Body.position
	var end_pos = $Body.position
	if right_slide:
		end_pos.x += slide_length
		# flip animation
		$Body.scale = Vector2(-1, 1)
	else:
		end_pos.x -= slide_length

	if sliced:
		$AnimationPlayer.play("sliced")
	else:
		$AnimationPlayer.play("roasted")
	$Tween.interpolate_property($Body, "position", start_pos, end_pos, 2,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	get_tree().change_scene('res://levels/GameOver.tscn')

