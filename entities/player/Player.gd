extends KinematicBody2D

export (int) var SPEED = 100
export (PackedScene) var Rocket = preload("res://entities/rocket/Rocket.tscn")
export (int) var MAX_HP = 3
export (int) var spread = 15

export (int) var recoil_power = 20

var Trail = load("res://entities/trail/DustTrail.tscn")

signal hp_updated(hp)
signal score_updated(score)
signal shot(bullet)
signal game_over

var velocity = Vector2()
var screen_size
var hp
var score = 0
var moving = false

var facing_right = true

func _ready():
	add_to_group('player')
	add_to_group('destroyables')
	hp = MAX_HP
	screen_size = get_viewport_rect().size
	emit_signal('score_updated', score)
	emit_signal('hp_updated', hp)
	$AnimationPlayer.play('iddle')
#	$FaceAnimator.play('idle')

func shoot():
	if not $FireRate.is_stopped():
		return
#	$AudioStreamPlayer.pitch_scale = 1 + rand_range(0.0, 0.2)
#	$FaceAnimator.play('shooting')
	var bullet_dir = -(position - get_global_mouse_position()).normalized()
	var spread_angle = rand_range(-spread, spread)
	bullet_dir = bullet_dir.rotated(deg2rad(spread_angle))

	var bullet = Rocket.instance()
	get_parent().add_child(bullet)
	bullet.init($Bazooka/Muzzle.global_position, bullet_dir, $Camera2D, self)
	emit_signal("shot", bullet)
	$Camera2D.shake(0.3, 20, 10)
	$FireRate.start()
#	position -= bullet_dir * recoil_power
	if facing_right:
		$AnimationPlayer.play('shoot right')
	else:
		$AnimationPlayer.play('shoot left')
	$Tween.interpolate_property(self, "position", position, position - bullet_dir * recoil_power,
		0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1)
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play('iddle')


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1

	if velocity.length() == 0 && $AnimationPlayer.current_animation == "run":
		$AnimationPlayer.play('iddle')
	elif velocity.length() != 0 && $AnimationPlayer.current_animation == "iddle":
		$AnimationPlayer.play('run')


	velocity = velocity.normalized() * SPEED

	if Input.is_action_just_pressed("shoot"):
		shoot()


func _physics_process(delta):
	get_input()
	move_and_collide(velocity * delta)
	var mouse_dir = -(position - get_global_mouse_position())
	$Bazooka.rotation = mouse_dir.angle()
	if mouse_dir.x > 0:
		facing_right = true
		$Sprite.scale = Vector2(1, 1)
		$Bazooka/Sprite.scale = Vector2(1, 1)
#		$Bazooka/Sprite.flip_v = false
	elif mouse_dir.x < 0:
		facing_right = false
		$Sprite.scale = Vector2(-1, 1)
		$Bazooka/Sprite.scale = Vector2(1, -1)
#		$Bazooka/Sprite.flip_v = true



func _on_Enemy_killed(score_value):
	score += score_value
	emit_signal('score_updated', score)

func take_damage(damage):
	hp -= damage
	$CollisionShape2D.set_deferred("disabled", true)
	# $CollisionShape2D.disabled = true
#	$Body.modulate = Color(1, 0, 0);
#	$AudioStreamPlayer.pitch_scale = 1
#	$FaceAnimator.play('hurt')
#	$AnimationPlayer.play('blink')
	emit_signal('hp_updated', hp)
#	if hp <= 0:
#		yield($FaceAnimator, 'animation_finished')
#		die()

func die(cause_pos, sliced):
	emit_signal('game_over')
	set_physics_process(false)
	$SpawnTrail.stop()
	$AnimationPlayer.stop()
	$Bazooka.z_index -= 10
	$Sprite.hide()
	$CollisionShape2D.set_deferred("disabled", true)
#	$CollisionShape2D.disabled = true
#	$Tween.interpolate_property($Bazooka, "position", $Bazooka.position, $DeadFrog.position, 0.2,
#		Tween.TRANS_CIRC, Tween.EASE_IN)
##	$Tween.interpolate_property($Bazooka, "rotation_degrees", $Bazooka.rotation_degrees, 0, 0.2,
##		Tween.TRANS_CIRC, Tween.EASE_IN)
#	$Tween.start()
	var slide_right = cause_pos.x < position.x
	$DeadFrog.death_animation(sliced, slide_right)


func roast(explosion_position):
	die(explosion_position, false)

func slice(mob_position):
	die(mob_position, true)


#func destroy():
#	emit_signal('game_over')


func _on_FaceAnimator_animation_finished(anim_name):
	match anim_name:
		'hurt':
			continue
		'shooting':
			$FaceAnimator.play('idle')

func _on_AnimationPlayer_animation_finished(anim_name):
	$Body.modulate = Color(1, 1, 1);
	$CollisionShape2D.disabled = false


func _on_SpawnTrail_timeout():
	if velocity.length() != 0:
		var trail = Trail.instance()
		get_parent().add_child(trail)
		trail.init(global_position, 4, 0.1)

