extends enemy
var wander := true
var ultra = true
var swaps = {
0:{ "Health": 250, "Damage": 10, "Speed": 200, "Name":["Chiquito"]},
}
func _ready():
	if swaps.size() < swaplvl:
		swaplvl = swaps.size()
	if swapuse:
		self.health = swaps[swaplvl].Health
		self.damage = swaps[swaplvl].Damage
		self.speed = swaps[swaplvl].Speed
		#$AnimatedSprite2D.material.set_shader_parameter("new", load("res://sprites/lynx/pallete/palLynx"+ str(swaplvl) + ".png"))
	uiName = swaps[swaplvl].Name[randi_range(0, swaps[swaplvl].Name.size()-1)]
func ai_input() -> void:
	if playa != null:
		if $Hitbox/CollisionShape2D2.disabled == false:
			$AnimatedSprite2D.modulate = Color(1, 0, 0)
		else:
			if ultra:
				$AnimatedSprite2D.modulate = Color(1, 1, 1)
			else:
				$AnimatedSprite2D.modulate = Color(1, 0.647, 0)
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
	if health < 125 and ultra and atkcool == false and hurcool == false:
		ultra = false
		atkcool = true
		state = State.SPEC2
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
			if 35 > abs(playa.position.y - position.y) and position.distance_to(playa.position) > 200: 
				#print("close projectile")
				projchance = 0
			else:
				#print("far projectile")
				projchance = randi_range(0,5)
			if projchance == 0 and atkcool == false and hurcool == false:
				atkcool = true
				if ultra:
					state = State.SPEC1
				else:
					state = State.SPEC3
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
		if hurcool == false and atkcool == false:
			state = State.ATTACK
			$idlereset.wait_time = randf_range(0.1,0.2)
		atkcool = true
	if health > 0:
		$idlereset.start()

func animations() ->void:
	if state == State.HURT:
		$AnimatedSprite2D.play("hurt")
	if state == State.IDLE:
		$Hitbox/CollisionShape2D2.disabled = true
		$AnimatedSprite2D.play("idle")
	if state == State.WALK:
		$Hitbox/CollisionShape2D2.disabled = true
		$AnimatedSprite2D.play("walk")
	if velocity.x > 0 and knocksum == 0 and state != State.SPEC1:
		$AnimatedSprite2D.flip_h = false
		$Hurtbox/slap.position = $Right.position
	elif velocity.x < 0 and knocksum == 0 and state != State.SPEC1:
		$AnimatedSprite2D.flip_h = true
		$Hurtbox/slap.position = $Left.position
	if state == State.ATTACK or State.SPEC1 or State.SPEC2 or State.SPEC3:
		if state == State.ATTACK:
			$AnimatedSprite2D.play("slap")
			if $AnimatedSprite2D.frame == 4:
				$Hurtbox/slap.disabled = false
			else: 
				$Hurtbox/slap.disabled = true
			if $AnimatedSprite2D.frame == 6:
				$Hitbox/CollisionShape2D2.disabled = false
		if state == State.SPEC1:
			$AnimatedSprite2D.play("throw")
			if $AnimatedSprite2D.frame == 8:
				if $AnimatedSprite2D.flip_h == false:
					#print("dash right")
					knockback.x = knockback.x + 3000
				else:
					#print("dash left")
					knockback.x = knockback.x - 3000
				$AudioStreamPlayer2D.pitch_scale = 1.25
				$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
				$AudioStreamPlayer2D.play()
				$Hurtbox/slap.disabled = false
			if $AnimatedSprite2D.frame == 11:
				$Hurtbox/slap.disabled = true
				$Hitbox/CollisionShape2D2.disabled = false
		if state == State.SPEC2:
			$AnimatedSprite2D.play("ganar")
			$Hitbox/CollisionShape2D2.disabled = true
			if $AnimatedSprite2D.frame == 0:
				$Label.show()
				$Label.text = "ARRIBA!!!"
			if $AnimatedSprite2D.frame == 3:
				$Label.text = "A GANAR!!!"
				$ExBurst.emitting = true
				speed = speed + 50
		if state == State.SPEC3:
			$AnimatedSprite2D.play("fast")
			if $AnimatedSprite2D.frame == 6:
				if $AnimatedSprite2D.flip_h == false:
					#print("dash right")
					knockback.x = knockback.x + 3000
				else:
					#print("dash left")
					knockback.x = knockback.x - 3000
				$AudioStreamPlayer2D.pitch_scale = 1.25
				$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
				$AudioStreamPlayer2D.play()
				$Hurtbox/slap.disabled = false
			if $AnimatedSprite2D.frame == 9:
				$Hurtbox/slap.disabled = true
				$Hitbox/CollisionShape2D2.disabled = false
		await $AnimatedSprite2D.animation_finished
		$Label.hide()
		$Hurtbox/slap.disabled = true
		knockback.x = 0
		knockback.y = 0
		atkcool = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	#print(self.get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != self.get_script().get_global_name()):
		area.get_parent().get_node("hitstun").start()
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
		if state == State.SPEC1:
			area.get_parent().hurt(damage*2,$AnimatedSprite2D.flip_h == false, 25, true)
		else:
			area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 15, true)
			$AudioStreamPlayer2D.pitch_scale = 1.3
		$AudioStreamPlayer2D.play()
		

func death(knock : Vector2) -> void:
	enemy_kill.emit()
	$AudioStreamPlayer2D.pitch_scale = 1
	$AudioStreamPlayer2D.volume_db = 5
	$AudioStreamPlayer2D.stream = load(sfx["Die"])
	$AudioStreamPlayer2D.play()
	self.get_node("CollisionShape2D").set_deferred("disabled", true)
	for item in $Hurtbox.get_children():
		item.set_deferred("disabled", true)
	for item in $Hitbox.get_children():
		item.set_deferred("disabled", true)
	hurcool = true
	state = State.HURT
	#self.modulate = Color(0,0,0,255)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", 1080, 1.1)
	tween.parallel().tween_property(self, "position", Vector2(self.position.x+sign(knock.x)*2000,self.position.y + randi_range(-100,100)), 1.3).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(self.queue_free)
