extends Node2D

export (Texture) var corpse
export (int) var score_value = 50

var main

func _ready():
	add_to_group('destroyables')


func destroy():
	print("prop destroy")
	main.spawn_corpse(position, corpse)
	call_deferred("queue_free")
