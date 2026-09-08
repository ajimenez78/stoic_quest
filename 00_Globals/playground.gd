class_name Playground extends Node2D

@export var current_level: Node2D
@onready var apprentice: Apprentice = $Apprentice
var current_dungeon
var tutorial_guide: TutorialGuide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.playground = self
	_setup_tutorial_guide()

func _setup_tutorial_guide() -> void:
	if not ProgressStore.is_tutorial_completed():
		tutorial_guide = TutorialGuide.new()
		tutorial_guide.name = "TutorialGuide"
		add_child(tutorial_guide)
