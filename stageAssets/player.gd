extends character
class_name player
@export var maxhealth : int
@export var money : int
var cumMoney : int
var glcombo = 0
var maxmana = 3
var mana = 0
var bullet = preload("res://entities/Fireball/fireball.tscn")
var sfx = {
"Hit": "res://sounds/punch.mp3",
"Special": "res://sounds/energy.mp3",
"Eat":"res://sounds/energy.mp3",
"Hurt": "res://sounds/explosion.mp3",
#"No":
}
var altpunch = false
var sucHit = false
var enhance = false
signal mana_changed
signal combo_changed
signal enemy_focus(uiname : String,health : int, mhealth : int)
#keycombo code by jesse florig @ gist.github.com/jesseflorig/4b9fd832c3db8ee25a52994ec2f77cb4
const COMBO_TIMEOUT = 0.2 # Timeout between key presses
const MAX_COMBO_CHAIN = 2 # Maximum key presses in a combo
var last_key_delta = 0    # Time since last keypress
var key_combo = []        # Current combo
var comboableKeys = ["ui_up","ui_down","ui_left","ui_right"]
func _process(delta: float) -> void:
	if Engine.time_scale == 1:
		ai_input()
		movement()
		animations()
	move_and_slide()
	last_key_delta += delta

func _input(event): #code by jesse florig
	if event is InputEventKey and event.pressed and !event.echo: # If distinct key press down
		#print(last_key_delta)
		if last_key_delta > COMBO_TIMEOUT:                   # Reset combo if stale
			key_combo = []
	
		for item in InputMap.get_actions():
			if event.is_action(item) and item.substr(0) in comboableKeys:
				key_combo.append(item.substr(0))      # Otherwise add it to combo
		if key_combo.size() > MAX_COMBO_CHAIN:               # Prune if necessary
			key_combo.pop_front()
		
		#print(key_combo)                                     # Log the combo (could pass to combo evaluator)
		last_key_delta = 0                                   # Reset keypress timer

func ai_input() -> void:
	if state == State.SPEC4 and mana >= 1 and Input.is_action_just_pressed("Special") and enhance == false and $AnimatedSprite2D.frame <= 1:
		mana = mana - 1
		enhance = true
		mana_changed.emit()
	if state == State.SPEC3 and mana >= 1 and Input.is_action_pressed("ui_down") and enhance == false and $AnimatedSprite2D.frame <= 4:
		mana = mana - 1
		enhance = true
		mana_changed.emit()
		$AudioStreamPlayer2D.volume_db = 0
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Special"])
		$AudioStreamPlayer2D.play()
	if (key_combo == ["ui_right","ui_right"] or key_combo == ["ui_left","ui_left"] or key_combo == ["ui_down","ui_down"] or key_combo == ["ui_up","ui_up"]) and atkcool == false and hurcool == false:
		state = State.SPEC4
		if key_combo == ["ui_right","ui_right"]:
			knockback.x = knockback.x + 1000
		elif key_combo == ["ui_left","ui_left"]:
			knockback.x = knockback.x - 1000
		elif key_combo == ["ui_down","ui_down"]:
			knockback.y = knockback.y + 750
		elif key_combo == ["ui_up","ui_up"]:
			knockback.y = knockback.y - 750
		key_combo = []
		atkcool = true
	if Input.is_action_pressed("Special") and Input.is_action_pressed("Attack") and atkcool == false and (mana >= 1 or ((float(health)/maxhealth) > 0.05)):
		state = State.SPEC3
		atkcool = true
	if Input.is_action_just_pressed("Special") and Input.is_action_pressed("ui_up") and mana >= 1 and hurcool == false and state != State.SPEC2:
		mana = mana - 1
		state = State.SPEC2
		atkcool = true
		mana_changed.emit()
	if Input.is_action_just_pressed("Attack") and atkcool == false and hurcool == false:
		if sucHit:
			if altpunch:
				altpunch = false
			else:
				altpunch = true
		else:
			altpunch = false
		state = State.ATTACK
		atkcool = true
	if Input.is_action_just_pressed("Special") and hurcool == false and atkcool == false:
		state = State.SPEC1
		atkcool = true
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if hurcool or atkcool:
		velocity = Vector2.ZERO + knockback
	else:
		velocity = direction * speed
