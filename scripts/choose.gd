extends Control

@onready var itemL_list = $ItemList

var data_directory = "res://sounds_data/"
var list_path: Array = []

func _ready() -> void:
	itemL_list.item_activated.connect(choose_music)
	check_directory()
	_add_back_button()

func _add_back_button() -> void:
	var btn = Button.new()
	btn.text = "← Retour"
	btn.add_theme_font_size_override("font_size", 20)
	btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	btn.offset_top = -60
	btn.offset_bottom = -10
	btn.offset_left = 10
	btn.offset_right = 140
	btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	add_child(btn)

func check_directory():
	var dir = DirAccess.open(data_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				var path = data_directory + "/" + file_name
				list_path.append(path)
				itemL_list.add_item(file_name.get_basename())
			file_name = dir.get_next()
		dir.list_dir_end()

func choose_music(index: int):
	GlobalData.selected_json = list_path[index]
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
