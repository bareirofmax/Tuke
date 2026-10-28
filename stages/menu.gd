extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Language/Esp.grab_focus()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	$Main.hide()
	$HowToPlay1/Next.grab_focus()
	$HowToPlay1.show()

func _on_glossary_pressed() -> void:
	$Main.hide()
	$Glosario/VBoxContainer/Characters.grab_focus()
	$Glosario/VBoxContainer/Intro.disabled = true
	$Glosario.show()
	$Glosario/Characters.hide()
	$Glosario/Pickups.hide()
	$Glosario/Stages.hide()
	$Glosario/Intro.show()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	$HowToPlay1.hide()
	$HowToPlay2.hide()
	$Main/Play.grab_focus()
	$Main.show()

func _on_enter_level_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/stage.tscn")


func _on_next_pressed() -> void:
	$HowToPlay1.hide()
	$HowToPlay2/EnterLevel.grab_focus()
	$HowToPlay2.show()


func _on_esp_pressed() -> void:
	TranslationServer.set_locale("es")
	$Language.hide()
	$Main.show()
	$Main/Play.grab_focus()



func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")
	$Language.hide()
	$Main.show()
	$Main/Play.grab_focus()
