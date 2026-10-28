extends CharacterBody2D
class_name projectile
var SPEED = 1000
var sender : String
var direction : int
var pos : Vector2
var Damage : int
var psprite : String
func _ready():
	global_position = pos
	if psprite != "":
		$Sprite2D.texture = load(psprite)

func death():
	velocity.x = 0
	velocity.y = 0
	queue_free()

func _physics_process(_delta: float) -> void: 
	if direction:
			velocity.x = SPEED * direction
	if is_on_wall() or is_on_wall():
		death()
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().get_script().get_global_name())
	if area.name == "Hitbox" && (area.get_parent().get_script().get_global_name() != sender):
		area.get_parent().get_node("hitstun").start()
		area.get_parent().hurt(Damage, direction == 1, 8, false)
		$AudioStreamPlayer2D.play()
		if sender == "Player":
			get_parent().get_node(sender).combo(false)
			get_parent().get_node(sender).enemy_focus.emit(area.get_parent().uiName,area.get_parent().health,area.get_parent().swaps[area.get_parent().swaplvl].Health)
