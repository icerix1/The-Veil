extends Control

const SAVE_PATH: String = "user://settings.cfg"

const DEFAULTS: Dictionary = {
	"master_volume": 0.8,
	"music_volume": 0.7,
	"sfx_volume": 0.8,
	"fullscreen": false,
	"vsync": true,
	"screen_shake": true,
	"damage_numbers": true
}

var current_settings: Dictionary = {}

@onready var background_anim: AnimatedSprite2D = $Background
@onready var master_slider: HSlider = %MasterSlider
@onready var master_val_label: Label = %MasterValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_val_label: Label = %MusicValue
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sfx_val_label: Label = %SFXValue

@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var vsync_check: CheckButton = %VSyncCheck
@onready var shake_check: CheckButton = %ShakeCheck
@onready var damage_check: CheckButton = %DamageCheck

@onready var reset_button: Button = %ResetButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	if background_anim and background_anim.sprite_frames:
		background_anim.play("default")

	get_viewport().size_changed.connect(update_background)
	update_background()

	_ensure_audio_buses()
	_connect_signals()
	load_settings()
	_update_ui()
	apply_settings()

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

func _ensure_audio_buses() -> void:
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")

func _connect_signals() -> void:
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	shake_check.toggled.connect(_on_shake_toggled)
	damage_check.toggled.connect(_on_damage_toggled)

	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

# ==============================================================================
# SETTINGS PERSISTENCE
# ==============================================================================

func load_settings() -> void:
	current_settings = DEFAULTS.duplicate()
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for key in DEFAULTS.keys():
			current_settings[key] = config.get_value("settings", key, DEFAULTS[key])
	else:
		save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	for key in current_settings.keys():
		config.set_value("settings", key, current_settings[key])
	config.save(SAVE_PATH)

func apply_settings() -> void:
	# Audio
	_set_bus_volume("Master", current_settings["master_volume"])
	_set_bus_volume("Music", current_settings["music_volume"])
	_set_bus_volume("SFX", current_settings["sfx_volume"])

	# Display
	var is_fs: bool = current_settings["fullscreen"]
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if is_fs else DisplayServer.WINDOW_MODE_WINDOWED
	)

	var vsync_on: bool = current_settings["vsync"]
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_on else DisplayServer.VSYNC_DISABLED
	)

func _set_bus_volume(bus_name: String, vol: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_mute(idx, vol <= 0.001)
		if vol > 0.001:
			AudioServer.set_bus_volume_db(idx, linear_to_db(vol))

func _update_ui() -> void:
	master_slider.set_value_no_signal(current_settings["master_volume"])
	master_val_label.text = str(int(round(current_settings["master_volume"] * 100.0))) + "%"

	music_slider.set_value_no_signal(current_settings["music_volume"])
	music_val_label.text = str(int(round(current_settings["music_volume"] * 100.0))) + "%"

	sfx_slider.set_value_no_signal(current_settings["sfx_volume"])
	sfx_val_label.text = str(int(round(current_settings["sfx_volume"] * 100.0))) + "%"

	fullscreen_check.set_pressed_no_signal(current_settings["fullscreen"])
	vsync_check.set_pressed_no_signal(current_settings["vsync"])
	shake_check.set_pressed_no_signal(current_settings["screen_shake"])
	damage_check.set_pressed_no_signal(current_settings["damage_numbers"])

# ==============================================================================
# UI CALLBACKS
# ==============================================================================

func _on_master_changed(val: float) -> void:
	current_settings["master_volume"] = val
	master_val_label.text = str(int(round(val * 100.0))) + "%"
	_set_bus_volume("Master", val)
	save_settings()

func _on_music_changed(val: float) -> void:
	current_settings["music_volume"] = val
	music_val_label.text = str(int(round(val * 100.0))) + "%"
	_set_bus_volume("Music", val)
	save_settings()

func _on_sfx_changed(val: float) -> void:
	current_settings["sfx_volume"] = val
	sfx_val_label.text = str(int(round(val * 100.0))) + "%"
	_set_bus_volume("SFX", val)
	save_settings()

func _on_fullscreen_toggled(is_on: bool) -> void:
	current_settings["fullscreen"] = is_on
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if is_on else DisplayServer.WINDOW_MODE_WINDOWED
	)
	save_settings()
	update_background()

func _on_vsync_toggled(is_on: bool) -> void:
	current_settings["vsync"] = is_on
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if is_on else DisplayServer.VSYNC_DISABLED
	)
	save_settings()

func _on_shake_toggled(is_on: bool) -> void:
	current_settings["screen_shake"] = is_on
	save_settings()

func _on_damage_toggled(is_on: bool) -> void:
	current_settings["damage_numbers"] = is_on
	save_settings()

func _on_reset_pressed() -> void:
	current_settings = DEFAULTS.duplicate()
	save_settings()
	_update_ui()
	apply_settings()

func _on_back_pressed() -> void:
	if get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
	else:
		queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
