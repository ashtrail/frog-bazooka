extends YSort

signal score_updated(score)

export (int) var spawn_radius = 300
export (Array) var props
export (int) var props_to_spawn = 10000



var ScorePopup = load("res://ui/score_popup/ScorePopup.tscn")
var BonusPopup = load("res://ui/bonus_popup/BonusPopup.tscn")

var Frenchie = load("res://entities/frenchie/Frenchie.tscn")
#var frenchies = []


var score = 0

var Corpse = load("res://entities/corpse/Corpse.tscn")

func spawn_corpse(pos, img, flip = false, z_offset = 0):
	var corpse = Corpse.instance()
	corpse.init(pos, img, flip, z_offset)
	add_child(corpse)


func _ready():
	emit_signal("score_updated", score)
	randomize()
	for i in range(props_to_spawn):
		var x = round(rand_range(6000, -6000))
		var y = round(rand_range(6000, -6000))
		var pos = Vector2(x, y)
		var prop = props[randi() % props.size()]
		var p = prop.instance()
		p.position = pos
		p.main = self
		add_child(p)
#	spawn_frenchie(Vector2(100, 100))
#	spawn_frenchie(Vector2(-100, -100))
	$PalmTree.main = self
	$GameTimer.start()


func add_score(to_add):
	score += to_add
	emit_signal("score_updated", score)


func _on_Player_game_over():
	$GameTimer.paused = true
	$SpawnTimer.stop()
	var frenchies = get_tree().get_nodes_in_group('mobs')
	for f in frenchies:
		f.freeze()

#	get_tree().change_scene('res://levels/GameOver.tscn')


func bonus_popup(mult, bonus, desc, pos):
	var popup = BonusPopup.instance()
	$CanvasLayer/UI.add_child(popup)
	var score_text = "+%sx%s" % [mult, bonus]
	popup.init(score_text, desc, pos)
	add_score(mult * bonus)


func score_popup(score, pos):
	var popup = ScorePopup.instance()
	$CanvasLayer/UI.add_child(popup)
	var score_text = "+%s" % score
	popup.init(score_text, pos)
	add_score(score)


func _process(delta):
	$CanvasLayer/UI/Timer.text = str(floor($GameTimer.time_left))


func _on_GameTimer_timeout():
	Global.score = score
#	print("score = %s" % score)
	get_tree().change_scene('res://levels/WinScreen.tscn')


func _on_Player_shot(bullet):
	bullet.main = self


func spawn_frenchie(pos : Vector2):
	var frenchie = Frenchie.instance()
	frenchie.init($Player, pos)
	frenchie.connect("spawned_corpse", self, "spawn_corpse")
	add_child(frenchie)


func _on_SpawnTimer_timeout():
	var angle = round(rand_range(0, 360))
	var offset = Vector2(spawn_radius, 0).rotated(deg2rad(angle))
	spawn_frenchie($Player.position + offset)
