extends Control

func init(score_text, position):
	rect_position = position
	$VBoxContainer/Score.text = score_text
	$AnimationPlayer.play("Popup")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("queue_free")
