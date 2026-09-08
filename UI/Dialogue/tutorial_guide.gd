# Coordinador del tutorial de bienvenida para aprendices primerizos.
# Gestiona los diálogos de Zenón, los marcadores visuales y la progresión entre edificios.
class_name TutorialGuide extends Node

signal tutorial_started
signal tutorial_completed

@export var dialogue_box_scene: PackedScene = preload("res://UI/Dialogue/dialogue_box.tscn")
@export var indicator_scene: PackedScene = preload("res://UI/Dialogue/tutorial_indicator.tscn")

var dialogue_box: DialogueBox
var indicator: TutorialIndicator
var playground: Playground

const DIALOGUES = {
	"intro": [
		"¡Bienvenido a Atenas, joven aprendiz! Soy Zenón de Citio. Estás a punto de iniciar tu camino en la filosofía estoica.",
		"Para cultivar el carácter y alcanzar la serenidad (ataraxia), debemos entrenar la mente día a día a través de cuatro grandes virtudes.",
		"Acompáñame en una breve peregrinación por nuestra polis. Primero, dirígete hacia el este, hacia [b]La Stoa[/b], el pórtico donde nos reunimos a filosofar."
	],
	"stoa": [
		"Este es el pórtico pintado, la Stoa Poikile. Aquí contemplamos el orden del cosmos y discernimos lo que está bajo nuestro control.",
		"La [b]Sabiduría[/b] (Prudencia) es el arte de distinguir lo bueno, lo indiferente y lo perjudicial, guiando cada uno de nuestros juicios con la razón.",
		"Ahora sal al ágora y visitemos [b]El Gimnasio[/b], al oeste, donde forjamos la disciplina del cuerpo y la templanza del alma."
	],
	"gym": [
		"Bienvenido a la palestra. Aquí no solo ejercitamos el cuerpo, sino la voluntad ante la adversidad.",
		"Con la [b]Fortaleza[/b] aprendemos a actuar con rectitud ante el miedo; con la [b]Templanza[/b], dominamos los impulsos y cultivamos la moderación.",
		"Por último, acompáñame a [b]El Hogar[/b], al norte, el espacio de introspección y examen de conciencia."
	],
	"home": [
		"Este es tu refugio íntimo. Cada noche, los estoicos examinamos nuestras acciones del día en nuestro diario personal.",
		"La [b]Justicia[/b] nos recuerda que no nacimos solo para nosotros, sino para convivir en concordia y servir a la comunidad humana.",
		"Has conocido los tres pilares de nuestra práctica y las cuatro virtudes cardinales.",
		"¡Has completado tu peregrinación inicial, aprendiz! Ahora portas la semilla de las cuatro virtudes. Explora Atenas con total libertad."
	]
}

var _active_step_at_dialogue: String = ""

func _ready() -> void:
	if ProgressStore.is_tutorial_completed():
		return
	
	_setup_nodes()
	LevelManager.dungeon_entered.connect(_on_dungeon_entered)
	LevelManager.dungeon_exited.connect(_on_dungeon_exited)
	
	# Iniciar el tutorial si es la primera vez
	call_deferred("_check_initial_state")

func _setup_nodes() -> void:
	if not dialogue_box and dialogue_box_scene:
		dialogue_box = dialogue_box_scene.instantiate()
		add_child(dialogue_box)
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
		dialogue_box.dialogue_started.connect(_on_dialogue_started)
	
	if not indicator and indicator_scene:
		indicator = indicator_scene.instantiate()
		if playground and playground.current_level:
			playground.current_level.add_child(indicator)
		else:
			add_child(indicator)

func _check_initial_state() -> void:
	if ProgressStore.is_tutorial_completed():
		_cleanup_tutorial()
		return
	
	var step := ProgressStore.get_tutorial_step()
	if step == "intro":
		tutorial_started.emit()
		_active_step_at_dialogue = "intro"
		if dialogue_box:
			dialogue_box.start_dialogue(DIALOGUES["intro"])
	else:
		_update_indicator_for_step(step)

func _on_dialogue_started() -> void:
	_stop_apprentice()

func _on_dialogue_finished() -> void:
	_resume_apprentice()
	
	var step := _active_step_at_dialogue
	_active_step_at_dialogue = ""
	
	if step == "intro":
		ProgressStore.advance_tutorial_step("stoa")
		_update_indicator_for_step("stoa")
	elif step == "stoa":
		ProgressStore.advance_tutorial_step("gym")
	elif step == "gym":
		ProgressStore.advance_tutorial_step("home")
	elif step == "home":
		ProgressStore.complete_tutorial()
		_cleanup_tutorial()
		tutorial_completed.emit()

func _on_dungeon_entered(dungeon: Node2D) -> void:
	if ProgressStore.is_tutorial_completed():
		return
	
	if indicator:
		indicator.hide()
	
	var current_step := ProgressStore.get_tutorial_step()
	var d_name := dungeon.name.to_lower()
	
	if current_step == "stoa" and ("stoa" in d_name or dungeon.get_script().resource_path.ends_with("stoa.gd")):
		_active_step_at_dialogue = "stoa"
		if dialogue_box:
			dialogue_box.start_dialogue(DIALOGUES["stoa"])
	elif current_step == "gym" and ("gym" in d_name or dungeon.get_script().resource_path.ends_with("gym.gd")):
		_active_step_at_dialogue = "gym"
		if dialogue_box:
			dialogue_box.start_dialogue(DIALOGUES["gym"])
	elif current_step == "home" and ("home" in d_name or dungeon.get_script().resource_path.ends_with("home.gd")):
		_active_step_at_dialogue = "home"
		if dialogue_box:
			dialogue_box.start_dialogue(DIALOGUES["home"])

func _on_dungeon_exited() -> void:
	if ProgressStore.is_tutorial_completed():
		_cleanup_tutorial()
		return
	
	var step := ProgressStore.get_tutorial_step()
	_update_indicator_for_step(step)

func _update_indicator_for_step(step: String) -> void:
	if not indicator or ProgressStore.is_tutorial_completed():
		if indicator:
			indicator.hide()
		return
	
	if LevelManager.in_dungeon():
		indicator.hide()
		return
	
	var target_node: Node2D = null
	var target_title := ""
	
	if step == "stoa" or step == "intro":
		target_node = _get_building_node("Stoa")
		target_title = "La Stoa"
	elif step == "gym":
		target_node = _get_building_node("Gym")
		target_title = "El Gimnasio"
	elif step == "home":
		target_node = _get_building_node("Home")
		target_title = "El Hogar"
	
	if target_node:
		indicator.set_destination(target_title, target_node.global_position)
	else:
		indicator.hide()

func _get_building_node(building_name: String) -> Node2D:
	if not playground:
		playground = LevelManager.playground
	if not playground or not playground.current_level:
		return null
	
	var athensLevel := playground.current_level
	var name_lower := building_name.to_lower()
	for child in athensLevel.get_children():
		if child.name.to_lower() == name_lower:
			return child as Node2D
	return null

func _stop_apprentice() -> void:
	if not playground:
		playground = LevelManager.playground
	if playground and playground.apprentice:
		playground.apprentice.is_moving_to_target = false
		playground.apprentice.direction = Vector2.ZERO
		playground.apprentice.velocity = Vector2.ZERO

func _resume_apprentice() -> void:
	pass

func _cleanup_tutorial() -> void:
	if indicator:
		indicator.hide()
		indicator.queue_free()
		indicator = null

func is_dialogue_active() -> bool:
	return dialogue_box != null and dialogue_box.is_active()
