extends Node2D

func _process(_delta):
	if Input.is_action_pressed('restart'):
		get_tree().change_scene('res://levels/Main.tscn')
