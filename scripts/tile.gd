extends Node2D

signal tile_missed
signal tile_hit

@onready var button = $Button

const TILE_HALF_HEIGHT = 50.0

var death_line_global_y: float = 487.0

func _ready() -> void:
	button.pressed.connect(clicked)

func _process(delta: float) -> void:
	self.position.y += 1
	if self.global_position.y + TILE_HALF_HEIGHT >= death_line_global_y:
		tile_missed.emit()
		queue_free()

func clicked():
	tile_hit.emit()
	queue_free()
