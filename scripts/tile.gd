extends Node2D

@onready var button = $Button

func _ready() -> void:
	button.pressed.connect(clicked)

func _process(delta: float) -> void:
	self.position.y += 1
	if self.position.y > 748:
		queue_free()

func clicked():
	queue_free()
