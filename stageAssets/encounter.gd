extends Node
@export var cam : Camera2D
@export var playa : player
@export var boss = false
var active = false
var i = 0
var waveCount = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func enemy_kill_count() -> void:
	#print("enemy bagged")
	i = i - 1
	if !boss:
		if i == 0:
			if self.get_node(str("Wave" + str(waveCount))).get_child_count() <= 0:
				waveCount = waveCount + 1
				#maxScreen = maxScreen + maxInc
				var nextWave = self.get_node(str("Wave" + str(waveCount)))
				if nextWave == null:
					cam.get_node("CamCollision").get_node("Top").set_deferred("disabled", true)
					cam.get_node("CamCollision").get_node("Bottom").set_deferred("disabled", true)
					cam.get_node("CamCollision").get_node("Left").set_deferred("disabled", true)
					cam.get_node("CamCollision").get_node("Right").set_deferred("disabled", true)
					cam.follow = true
					cam.get_node("HUD").enemy_status("AREA SEGURA! CONTINUA!",0,0)
					self.queue_free()
				else:
					print("nextWave")
					wave_spawn(nextWave)
			else:
				#print("do it again bitch")
				#print(i)
				wave_spawn(self.get_node(str("Wave" + str(waveCount))))
	else:
		cam.get_node("HUD").win()

func wave_spawn(wave : Node) -> void:
	var toTheRightNow = true
	for item in wave.get_children():
			i = i + 1
			if toTheRightNow == false:
				if item.name != "Pyche":
					toTheRightNow = true
					item.position.x = item.position.x - 1300
			else:
				toTheRightNow = false
				item.position.x = item.position.x 
			item.reparent.call_deferred($"..")
			item.visible = true
			for item2 in item.get_node("Hitbox").get_children():
				item2.set_deferred("disabled", false)
			item.get_node("idlereset").start()
			item.playa = playa
			item.enemy_kill.connect(enemy_kill_count)


func _on_lockposition_body_entered(body: Node2D) -> void:
	if body.name == "Player" and active == false:
		if boss:
			pass
			#$"../../Camera2D/AudioStreamPlayer2D".stop()
			#$"../../Camera2D/AudioStreamPlayer2D".stream = load("res://sounds/music/breakdown.mp3")
			#$"../../Camera2D/AudioStreamPlayer2D".play()
		active = true
		#print("ambush!")
		cam.get_node("CamCollision").get_node("Top").set_deferred("disabled", false)
		cam.get_node("CamCollision").get_node("Bottom").set_deferred("disabled", false)
		cam.get_node("CamCollision").get_node("Left").set_deferred("disabled", false)
		cam.get_node("CamCollision").get_node("Right").set_deferred("disabled", false)
		#cam.position = self.position
		cam.follow = false
		wave_spawn($Wave1)
