extends Node2D

signal tile_missed
signal tile_hit(distance: float)

@onready var button = $Button

const TILE_HALF_HEIGHT = 50.0

var death_line_global_y: float = 487.0
var speed: float = 1.0

func _ready() -> void:
	button.pressed.connect(clicked)

func _process(delta: float) -> void:
	self.position.y += speed
	var screen_bottom = get_viewport_rect().size.y
	if self.global_position.y - TILE_HALF_HEIGHT >= screen_bottom:
		tile_missed.emit()
		queue_free()

func clicked():
	var distance = abs(self.global_position.y + TILE_HALF_HEIGHT - death_line_global_y)
	_spawn_hit_effect(distance)
	tile_hit.emit(distance)
	queue_free()

func _spawn_hit_effect(distance: float) -> void:
	var judgment = _get_judgment(distance)
	var lbl = Label.new()
	lbl.text = judgment.text
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", judgment.color)
	lbl.z_index = 30
	lbl.global_position = self.global_position + Vector2(-30, -60)
	get_parent().add_child(lbl)
	var tw = lbl.create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 60.0, 0.5)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)

func _get_judgment(distance: float) -> Dictionary:
	if distance < 20.0:
		return {"text": "PERFECT", "color": Color(1.0, 0.92, 0.1)}
	elif distance < 55.0:
		return {"text": "GOOD", "color": Color(0.3, 1.0, 0.4)}
	else:
		return {"text": "BAD", "color": Color(1.0, 0.35, 0.35)}
