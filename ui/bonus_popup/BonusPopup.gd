extends Control

func init(score_text, description, position):
	rect_position = position
	$VBoxContainer/Description.text = description
	$VBoxContainer/Score.text = score_text
	$AnimationPlayer.play("Popup")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("queue_free")
