extends Control

func _on_Main_score_updated(score):
	$Score.text = "Mayhem: %s" % score
