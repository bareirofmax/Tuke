extends CharacterBody2D
class_name character
@export var health : int
@export var damage : int
@export var speed : float
enum State {IDLE, WALK, HURT, ATTACK, SPEC1, SPEC2, SPEC3, SPEC4}
var state = State.IDLE
var atkcool = false
var hurcool = false
var knockback = Vector2.ZERO
var knocksum = 0.0
var selfcombo = 0
@onready var oghitstun = $hitstun.wait_time
signal health_changed
func _ready() -> void:
	pass
#the code structure for ai_input, movement and animations was adapted from The GameDev Tavern's video www.youtube.com/watch?v=Y5i42mZTO4M&list=PLNNbuBNHHbNGtZjygmnJ2fBvp6JmDNkAm&index=1
func _process(_delta: float) -> void:
	if Engine.time_scale == 1: 
		ai_input()
		movement()
		animations()
	move_and_slide()

func movement() -> void:
	knockback = knockback.lerp(Vector2.ZERO, 0.1)
	if knockback.x != 0 and get_slide_collision_count() > 0 and is_on_floor() == false and is_on_ceiling() == false:
		var collision = get_slide_collision(0)
		if sign(knockback.x) != sign(collision.get_normal().x):
			#print("wallbounce")
			if self.name == "Player":
				knockback.x = knockback.x * -1.5
			else:
				knockback.x = knockback.x * -1.1
			if $hitstun.wait_time > 0.1:
				$hitstun.wait_time = $hitstun.wait_time - 0.1
			knocksum = 0.0
	if atkcool == false and hurcool == false:
		if velocity == Vector2(0,0):
			state = State.IDLE
		else:
			state = State.WALK

func hurt(ouchdmg : int ,dir : bool, knockinc: float, stack : bool) -> void: #knccksum stores all knockincrements if the stack variable is applied
	for item in $Hurtbox.get_children():
		item.set_deferred("disabled", true)
	if stack:
		knocksum = knocksum + knockinc
	print(knocksum)
	selfcombo = selfcombo + 1
	$Hitbox/hitspark.play("default")
	$Hitbox/hitspark.scale.x = 1 + float(selfcombo)/2
	$Hitbox/hitspark.scale.y = 1 + float(selfcombo)/2
	state = State.HURT
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
				knockback = knockinc * Vector2(100,0)
	#print(selfcombo)
	if $hitstun.wait_time > 0.1:
		$hitstun.wait_time = $hitstun.wait_time - 0.1
	health_changed.emit()
	if health <= 0:
		death(knockback)

func animations() -> void:
	pass

func ai_input() -> void:
	pass

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	pass

func _on_hitstun_timeout() -> void:
	if health > 0:
		atkcool = false
		hurcool = false
	for item in $Hurtbox.get_children():
		item.disabled = true
	knockback = Vector2.ZERO
	knocksum = 0.0
	selfcombo = 0
	$hitstun.wait_time = oghitstun

func death(_knock : Vector2) -> void:
	pass