func animations() -> void:
	if $Hitbox/CollisionShape2D.disabled == false:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
	else:
		if state != State.HURT:
			$AnimatedSprite2D.modulate = Color(0, 1, 1)
	if state == State.HURT:
		$AnimatedSprite2D.play("hurt")
	if state == State.IDLE:
		$AnimatedSprite2D.play("idle")
	if state == State.WALK:
		$AnimatedSprite2D.play("walk")
	if velocity.x > 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = false
		$Hurtbox/head.position = $HeadRight.position
		$Hurtbox/cane.position = $CaneRight.position
	elif velocity.x < 0 and knocksum == 0:
		$AnimatedSprite2D.flip_h = true
		$Hurtbox/head.position = $HeadLeft.position
		$Hurtbox/cane.position = $CaneLeft.position
	if state == State.ATTACK or state == State.SPEC1 or State.SPEC2:
		if state == State.ATTACK:
			if altpunch:
				$AnimatedSprite2D.play("alt")
			else:
				$AnimatedSprite2D.play("headbutt")
			if $AnimatedSprite2D.frame == 2:
				sucHit = false
				$Hurtbox/head.disabled = false
			else: 
				$Hurtbox/head.disabled = true
		elif state == State.SPEC1:
			$AnimatedSprite2D.play("kick")
			#$Hurtbox/head.scale.x = 2
			if $AnimatedSprite2D.frame == 2:
				$Hurtbox/cane.disabled = false
			else: 
				$Hurtbox/cane.disabled = true
		elif state == State.SPEC2:
			$AnimatedSprite2D.play("fireball")
			if $AnimatedSprite2D.frame == 2:
					$ExBurst.emitting = true
					$AudioStreamPlayer2D.volume_db = 0
					$AudioStreamPlayer2D.pitch_scale = 1
					$AudioStreamPlayer2D.stream = load(sfx["Special"])
					$AudioStreamPlayer2D.play()
					var proj = bullet.instantiate()
					proj.sender = "Player"
					proj.pos = $Hurtbox/head.global_position
					proj.Damage = damage
					proj.psprite = "res://sprites/jasy/musak.png"
					if $AnimatedSprite2D.flip_h == true:
						proj.direction = -1
					else:
						proj.direction = 1
					get_parent().add_child(proj)
		elif state == State.SPEC3:
			$AnimatedSprite2D.play("aoe")
			$Hitbox/CollisionShape2D.disabled = true
			if $AnimatedSprite2D.frame == 1:
				if (float(health)/maxhealth) > 0.05 and enhance == false:
						health = health -(maxhealth * 0.05)
						health_changed.emit()
			if $AnimatedSprite2D.frame == 2:
				if enhance:
					$ExBurst.emitting = true
				$Hurtbox/aoe.disabled = false
			else: 
				$Hurtbox/aoe.disabled = true
			if $AnimatedSprite2D.frame == 5:
				$Hitbox/CollisionShape2D.disabled = false
		elif state == State.SPEC4:
			$AnimatedSprite2D.play("dash")
			if enhance:
				$Hitbox/CollisionShape2D.disabled = true
				if $AnimatedSprite2D.frame == 1:
					$ExBurst.emitting = true
					$AudioStreamPlayer2D.volume_db = 0
					$AudioStreamPlayer2D.pitch_scale = 1
					$AudioStreamPlayer2D.stream = load(sfx["Special"])
					$AudioStreamPlayer2D.play()
					$Hurtbox/aoe.disabled = false
				else: 
					$Hurtbox/aoe.disabled = true
				if $AnimatedSprite2D.frame == 4:
					$Hitbox/CollisionShape2D.disabled = false
			if $AnimatedSprite2D.frame == 4:
				knockback.x = 0
				knockback.y = 0
		await $AnimatedSprite2D.animation_finished
		atkcool = false
		$Hitbox/CollisionShape2D.disabled = false
		#$Hurtbox/head.scale.x = 1
		knockback.x = 0
		knockback.y = 0
		enhance = false
		$Hurtbox/head.disabled = true
		$Hurtbox/aoe.disabled = true
		$Hurtbox/cane.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	#print(self.get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != self.get_script().get_global_name()):
		sucHit = true
		area.get_parent().get_node("hitstun").start()
		$AudioStreamPlayer2D.volume_db = 0
		$AudioStreamPlayer2D.pitch_scale = 1
		$AudioStreamPlayer2D.stream = load(sfx["Hit"])
		if state == State.SPEC1:
			area.get_parent().hurt(damage*2,$AnimatedSprite2D.flip_h == false, 25, true)
			area.get_parent().get_node("idlereset").start()
			$AudioStreamPlayer2D.pitch_scale = 0.7
		elif state == State.SPEC3:
			if enhance:
				area.get_parent().hurt(damage*3,$AnimatedSprite2D.flip_h == false, 40, false)
			else:
				area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 20, true)
			area.get_parent().get_node("idlereset").start()
			$AudioStreamPlayer2D.pitch_scale = 0.5
		elif state == State.SPEC4:
			area.get_parent().hurt(damage*2,$AnimatedSprite2D.flip_h == false, 10, false)
			area.get_parent().get_node("idlereset").start()
			$AudioStreamPlayer2D.pitch_scale = 0.5
		else:
			if 6 == (area.get_parent().knocksum): #if its a three X combo
				$AudioStreamPlayer2D.pitch_scale = 1.5
				area.get_parent().hurt(damage/2,$AnimatedSprite2D.flip_h == false, 15, true)
				sucHit = false
			else:
				area.get_parent().hurt(damage,$AnimatedSprite2D.flip_h == false, 3, true)
		combo(false)
		$AudioStreamPlayer2D.play()
		enemy_focus.emit(area.get_parent().uiName,area.get_parent().health,area.get_parent().swaps[area.get_parent().swaplvl].Health)
	elif area.name == "GrabRange":
		if (area.get_parent().shopkeeper == true and (money - area.get_parent().price >= 0)) or area.get_parent().shopkeeper == false:
			$AudioStreamPlayer2D.volume_db = 0
			$AudioStreamPlayer2D.pitch_scale = 1
			$AudioStreamPlayer2D.stream = load(sfx["Eat"])
			$AudioStreamPlayer2D.play()
			if (health + (maxhealth * area.get_parent().healthbonus/100)) > maxhealth:
				health = maxhealth
			else:
				health = health + (maxhealth * area.get_parent().healthbonus/100)
			if (mana + area.get_parent().manabonus) > maxmana:
				mana = maxmana
			else:
				mana = mana + area.get_parent().manabonus
			damage = damage + area.get_parent().dmgbonus
			speed = speed + area.get_parent().speedbonus
			health_changed.emit()
			mana_changed.emit()
			var pickupLabel = ""
			if (area.get_parent().healthbonus) != 0:
				pickupLabel = pickupLabel + str(" +" + str(area.get_parent().healthbonus) + "% HP")
			if (area.get_parent().dmgbonus) != 0:
				pickupLabel = pickupLabel + str(" +" + str(area.get_parent().dmgbonus) + " DMG")
			if (area.get_parent().speedbonus) != 0:
				pickupLabel = pickupLabel + str(" +" + str(area.get_parent().speedbonus) + " SPD")
			if (area.get_parent().manabonus) != 0:
				pickupLabel = pickupLabel + str(" +" + str(area.get_parent().manabonus) + " MANA")
			enemy_focus.emit(area.get_parent().pickupName + pickupLabel,0,0)
			pickupLabel = ""
			if area.get_parent().shopkeeper:
				money = money - area.get_parent().price
				combo(true)
			if area.get_parent().unlimited == false:
				area.get_parent().queue_free()
		elif (area.get_parent().shopkeeper == true and (money - area.get_parent().price >= 0) == false):
			$AudioStreamPlayer2D.pitch_scale = 1
			$AudioStreamPlayer2D.volume_db = -5
			#$AudioStreamPlayer2D.stream = load(sfx["No"])
			$AudioStreamPlayer2D.play()

