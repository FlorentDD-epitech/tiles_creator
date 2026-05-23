extends Node2D

@export var lane_nodes: Array[Node2D] = []

const TILE_SCENE = preload("res://scenes/tile.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_AMPERSAND:
			spawn_tile(0)
		if event.keycode == KEY_2:
			spawn_tile(1)
		if event.keycode == KEY_QUOTEDBL:
			spawn_tile(2)
		if event.keycode == KEY_APOSTROPHE:
			spawn_tile(3)

func spawn_tile(index: int):
	var new_tile = TILE_SCENE.instantiate()
	new_tile.position.x = lane_nodes[index].position.x
	add_child(new_tile)
