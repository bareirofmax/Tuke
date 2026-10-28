extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible == true and Input.is_action_just_pressed("Pause"):
		$"../Main".show()
		self.visible = false
		$"../Main/Glossary".grab_focus()
		for item in $VBoxContainer.get_children():
			if item.name == "Intro":
				item.disabled = true
			else:
				item.disabled = false
		$Characters.visible = false
		$Pickups.visible = false
		$Stages.visible = false
		$Intro.visible = true

func _on_characters_pressed() -> void:
	for item in $VBoxContainer.get_children():
		if item.name == "Characters":
			item.disabled = true
		else:
			item.disabled = false
	$Characters.visible = true
	$Pickups.visible = false
	$Stages.visible = false
	$Intro.visible = false

func _on_pickups_pressed() -> void:
	for item in $VBoxContainer.get_children():
		if item.name == "Pickups":
			item.disabled = true
		else:
			item.disabled = false
	$Characters.visible = false
	$Pickups.visible = true
	$Stages.visible = false
	$Intro.visible = false

func _on_stages_pressed() -> void:
	for item in $VBoxContainer.get_children():
		if item.name == "Stages":
			item.disabled = true
		else:
			item.disabled = false
	$Characters.visible = false
	$Pickups.visible = false
	$Stages.visible = true
	$Intro.visible = false

func _on_intro_pressed() -> void:
	for item in $VBoxContainer.get_children():
		if item.name == "Intro":
			item.disabled = true
		else:
			item.disabled = false
	$Characters.visible = false
	$Pickups.visible = false
	$Stages.visible = false
	$Intro.visible = true
