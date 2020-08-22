extends Node2D

export (int) var speed = 200
export (int) var oscillation_speed = 50
export (Vector2) var oscillation

export (PackedScene) var Trail

export (Texture) var residue

var direction
var camera
var main
var player

var explosion_kills = 0

func _ready():
	add_to_group('bullets')
	$Explosion/ExplosionArea/CollisionShape2D.set_deferred("disabled", true)
	$Body/RocketCollider/RocketCollision.set_deferred("disabled", false)
	$Body/Sprite.show()
	$Explosion/AnimatedSprite.hide()
	$AnimationPlayer.play("oscillate")

func init(pos, dir : Vector2, player_camera, p):
	global_position = pos
	direction = dir.normalized()
	camera = player_camera
	player = p
	_on_TrailSpawnTimer_timeout()

func _physics_process(delta):
	var velocity = (direction * speed + oscillation * oscillation_speed)
	rotation = velocity.angle()
	position +=  velocity * delta


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")


func _on_TrailSpawnTimer_timeout():
	var trail = Trail.instance()
	get_parent().add_child(trail)
	trail.init($Trail/SpawnPos.global_position, 3)


func explode(on_collision):
	$AnimationPlayer.play("explode")
	if on_collision:
		camera.shake(0.5, 30, 20)
	else:
		camera.shake(0.3, 20, 5)
	yield($AnimationPlayer, "animation_finished")
	print("overlaps = " + str($Explosion/ExplosionArea.get_overlapping_areas()))
	if explosion_kills > 1:
		var screen_pos = get_global_transform_with_canvas().origin
		main.bonus_popup(Global.GROUP_BONUS, explosion_kills, "Group Destruction", screen_pos)
	die()


func _on_RocketCollider_area_entered(area):
	rocket_collision(area)

func _on_RocketCollider_body_entered(body):
	rocket_collision(body)


func rocket_collision(_collider):
	set_physics_process(false)
	direction = Vector2(0, 0)
	explode(true)


func die():
	main.spawn_corpse(position, residue, false, -1)
	call_deferred("queue_free")


func _on_ExplosionArea_area_entered(area):
	print("explosion area entered")
	explosion_collision(area)


func _on_ExplosionArea_body_entered(body):
	explosion_collision(body)


func explosion_collision(collider):
	print("explosion collision")
	if collider.is_in_group("player"):
		collider.roast(position)
	elif collider.is_in_group('destroyables'):
		print("explosion kill")
		explosion_kills += 1
		var screen_pos = collider.get_global_transform_with_canvas().origin
		main.score_popup(collider.score_value, screen_pos)
#		main.add_score(100)
		collider.destroy()


func _on_DeathTimer_timeout():
	explode(false)
