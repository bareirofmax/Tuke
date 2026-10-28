extends CharacterBody2D
@export var pickupName : String
@export var healthbonus : int
@export var dmgbonus : int
@export var speedbonus : int
@export var manabonus : int
@export var psprite : String
@export var shopkeeper = false
@export var unlimited = false
@export var price : int
var flash = false
func _ready():
	if shopkeeper == true:
		$vendedor.visible = true
	if price > 0:
		$Label.text = str(price) + " Gs."
		$Label.visible = true
	if psprite != "":
		$Sprite2D.texture = load(psprite)


func _on_color_change_timeout() -> void:
	$colorChange.stop()
	if flash == false:
		$Sprite2D.modulate = Color(1, 1, 1)
		if 0 < dmgbonus:
			$Sprite2D.modulate =  Color(1, 0, 0)
		elif 0 < speedbonus:
			$Sprite2D.modulate =  Color(0, 1, 0)
		elif 0 < manabonus:
			$Sprite2D.modulate =  Color(0, 0, 1)
		flash = true
		$colorChange.wait_time = 0.25
	else:
		$colorChange.wait_time = 1
		$Sprite2D.modulate =  Color(1, 1, 1)
		flash = false
	$colorChange.start()
