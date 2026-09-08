class_name Apprentice extends CharacterBody2D

const SPEED = 100.0
# Ventaja del eje que ya manda al comparar magnitudes, para que las diagonales
# del joystick no hagan parpadear la animación entre lateral y vertical.
const DIRECTION_BIAS = 1.2

var cardinal_direction := Vector2.DOWN
var direction := Vector2.ZERO
var state := "idle"
var dungeon_entered = false

# Navegación por toque (Estilo Stardew Valley)
var is_moving_to_target := false
var _last_positions: Array[Vector2] = []
const STUCK_FRAME_COUNT = 10
const STUCK_THRESHOLD = 0.2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var apprentice_camera: ApprenticeCamera = $Camera2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
# @onready var back_button: TextureButton = $TouchControls/TextureButton
@onready var back_button: Button = $TouchControls/BackButton
@onready var touch_controls: CanvasLayer = $TouchControls
@onready var virtual_joystick: Control = $TouchControls/VirtualJoystick

func _ready() -> void:
	nav_agent.target_position = Vector2.ZERO
	if touch_controls:
		touch_controls.layer = 100
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	_update_touch_controls()

func _on_back_button_pressed() -> void:
	if LevelManager.in_dungeon() and LevelManager.playground.current_dungeon:
		var dungeon = LevelManager.playground.current_dungeon
		if dungeon.has_method("_on_back_button_pressed"):
			dungeon._on_back_button_pressed()

func _update_touch_controls() -> void:
	var in_dungeon = LevelManager.in_dungeon()
	if back_button:
		back_button.visible = in_dungeon
		back_button.disabled = !in_dungeon
	if virtual_joystick:
		virtual_joystick.visible = !in_dungeon

func _unhandled_input(event: InputEvent) -> void:
	if LevelManager.in_dungeon():
		return
	
	if LevelManager.playground and LevelManager.playground.tutorial_guide and LevelManager.playground.tutorial_guide.is_dialogue_active():
		return
		
	# Capturar click o toque en la pantalla que no haya sido consumido por la UI
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target_position: Vector2 = get_global_mouse_position()
			nav_agent.target_position = target_position
			
			is_moving_to_target = true

func _process(delta: float) -> void:
	_update_touch_controls()

	if !LevelManager.in_dungeon():
		if dungeon_entered: dungeon_entered = false

		var input_dir := Vector2.ZERO
		var is_dialogue := false
		if LevelManager.playground and LevelManager.playground.tutorial_guide:
			is_dialogue = LevelManager.playground.tutorial_guide.is_dialogue_active()

		if is_dialogue:
			is_moving_to_target = false
			_last_positions.clear()
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
		else:
			# Leer controles físicos o Joystick virtual
			input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
			input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")


		
		if input_dir.length_squared() > 0.05:
			# Si se detecta entrada manual del joystick o teclado, se cancela el Tap-to-Move de inmediato
			is_moving_to_target = false
			_last_positions.clear()
			direction = input_dir.normalized()
			velocity = direction * SPEED
		elif is_moving_to_target:
			# Mover hacia la posición marcada por toque
			var to_target := nav_agent.target_position - global_position
			var to_local_target := to_local(nav_agent.get_next_path_position())
			
			# Registrar posición para detectar bloqueos contra paredes/obstáculos
			_last_positions.append(global_position)
			if _last_positions.size() > STUCK_FRAME_COUNT:
				_last_positions.pop_front()
			
			var is_stuck := false
			if _last_positions.size() == STUCK_FRAME_COUNT:
				var min_x := _last_positions[0].x
				var max_x := _last_positions[0].x
				var min_y := _last_positions[0].y
				var max_y := _last_positions[0].y
				for pos in _last_positions:
					min_x = min(min_x, pos.x)
					max_x = max(max_x, pos.x)
					min_y = min(min_y, pos.y)
					max_y = max(max_y, pos.y)
				if (max_x - min_x) < STUCK_THRESHOLD and (max_y - min_y) < STUCK_THRESHOLD:
					is_stuck = true
			
			if to_target.length() < 4.0 or nav_agent.is_navigation_finished() or is_stuck:
				is_moving_to_target = false
				_last_positions.clear()
				direction = Vector2.ZERO
				velocity = Vector2.ZERO
			else:
				direction = to_local_target.normalized()
				# Escalar la velocidad para prevenir sobretiros (overshoot) y evitar temblores por desfase
				var target_speed: float = min(SPEED, to_target.length() / delta)
				velocity = direction * target_speed
		else:
			_last_positions.clear()
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
	else:
		is_moving_to_target = false
		_last_positions.clear()
		velocity = Vector2.ZERO
		if !dungeon_entered:
			direction = -direction
			dungeon_entered = true
		
	# Sin cortocircuito: al empezar a andar cambian estado y dirección a la vez,
	# y saltarse setDirection() dejaba un frame con la animación del cardinal viejo.
	var state_changed := setState()
	var direction_changed := setDirection()
	if state_changed || direction_changed:
		updateAnimation()

func _physics_process(_delta: float) -> void:
	if LevelManager.in_dungeon():
		velocity = Vector2.ZERO
		is_moving_to_target = false
		_last_positions.clear()
		nav_agent.target_position = global_position
	move_and_slide()

func setDirection() -> bool:
	var new_dir := cardinal_direction
	if direction == Vector2.ZERO:
		return false

	# Con el joystick virtual casi nunca hay un eje exactamente a cero, así que
	# la animación la decide el eje de mayor magnitud, no la simple presencia
	# de componente vertical.
	var horizontal: bool
	if cardinal_direction == Vector2.LEFT || cardinal_direction == Vector2.RIGHT:
		horizontal = absf(direction.x) * DIRECTION_BIAS >= absf(direction.y)
	else:
		horizontal = absf(direction.x) >= absf(direction.y) * DIRECTION_BIAS

	if horizontal:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN

	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	return true

func setState() -> bool:
	var new_state := "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	
	state = new_state
	return true

func updateAnimation() -> void:
	animated_sprite_2d.play(state + "_" + animDirection())

func animDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "south"
	elif cardinal_direction == Vector2.UP:
		return "north"
	elif cardinal_direction == Vector2.RIGHT:
		return "east"
	else:
		return "west"
