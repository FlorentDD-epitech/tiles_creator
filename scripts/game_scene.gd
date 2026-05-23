extends Control

@onready var stream_player = $AudioStreamPlayer
@onready var node2d = $Node2D

@export var lane_nodes: Array[Node2D] = []

const TILE_SCENE = preload("res://scenes/tile.tscn")
const TIME_TO_TRAVEL = 4

var json_data = null
var tile_list: Array = []
var timer = 0.0

func _ready() -> void:
	var file = FileAccess.open(GlobalData.selected_json, FileAccess.READ)
	if file:
		json_data = JSON.parse_string(file.get_as_text())
		file.close()
		tile_list = json_data.get("data", [])
		init_music()
	if json_data == null:
		print("invalid json")
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _process(delta: float) -> void:
	if tile_list.is_empty():
		return
	var prochaine_note = tile_list[0]
	
	if !stream_player.playing:
		timer += delta
		if timer >= TIME_TO_TRAVEL:
			stream_player.play()
	else:
		timer = stream_player.get_playback_position() + TIME_TO_TRAVEL
	
	if prochaine_note["time"] <= timer:
		spawn_tile(prochaine_note["lane"])
		tile_list.remove_at(0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/choose.tscn")

func spawn_tile(index: int):
	var new_tile = TILE_SCENE.instantiate()
	new_tile.position.x = lane_nodes[index].position.x
	node2d.add_child(new_tile)

func init_music():
	var music_path = json_data.get("music-path", "")
	var file = FileAccess.open(music_path, FileAccess.READ)
	if file:
		var stream_mp3 = AudioStreamMP3.new()
		stream_mp3.data = file.get_buffer(file.get_length())
		stream_player.stream = stream_mp3
	else:
		print("Invalid json")
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
