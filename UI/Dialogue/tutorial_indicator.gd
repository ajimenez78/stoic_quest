# Indicador visual flotante que señala el edificio de destino durante el tutorial.
class_name TutorialIndicator extends Node2D

@onready var label: Label = $Container/Panel/Margin/Label
@onready var arrow: Label = $Container/Arrow

@onready var container: Node2D = $Container

var _base_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_base_y = container.position.y
	_update_responsive_scale()

func _update_responsive_scale() -> void:
	var is_mobile := OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	var viewport_size := get_viewport().get_visible_rect().size if get_viewport() else Vector2.ZERO
	if is_mobile or (viewport_size.x > 0 and viewport_size.x < 768.0):
		if label:
			label.add_theme_font_size_override("font_size", 18)
		if arrow:
			arrow.add_theme_font_size_override("font_size", 22)

func _process(delta: float) -> void:
	_time += delta
	# Animación suave de flotación vertical
	container.position.y = _base_y + sin(_time * 4.0) * 5.0

func set_destination(dest_name: String, target_global_pos: Vector2) -> void:
	global_position = target_global_pos + Vector2(0, -60)
	if label:
		label.text = "✦ %s ✦" % dest_name.to_upper()
	show()
