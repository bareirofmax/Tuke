extends enemy
var wander := true
var bullet = preload("res://entities/Fireball/fireball.tscn")
var swaps = {
0:{ "Health": 40, "Damage": 4, "Speed": 300, "Name":["Lynx"]},
1:{ "Health": 50, "Damage": 5, "Speed": 300, "Name":["Viper"]},
2:{ "Health": 60, "Damage": 5, "Speed": 310, "Name":["Coyote"]},
3:{ "Health": 65, "Damage": 6, "Speed": 350, "Name":["Panther"]},
}
func _ready():
	if swaps.size() < swaplvl:
		swaplvl = swaps.size()
	if swapuse:
		self.health = swaps[swaplvl].Health
		self.damage = swaps[swaplvl].Damage
		self.speed = swaps[swaplvl].Speed
		$AnimatedSprite2D.material.set_shader_parameter("new", load("res://sprites/lynx/pallete/palLynx"+ str(swaplvl) + ".png"))
	uiName = swaps[swaplvl].Name[randi_range(0, swaps[swaplvl].Name.size()-1)]
func ai_input() -> void:
	if playa != null:
		if is_on_ceiling():
			posRand = Vector2(randi_range(-50, 50) , randi_range(-200, 0))
		if is_on_floor():
			posRand = Vector2(randi_range(-50, 50) , randi_range(0, 200))
		if atkcool == false and walkcool == true and hurcool == false:
			if wander:
				var direction := (playa.position - position).normalized()
				velocity = direction * speed
				if (position.distance_to(playa.position)) < 10:
					#$idlereset.stop()
					velocity = Vector2(0,0)
					#posRand = Vector2(randi_range(-50, 50) , randi_range(-50, 50))
					#$idlereset.wait_time = randf_range(0.1,0.2)
					#$idlereset.start()
			else:
				velocity.x = 0
				var distancey := playa.position.y - position.y 
				velocity.y = sign(distancey)  * speed
				if abs(distancey) < 10: 
					velocity = Vector2.ZERO
		else:
			velocity = Vector2(0,0) + knockback
	else:
		velocity = Vector2(0,0) + knockback
		$idlereset.stop()

func _on_idlereset_timeout() -> void:
	if position.distance_to(playa.position) > 50:
		if walkcool:
			if (playa.position.x - position.x) >= 0:
				$AnimatedSprite2D.flip_h = false
				$Hurtbox/slap.position = $Right.position
			else:
				$AnimatedSprite2D.flip_h = true
				$Hurtbox/slap.position = $Left.position
			walkcool = false
			var projchance : int
			if 35 > abs(playa.position.y - position.y): 
				#print("close projectile")
				projchance = 0
			else:
				#print("far projectile")
				projchance = randi_range(0,3)
			if projchance == 0 and atkcool == false and hurcool == false:
				state = State.SPEC1
				atkcool = true
				$idlereset.wait_time = randf_range(0.4,0.6)
			else:
				#print("proj denied")
				$idlereset.wait_time =  randf_range(0.3,0.5)
		else:
			walkcool = true
			#wander = false
			#print(str(position.distance_to(playa.position) > 350))
			
			if randi_range(0,4) != 0 and position.distance_to(playa.position) > 350:
				#print("chase/walk")
				pass
			elif position.distance_to(playa.position) < 350:
				#print("wander")
				#wander = true
				posRand = Vector2(randi_range(-200, 200) , randi_range(-200, 200))
				$idlereset.wait_time =  randf_range(0.5,0.6)
			elif position.distance_to(playa.position) < 200:
				posRand = Vector2(randi_range(-200, 200) , randi_range(-200, 200))
				$idlereset.wait_time =  randf_range(0.5,0.6)
	else:
		#print("walktick ATTACKEN")
		if (playa.position.x - position.x) >= 0:
			$AnimatedSprite2D.flip_h = false
			$Hurtbox/slap.position = $Right.position
		else:
			$AnimatedSprite2D.flip_h = true
			$Hurtbox/slap.position = $Left.position
		if hurcool == false:
			state = State.ATTACK
			$idlereset.wait_time = randf_range(0.1,0.2)
		atkcool = true
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
		$Hurtbox/slap.position = $Right.position
	elif velocity.x < 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = true
		$Hurtbox/slap.position = $Left.position
	if state == State.ATTACK or State.SPEC1:
		if state == State.ATTACK:
			$AnimatedSprite2D.play("slap")
			if $AnimatedSprite2D.frame == 1:
				$Hurtbox/slap.disabled = false
			else: 
				$Hurtbox/slap.disabled = true
		if state == State.SPEC1:
			$AnimatedSprite2D.play("throw")
			if $AnimatedSprite2D.frame == 3:
				$AudioStreamPlayer2D.pitch_scale = 1.25
				$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
				$AudioStreamPlayer2D.play()
				var proj = bullet.instantiate()
				proj.psprite = "res://sprites/lynx/bullet.png"
				proj.sender = ""
				proj.pos = $Hurtbox/slap.global_position
				proj.Damage = damage
				if $AnimatedSprite2D.flip_h == true:
					proj.direction = -1
				else:
					proj.direction = 1
				get_parent().add_child(proj)
		await $AnimatedSprite2D.animation_finished
		atkcool = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	#print(self.get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != self.get_script().get_global_name()):
		area.get_parent().get_node("hitstun").start()
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
		if state == State.SPEC1:
			area.get_parent().hurt(damage*5,$AnimatedSprite2D.flip_h == false, 25, true)
		else:
			area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 15, true)
			$AudioStreamPlayer2D.pitch_scale = 1.3
		$AudioStreamPlayer2D.play()
