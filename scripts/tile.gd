extends Node2D

signal tile_missed
signal tile_hit

@onready var button = $Button

const TILE_HALF_HEIGHT = 50.0

# Position Y GLOBALE de la Line2D, passée depuis game_scene au spawn
var death_line_global_y: float = 487.0

func _ready() -> void:
	button.pressed.connect(clicked)

func _process(delta: float) -> void:
	self.position.y += 1
	# Le bas de la tile = global_position.y + TILE_HALF_HEIGHT
	if self.global_position.y + TILE_HALF_HEIGHT >= death_line_global_y:
		tile_missed.emit()
		queue_free()

func clicked():
	tile_hit.emit()
	queue_free()
