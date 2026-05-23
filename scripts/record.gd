extends Control

@onready var stream_player = $AudioStreamPlayer
@onready var label = $Label

var tile_list : Array = []
var recording : bool = false

func _ready() -> void:
	var file = FileAccess.open(GlobalData.selected_music, FileAccess.READ)
	if file:
		var bytes = file.get_buffer(file.get_length())
		var mp3_stream = AudioStreamMP3.new()
		mp3_stream.data = bytes
		stream_player.stream = mp3_stream
		stream_player.finished.connect(save_json)
		start_record()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func start_record():
	label.text = "3"
	await  get_tree().create_timer(1).timeout
	label.text = "2"
	await  get_tree().create_timer(1).timeout
	label.text = "1"
	await  get_tree().create_timer(1).timeout
	label.text = "RECORDING"
	recording = true
	stream_player.play()

func _input(event: InputEvent) -> void:
	if !recording:
		return
	var valid_input = false
	var actual_time = stream_player.get_playback_position()
	var lane = 0
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_AMPERSAND:
			lane = 0
			valid_input = true
		if event.keycode == KEY_2:
			lane = 1
			valid_input = true
		if event.keycode == KEY_QUOTEDBL:
			lane = 2
			valid_input = true
		if event.keycode == KEY_APOSTROPHE:
			lane = 3
			valid_input = true
	if valid_input:
		var new_note = {
			"time": actual_time,
			"lane": lane
		}
		tile_list.append(new_note)

func save_json():
	var json_prefix = {
		"background-texture" : "res://assets/bleu.png",
		"tile-texture" : "res://assets/noir.png",
		"music-path" : GlobalData.selected_music,
		"data" : tile_list
	}
	var json_data = JSON.stringify(json_prefix, "\t")
	var file_path = "res://sounds_data/" + GlobalData.selected_music.get_basename().get_file() + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_data)
		file.close()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
