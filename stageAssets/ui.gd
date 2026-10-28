extends Control
@export var playa : player
var paused = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1
	$Label.text = str(playa.money) + " Gs."
	health_update()
	mana_update()
	playa.health_changed.connect(health_update)
	playa.mana_changed.connect(mana_update)
	playa.combo_changed.connect(combo_update)
	playa.enemy_focus.connect(enemy_status)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pause()

func health_update()-> void:
	$ProgressBar.value = playa.health
	$ProgressBar.max_value = playa.maxhealth
	if 0 >= playa.health:
		Engine.time_scale = 0

func mana_update()-> void:
	if playa.mana >= 1:
		$Mana1.visible = true
	else:
		$Mana1.visible = false
	if playa.mana >= 2:
		$Mana2.visible = true
	else:
		$Mana2.visible = false
	if playa.mana == 3:
		$Mana3.visible = true
	else:
		$Mana3.visible = false

func combo_update()-> void:
	if playa.glcombo >= 1:
		#$Label.visible = true
		$Label.text = "combo x" + str(playa.glcombo) + " +" + str(playa.cumMoney) + "Gs."
	else:
		$Label.text = str(playa.money) + " Gs."
		#$Label.visible = false
		#$EnemyBar.visible = false
		#$EnemyLabel.visible = false

func pause()-> void:
	if playa.health >= 0:
		var pauseHealth = str("HP: " + str(playa.health) + "/" + str(playa.maxhealth) + "\n")
		var pauseMana = str("MANA: " + str(playa.mana) + "/" + str(playa.maxmana) + "\n")
		var pauseDmg = str("ATK: " + str(playa.damage) + "\n")
		var pauseSpeed = str("VEL: " + str(playa.speed))
		$"../Pause/Stats".text = pauseHealth + pauseMana + pauseDmg + pauseSpeed
		if paused:
			Engine.time_scale = 1
			get_parent().get_node("Pause").hide()
			get_parent().get_node("HUD").show()
		else:
			Engine.time_scale = 0
			get_parent().get_node("HUD").hide()
			get_parent().get_node("Pause").show()
		paused = !paused

func enemy_status(uiname : String,health : int, mhealth : int)-> void:
	$EnemyLabel.visible = true
	$EnemyLabel.text = uiname
	if health == 0 and mhealth == 0:
		$Label.text = str(playa.money) + " Gs."
		$EnemyBar.visible = false
		$enemyVar.visible = false
		$enemybg.visible = false
	else:
		if health == 0:
			#playa.altpunch = false
			playa.sucHit = false
		$EnemyBar.max_value = mhealth
		$EnemyBar.value = health
		$EnemyBar.visible = true
		$enemyVar.visible = true
		$enemybg.visible = true

func win()-> void:
	self.hide()
	Engine.time_scale = 0
	$"../Pause".hide()
	$"../Death".hide()
	playa.health = 0
	$"../Win".show()
	$"../Win/Retry".grab_focus()
	$"../Win/Retry".disabled = false
	$"../Win/Menu".disabled = false
	$"../Win/Quit".disabled = false


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/stage.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/menu.tscn")
