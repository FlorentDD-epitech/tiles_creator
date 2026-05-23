extends Control

@onready var play_button = $PlayButton
@onready var record_button = $RecordButton
@onready var file_dialog = $FileDialog

func _ready() -> void:
	play_button.pressed.connect(play_button_pressed)
	record_button.pressed.connect(record_button_pressed)
	file_dialog.file_selected.connect(file_selected)

func play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/choose.tscn")

func record_button_pressed():
	file_dialog.popup_centered()

func file_selected(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		GlobalData.selected_music = path
		get_tree().change_scene_to_file("res://scenes/record.tscn")
	else:
		print("error")
