extends Control

@onready var play_button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(play_button_pressed)

func play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
