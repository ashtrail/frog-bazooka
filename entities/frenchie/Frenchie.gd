extends Area2D

export (int) var SPEED = 50
export (int) var CONTACT_DAMAGE = 1
export (Texture) var corpse

export (int) var score_value = 100

signal died(score_value)
signal spawned_corpse(pos, img, flip, z_offset)

var target
#var current_target
var direction = Vector2()

var Trail = load("res://entities/trail/DustTrail.tscn")


func _ready():
	add_to_group('mobs')
	add_to_group('destroyables')
	target = get_tree().get_nodes_in_group('player')[0]
	randomize()
	var random_cuttlery = randi() % 3
	if random_cuttlery == 0:
		$Sprites/Cuttlery/Fork.hide()
	elif random_cuttlery == 1:
		$Sprites/Cuttlery/Knife.hide()
	$ResetDirection.start()
	$AnimationPlayer.play("run")


func init(player, pos):
	target = player
	position = pos


func _physics_process(delta):
	position += direction * SPEED * delta


func reset_direction():
	direction = (target.position - position).normalized()
	if direction.x > 0:
		direction.x = 1
		$Sprites.scale = Vector2(1, 1)
	elif direction.x < 0:
		direction.x = -1
		$Sprites.scale = Vector2(-1, 1)
#	direction = Vector2()
#	if !target or position == target.position:
#		return
#	var axis = randi() % 2
#	match axis:
#		0:
#			if target.position.x > position.x:
#				direction.x = 1
#				$Sprites.scale = Vector2(1, 1)
#			else:
#				direction.x = -1
#				$Sprites.scale = Vector2(-1, 1)
#		1:
#			direction.y = 1 if target.position.y > position.y else -1

func collide(collider):
	if collider.is_in_group('player'):
		collider.slice(position)
		freeze()


func freeze():
	set_physics_process(false)
	$SpawnTrail.stop()
	$ResetDirection.stop()
	direction = Vector2()


func destroy():
	freeze()
	var flipped = $Sprites.scale == Vector2(-1, 1)
	emit_signal("spawned_corpse", position, corpse, flipped, 0)
#	Global.spawn_corpse(position, corpse)
	call_deferred("queue_free")


func _on_ResetDirection_timeout():
	reset_direction()


func _on_Frenchie_area_entered(area):
	collide(area)


func _on_Frenchie_body_entered(body):
	collide(body)


func _on_SpawnTrail_timeout():
	var trail = Trail.instance()
	get_parent().add_child(trail)
	trail.init(global_position, 4, 0.1)
