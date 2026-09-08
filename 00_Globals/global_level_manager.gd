extends Node

var current_tilemap_bounds: Array[Vector2]
var playground: Playground

signal TileMapBoundsChanged(bounds: Array[Vector2])
signal dungeon_entered(dungeon: Node2D)
signal dungeon_exited

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	TileMapBoundsChanged.emit(bounds)
	
func enter_dungeon(new_dungeon: Node2D) -> void:
	if !playground.current_dungeon:
		playground.add_child(new_dungeon)

		# Position dungeon at the camera's actual position (viewport center)
		var apprentice = playground.apprentice
		if apprentice:
			var camera = apprentice.apprentice_camera
			if camera:
				# Use camera's global position (actual viewport center)
				new_dungeon.global_position = camera.get_screen_center_position()
			else:
				# Fallback to apprentice position
				new_dungeon.global_position = apprentice.global_position

		playground.current_dungeon = new_dungeon
		dungeon_entered.emit(new_dungeon)

func exit_dungeon() -> void:
	if playground.current_dungeon:
		var _exited_dungeon = playground.current_dungeon
		playground.remove_child(playground.current_dungeon)
		playground.current_dungeon = null
		dungeon_exited.emit()

func in_dungeon() -> bool:
	return playground != null and playground.current_dungeon != null