func combo(food : bool) -> void:
	if food == false:
		glcombo = glcombo + 1
		cumMoney = cumMoney + 50
	if glcombo % 10 == 0 and food == false:
		cumMoney = snappedi(cumMoney * 1.5,50)
		mana = mana + 1
		if maxmana < mana:
			mana = maxmana
		mana_changed.emit()
		#print(str(mana) + " / " + str(maxmana))
	combo_changed.emit()
	if glcombo > 0:
		$Combo.stop()
		#$Label.visible = true
		#$Label.text = "combo: " + str(glcombo)
		$Combo.start()

func _on_combo_timeout() -> void:
	money = money + cumMoney
	cumMoney = 0
	glcombo = 0
	altpunch = false
	combo_changed.emit()
	#$Label.visible = false
	$Combo.stop()
	
func death(_knock : Vector2) -> void:
	if 0 >= health:
		$"../../Camera2D/Pause".hide()
		$"../../Camera2D/HUD".hide()
		$"../../Camera2D/Death".show()
		$"../../Camera2D/Death/Retry".grab_focus()
		$"../../Camera2D/Death/Retry".disabled = false
		$"../../Camera2D/Death/Menu".disabled = false
		$"../../Camera2D/Death/Quit".disabled = false
	#self.queue_free()
	

func _on_hitstun_timeout() -> void:
	if health > 0:
		atkcool = false
		hurcool = false
	for item in $Hurtbox.get_children():
		item.disabled = true
	knockback = Vector2.ZERO
	knocksum = 0
	altpunch = false
	selfcombo = 0
	$hitstun.wait_time = oghitstun

func hurt(ouchdmg : int ,dir : bool, knockinc: float, stack : bool) -> void:
	for item in $Hurtbox.get_children():
		item.set_deferred("disabled", true)
	knocksum = knocksum + knockinc
	selfcombo = selfcombo + 1
	state = State.HURT
	$Hitbox/hitspark.play("default")
	$Hitbox/hitspark.scale.x = 1 + float(selfcombo)/4
	$Hitbox/hitspark.scale.y = 1 + float(selfcombo)/4
	atkcool = false
	hurcool = true
	health = health - ouchdmg
	#print(health)
	if stack:
		if dir == false:
			knockback = knocksum * Vector2(100,0) * -1
		else:
				knockback =  knocksum * Vector2(100,0)
	else:
		if dir == false:
			knockback = knockinc * Vector2(100,0) * -1
		else:
				knockback =  knockinc * Vector2(100,0)
	#print(selfcombo)
	if $hitstun.wait_time > 0.1:
		$hitstun.wait_time = $hitstun.wait_time - 0.1
	health_changed.emit()
	money = money + cumMoney
	cumMoney = 0
	glcombo = 0
	combo_changed.emit()
	#$Label.visible = false
	$Combo.stop()
	if health <= 0:
		death(knockback)
