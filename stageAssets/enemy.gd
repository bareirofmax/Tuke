class_name enemy
extends character
var uiName = "Default"
@export var playa : player
var posRand = Vector2.ZERO
var walkcool = true
@export var swaplvl = 0
@export var swapuse = false
var sfx = {
"Hit":"res://sounds/punch.mp3",
"Hurt":"res://sounds/explosion.mp3",
"Die":"res://sounds/hurt.mp3",
}
signal enemy_kill
func ai_input() -> void:
	pass
func _on_idlereset_timeout() -> void:
	pass

func animations() ->void:
	pass
func _on_hurtbox_area_entered(_area: Area2D) -> void:
	pass
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
