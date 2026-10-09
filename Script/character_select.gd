extends Control

var selected_character_ = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Character Select Ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_male_cac_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Male selected")
		selected_character_ = "male"
		update_selection()


func _on_female_cac_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Female selected")
		selected_character_ = "female"
		update_selection()
		

func update_selection():
	$CharacterRow/MaleCac.modulate = Color(1,1,1)
	$CharacterRow/FemaleCac.modulate = Color(1,1,1)
	if selected_character_ == "male":
		$CharacterRow/FemaleCac.modulate = Color(0.4, 0.4, 0.4)
	if selected_character_ == "female":
		$CharacterRow/MaleCac.modulate = Color(0.4, 0.4, 0.4)


func _on_confirm_button_pressed() -> void:
	if selected_character_ == "":
		print("No Character selected yet")
		return
	print("Confirmed: " + selected_character_)
	GameManager.selected_character = selected_character_
	get_tree().change_scene_to_file("res://Scene/main_game.tscn")
