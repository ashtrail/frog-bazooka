extends Node2D

export (Array) var sprites

var sprite_index

func _ready():
	pass

enum TrailSize {
	Smallest = 0,
	Smaller,
	Small,
	Medium,
	Big = 4,
}

func init(pos, size, scale_delay = 0.2):
	position = pos
	$Timer.wait_time = scale_delay
	sprite_index = clamp(size, TrailSize.Smallest, TrailSize.Big)
	$Sprite.texture = sprites[sprite_index]
	$Timer.start()
	$AnimationPlayer.play("Rotate")
	var fade_duration = $Timer.wait_time * (sprite_index + 1)
	$Tween.interpolate_property(self, "modulate.a", 1, 0, fade_duration, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween.start()


func _on_Timer_timeout():
	sprite_index -= 1
	if sprite_index < 0:
		call_deferred("queue_free")
	else:
		$Sprite.texture = sprites[sprite_index]

