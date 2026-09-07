# Indicador visual flotante que señala el edificio de destino durante el tutorial.
class_name TutorialIndicator extends Node2D

@onready var label: Label = $Container/Label
@onready var arrow: Label = $Container/Arrow
@onready var container: Node2D = $Container

var _base_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_base_y = container.position.y

func _process(delta: float) -> void:
	_time += delta
	# Animación suave de flotación vertical
	container.position.y = _base_y + sin(_time * 4.0) * 5.0

func set_destination(dest_name: String, target_global_pos: Vector2) -> void:
	global_position = target_global_pos + Vector2(0, -60)
	if label:
		label.text = "✦ %s ✦" % dest_name.to_upper()
	show()
