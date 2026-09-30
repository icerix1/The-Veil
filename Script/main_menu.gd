extends Control

@export var PlayButtonLabel : Label
@export var SettingsButtonLabel : Label
@export var QuitButtonLabel : Label

@onready var background_anim: AnimatedSprite2D = $Background

var label_tweens : Dictionary = {}

func _ready() -> void:
	get_viewport().size_changed.connect(update_background)
	update_background()

func update_background() -> void:
	if not background_anim or not background_anim.sprite_frames:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var frame_tex: Texture2D = background_anim.sprite_frames.get_frame_texture("default", 0)
	if not frame_tex:
		return
	var texture_size: Vector2 = frame_tex.get_size()
	var scale_factor: float = maxf(
		viewport_size.x / texture_size.x,
		viewport_size.y / texture_size.y
	)
	background_anim.scale = Vector2.ONE * scale_factor
	background_anim.position = viewport_size / 2.0

func tween_label(label: Label, target_scale: Vector2, color: Color, duration: float) -> void:
	if label_tweens.has(label) and label_tweens[label].is_running():
		label_tweens[label].kill()
		
	var tween = create_tween().set_parallel(true)
	label_tweens[label] = tween
	
	tween.tween_property(label, "scale", target_scale, duration)
	
	if label.label_settings:
		label.label_settings = label.label_settings.duplicate()
		tween.tween_property(label.label_settings, "font_color", color, duration)

#Entered
func _on_play_button_mouse_entered() -> void:
	tween_label(PlayButtonLabel, Vector2(1.15, 1.15), Color("c8c8c8ff"), 0.1)

func _on_setting_button_mouse_entered() -> void:
	tween_label(SettingsButtonLabel, Vector2(1.15, 1.15), Color("c8c8c8ff"), 0.1)

func _on_quit_button_mouse_entered() -> void:
	tween_label(QuitButtonLabel, Vector2(1.15, 1.15), Color("c8c8c8ff"), 0.1)

#Exited
func _on_play_button_mouse_exited() -> void:
	tween_label(PlayButtonLabel, Vector2(1.0, 1.0), Color("ffffffff"), 0.2)

func _on_setting_button_mouse_exited() -> void:
	tween_label(SettingsButtonLabel, Vector2(1.0, 1.0), Color("ffffffff"), 0.2)

func _on_quit_button_mouse_exited() -> void:
	tween_label(QuitButtonLabel, Vector2(1.0, 1.0), Color("ffffffff"), 0.2)


#main menu logic


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main_game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_setting_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/settings_menu.tscn")
