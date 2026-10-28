extends enemy
var swaps = {
0:{ "Health": 18, "Damage": 3, "Speed": 250, "Name":["Pablo","Paolo","Pedro","Policarpo"]},
1:{ "Health": 25, "Damage": 3, "Speed": 200, "Name":["Oliver","Orlando","Olimpio","Oscar"]},
2:{ "Health": 30, "Damage": 3, "Speed": 300, "Name":["Carlos","Camilo","Cesar","Cristian"]},
3:{ "Health": 40, "Damage": 4, "Speed": 300, "Name":["Guido","Gutierrez","Gaston","Guzman"]},
4:{ "Health": 45, "Damage": 4, "Speed": 350, "Name":["Lucas","Lorenzo","Leandro","Lisandro"]},
}
func _ready():
	if swaps.size() < swaplvl:
		swaplvl = swaps.size()
	if swapuse:
		self.health = swaps[swaplvl].Health
		self.damage = swaps[swaplvl].Damage
		self.speed = swaps[swaplvl].Speed
		$AnimatedSprite2D.material.set_shader_parameter("new", load("res://sprites/football/pallete/palOlimpio"+ str(swaplvl) + ".png"))
	uiName = swaps[swaplvl].Name[randi_range(0, swaps[swaplvl].Name.size()-1)]

func ai_input() -> void: 
	if playa != null:
		if is_on_ceiling():
			posRand = Vector2(randi_range(-50, 50) , randi_range(0, 200))
		if is_on_floor():
			posRand = Vector2(randi_range(-50, 50) , randi_range(-200, 0))
		if atkcool == false and walkcool == true and hurcool == false:
			var direction := (playa.position - position + posRand).normalized() #this line and posRand are used in all enemies for movement and were adapted from The GameDev Tavern's video www.youtube.com/watch?v=Y5i42mZTO4M&list=PLNNbuBNHHbNGtZjygmnJ2fBvp6JmDNkAm&index=1
			velocity = direction * speed
			if (position.distance_to(playa.position + posRand)) < 10:
				$idlereset.stop()
				velocity = Vector2(0,0)
				posRand = Vector2(randi_range(-100, 100) , randi_range(-100, 100))
				$idlereset.wait_time = randf_range(0.1,0.2)
				$idlereset.start()
		else:
			velocity = Vector2(0,0) + knockback
	else:
		velocity = Vector2(0,0) + knockback
		$idlereset.stop()

func _on_idlereset_timeout() -> void:
	if position.distance_to(playa.position) > 75:
		if walkcool:
			walkcool = false
			#print("walktick IDLE")
			$idlereset.wait_time =  randf_range(0.5,1)
		else:
			walkcool = true
			#print("walktick WALK")
			if position.distance_to(playa.position) > 300:
				posRand = Vector2(randi_range(-200, 200) , randi_range(-200, 200))
				$idlereset.wait_time =  randf_range(2,4)
			else:
				posRand = Vector2(50, 25)
				$idlereset.wait_time =  randf_range(0.2,0.4)
	else:
		#print("walktick ATTACKEN")
		if (playa.position.x - position.x) >= 0:
			$AnimatedSprite2D.flip_h = false
			$Hurtbox/head.position = $HeadRight.position
		else:
			$AnimatedSprite2D.flip_h = true
			$Hurtbox/head.position = $HeadLeft.position
		if hurcool == false:
			state = State.ATTACK
			atkcool = true
			$idlereset.wait_time = randf_range(0.1,0.2)
	if health > 0:
		$idlereset.start()
func animations() ->void:
	if state == State.HURT:
		$AnimatedSprite2D.play("hurt")
	if state == State.IDLE:
		$AnimatedSprite2D.play("idle")
	if state == State.WALK:
		$AnimatedSprite2D.play("walk")
	if velocity.x > 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = false
		$Hurtbox/head.position = $HeadRight.position
	elif velocity.x < 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = true
		$Hurtbox/head.position = $HeadLeft.position
	if state == State.ATTACK or state == State.SPEC1:
		if state == State.ATTACK:
			$AnimatedSprite2D.play("headbutt")
			if $AnimatedSprite2D.frame == 3 or $AnimatedSprite2D.frame == 4:
				$Hurtbox/head.disabled = false
			else: 
				$Hurtbox/head.disabled = true
		elif state == State.SPEC1:
			$AnimatedSprite2D.play("kick")
			if $AnimatedSprite2D.frame == 2 or $AnimatedSprite2D.frame == 3:
				$Hurtbox/head.disabled = false
			else: 
				$Hurtbox/head.disabled = true
		await $AnimatedSprite2D.animation_finished
		atkcool = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	#print(self.get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != self.get_script().get_global_name()):
		#print("ouch")
		area.get_parent().get_node("hitstun").start()
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
		if state == State.SPEC1:
			area.get_parent().hurt(damage*2,$AnimatedSprite2D.flip_h == false, 4, true)
		else:
			area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 4, true)
		$AudioStreamPlayer2D.play()
