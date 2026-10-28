extends enemy
var swaps = {
0:{ "Health": 60, "Damage": 2, "Speed": 200, "Name":["Guille","Gero","Santino","Miguel"]},
1:{ "Health": 65, "Damage": 2, "Speed": 200, "Name":["Bruno","Maxi","Leopoldo","Enzo"]},
2:{ "Health": 75, "Damage": 3, "Speed": 250, "Name":["Pandolfo","Rodolfo","Daniel","Santiago"]},
3:{ "Health": 80, "Damage": 4, "Speed": 350, "Name":["Gordo Hijueputa"]},
}
func _ready():
	if swaps.size() < swaplvl:
		swaplvl = swaps.size()
	if swapuse:
		self.health = swaps[swaplvl].Health
		self.damage = swaps[swaplvl].Damage
		self.speed = swaps[swaplvl].Speed
		$AnimatedSprite2D.material.set_shader_parameter("new", load("res://sprites/panza/pallete/palPanza"+ str(swaplvl) + ".png"))
	uiName = swaps[swaplvl].Name[randi_range(0, swaps[swaplvl].Name.size()-1)]
func ai_input() -> void:
	if playa != null:
		if is_on_ceiling():
			posRand = Vector2(randi_range(-50, 50) , randi_range(0, 200))
		if is_on_floor():
			posRand = Vector2(randi_range(-50, 50) , randi_range(-200, 0))
		if atkcool == false and walkcool == true and hurcool == false:
			var direction := (playa.position - position + posRand).normalized()
			velocity = direction * speed
			if (position.distance_to(playa.position + posRand)) < 10:
				$idlereset.stop()
				velocity = Vector2(0,0)
				posRand = Vector2(randi_range(-50, 50) , randi_range(-50, 50))
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
				$idlereset.wait_time =  randf_range(1,2)
			else:
				posRand = Vector2(50, 25)
				$idlereset.wait_time =  randf_range(0.3,0.6)
	else:
		#print("walktick ATTACKEN")
		if (playa.position.x - position.x) >= 0:
			$AnimatedSprite2D.flip_h = false
			$Hurtbox/slap.position = $Right.position
		else:
			$AnimatedSprite2D.flip_h = true
			$Hurtbox/slap.position = $Left.position
		if hurcool == false:
			if randi_range(0,3) == 0 and atkcool == false:
				state = State.SPEC1
				$idlereset.wait_time = randf_range(0.3,0.7)
			else:
				state = State.ATTACK
				$idlereset.wait_time = randf_range(0.1,0.3)
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
			$AnimatedSprite2D.play("termo")
			if $AnimatedSprite2D.frame == 1:
				$Hurtbox/slap.scale.x = 2
				$Hurtbox/slap.scale.y= 1.5
				$Hurtbox/slap.disabled = false
			else: 
				$Hurtbox/slap.disabled = true
				$Hurtbox/slap.scale.x = 1
				$Hurtbox/slap.scale.y = 1
		$Hurtbox/slap.scale.x = 1
		$Hurtbox/slap.scale.y = 1
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
			$AudioStreamPlayer2D.pitch_scale = 0.5
		else:
			area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 1, true)
			$AudioStreamPlayer2D.stream = load(sfx["Hit"])
		$AudioStreamPlayer2D.play()
