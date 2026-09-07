# Cuadro de diálogo estilo RPG clásico para interactuar con mentores (Zenón)
# y presentar el tutorial guiado de forma inmersiva y responsive.
class_name DialogueBox extends CanvasLayer

signal dialogue_started
signal dialogue_finished
signal line_changed(line_index: int)

@onready var root_control: Control = %RootControl
@onready var backdrop_button: Button = %BackdropButton
@onready var portrait_rect: TextureRect = %PortraitRect
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var prompt_indicator: Label = %PromptIndicator

@export var default_portrait: Texture2D = preload("res://Zeno/Sprites/frame_000.png")

var _lines: Array = []
var _current_line_index: int = 0
var _is_active: bool = false
var _is_typing: bool = false
var _type_speed: float = 0.02

var _base_font_sizes: Dictionary = {}
var _current_scale_factor: float = 1.0

func _ready() -> void:
	layer = 110
	_ensure_nodes()
	if backdrop_button:
		backdrop_button.pressed.connect(_on_backdrop_pressed)
	
	_cache_base_font_sizes(root_control if root_control else self)
	_apply_font_scale()
	
	hide_dialogue()

func _ensure_nodes() -> void:
	if not root_control and has_node("%RootControl"):
		root_control = %RootControl
	if not backdrop_button and has_node("%BackdropButton"):
		backdrop_button = %BackdropButton
	if not portrait_rect and has_node("%PortraitRect"):
		portrait_rect = %PortraitRect
	if not speaker_label and has_node("%SpeakerLabel"):
		speaker_label = %SpeakerLabel
	if not text_label and has_node("%TextLabel"):
		text_label = %TextLabel
	if not prompt_indicator and has_node("%PromptIndicator"):
		prompt_indicator = %PromptIndicator

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
	
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_X]:
			get_viewport().set_input_as_handled()
			advance()
	elif event is InputEventScreenTouch and event.pressed:
		get_viewport().set_input_as_handled()
		advance()

func start_dialogue(lines: Array, speaker: String = "Zenón de Citio", portrait: Texture2D = null) -> void:
	if lines.is_empty():
		return
	
	_ensure_nodes()
	_lines = lines
	_current_line_index = 0
	_is_active = true
	
	if speaker_label:
		speaker_label.text = speaker
	
	if portrait_rect:
		portrait_rect.texture = portrait if portrait else default_portrait
	
	show_dialogue()
	_show_current_line()
	dialogue_started.emit()

func advance() -> void:
	if not _is_active:
		return
	
	# Si todavía está mostrando la animación de texto rápido, completar de golpe
	if _is_typing:
		_is_typing = false
		if text_label:
			text_label.visible_ratio = 1.0
		return
	
	_current_line_index += 1
	if _current_line_index < _lines.size():
		_show_current_line()
	else:
		close()

func _show_current_line() -> void:
	_ensure_nodes()
	if _current_line_index < 0 or _current_line_index >= _lines.size():
		return
	
	var line_text: String = str(_lines[_current_line_index])
	if text_label:
		text_label.text = line_text
		text_label.visible_ratio = 0.0
		_is_typing = true
		_animate_typewriter()
	
	line_changed.emit(_current_line_index)

func _animate_typewriter() -> void:
	if not is_inside_tree():
		if text_label:
			text_label.visible_ratio = 1.0
		_is_typing = false
		return
		
	var tween := create_tween()
	var duration: float = max(0.25, min(1.2, text_label.text.length() * _type_speed))
	tween.tween_property(text_label, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func():
		_is_typing = false
	)

func close() -> void:
	_is_active = false
	_is_typing = false
	hide_dialogue()
	dialogue_finished.emit()

func show_dialogue() -> void:
	_ensure_nodes()
	if root_control:
		root_control.visible = true

func hide_dialogue() -> void:
	_ensure_nodes()
	if root_control:
		root_control.visible = false

func is_active() -> bool:
	return _is_active

func set_font_scale(scale_factor: float) -> void:
	_current_scale_factor = scale_factor
	if is_inside_tree():
		_apply_font_scale()

func _cache_base_font_sizes(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			if not _base_font_sizes.has(child):
				var base_size := (child as Control).get_theme_font_size("font_size")
				if base_size > 0:
					_base_font_sizes[child] = base_size
		_cache_base_font_sizes(child)

func _apply_font_scale() -> void:
	for control in _base_font_sizes.keys():
		if is_instance_valid(control):
			var base_size: int = _base_font_sizes[control]
			var scaled_size := int(round(base_size * _current_scale_factor))
			(control as Control).add_theme_font_size_override("font_size", scaled_size)

func _on_backdrop_pressed() -> void:
	advance()
