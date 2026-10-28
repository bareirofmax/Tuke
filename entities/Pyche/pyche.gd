extends enemy
var directionx = -1.0
var directiony = -1.0
var ogspeed : float
var swaps = {
0:{ "Health": 25, "Damage": 3, "Speed": 600, "Name":["Paula","Paola","Perla"]},
}
func _ready():
	ogspeed = speed
	if swaps.size() < swaplvl:
		swaplvl = swaps.size()
	if swapuse:
		self.health = swaps[swaplvl].Health
		self.damage = swaps[swaplvl].Damage
		self.speed = swaps[swaplvl].Speed
		#$AnimatedSprite2D.material.set_shader_parameter("new", load("res://sprites/football/pallete/palOlimpio"+ str(swaplvl) + ".png"))
	uiName = swaps[swaplvl].Name[randi_range(0, swaps[swaplvl].Name.size()-1)]
func ai_input() -> void:
	if playa != null:
		if atkcool == false and walkcool == true and hurcool == false:
			if get_slide_collision_count() > 0:
				speed = speed * 0.8
				var collision = get_slide_collision(0)
				var normal = collision.get_normal()
				if abs(normal.x) > 0.1:
					directionx = sign(normal.x)
				if abs(normal.y) > 0.1:
					directiony = sign(normal.y)
			var direction := Vector2(directionx,directiony)
			velocity = direction * speed
		else:
			speed = ogspeed
			velocity = Vector2(0,0) + knockback
	else:
		velocity = Vector2(0,0) + knockback
		$idlereset.stop()

func _on_idlereset_timeout() -> void:
		if walkcool:
			walkcool = false
			#print("walktick IDLE")
			$idlereset.wait_time =  randf_range(2,3)
		else:
			walkcool = true
			#print("walktick WALK")
			#if randi_range(0,2) != 0:
				#posRand = Vector2(randi_range(-400, 400) , randi_range(-400, 400))
			#else:
				#posRand = Vector2(randi_range(-200, 200) , randi_range(-200, 200))
			$idlereset.wait_time =  randf_range(4,5)
		if health > 0:
			$idlereset.start()

func animations() -> void:
	if state == State.HURT:
		$AnimatedSprite2D.play("hurt")
		$Hurtbox/slap.disabled = true
	if state == State.IDLE:
		$AnimatedSprite2D.play("idle")
		$Hurtbox/slap.disabled = true
	if state == State.WALK:
		$Hurtbox/slap.disabled = false
		$AnimatedSprite2D.play("walk")
	if velocity.x > 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = false
		#$Hurtbox/head.position = $HeadRight.position
	elif velocity.x < 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = true
		#$Hurtbox/head.position = $HeadLeft.position
		await $AnimatedSprite2D.animation_finished

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	#print(self.get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != self.get_script().get_global_name()):
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Hurt"])
		$AudioStreamPlayer2D.play()
		area.get_parent().get_node("hitstun").start()
		area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 20, false)
