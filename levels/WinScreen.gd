extends Node2D

func _ready():
	$CanvasLayer/UI/Score.text = str(Global.score)

func _process(_delta):
	if Input.is_action_pressed('restart'):
		get_tree().change_scene('res://levels/Main.tscn')
