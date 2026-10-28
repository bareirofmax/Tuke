extends Camera2D
var follow = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if follow and get_node("../Entities/Player") != null:
		self.position.x = get_node("../Entities/Player").position.x
