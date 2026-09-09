extends CanvasLayer

@onready var settings_button: Button = %SettingsButton
@onready var modal_overlay: Control = %ModalOverlay
@onready var close_button: Button = %CloseButton
@onready var music_check_button: CheckButton = %MusicCheckButton
@onready var backdrop_button: Button = %BackdropButton

func _ready() -> void:
	# Sincronizar estado inicial del conmutador de música
	var music_enabled := ProgressStore.is_music_enabled()
	music_check_button.button_pressed = music_enabled
	ProgressStore.apply_music_setting(music_enabled)

	# Ocultar panel modal inicialmente
	modal_overlay.visible = false

	# Conectar señales
	settings_button.pressed.connect(_on_settings_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	backdrop_button.pressed.connect(_on_close_button_pressed)
	music_check_button.toggled.connect(_on_music_toggled)

func _on_settings_button_pressed() -> void:
	# Actualizar el conmutador por si la preferencia cambió
	music_check_button.button_pressed = ProgressStore.is_music_enabled()
	modal_overlay.visible = true

func _on_close_button_pressed() -> void:
	modal_overlay.visible = false

func _on_music_toggled(toggled_on: bool) -> void:
	ProgressStore.set_music_enabled(toggled_on)
