extends Control

@onready var stream_player = $AudioStreamPlayer
@onready var label = $Label

const HALF_W = 576.0
const HALF_H = 324.0
const AUTO_LANES = 4
const MIN_BEAT_INTERVAL = 0.15

var tile_list: Array = []
var recording: bool = false
var audio_bytes: PackedByteArray = []

var choice_container: Control
var bpm_container: Control
var bpm_input: LineEdit
var bpm_error_label: Label

func _ready() -> void:
	var file = FileAccess.open(GlobalData.selected_music, FileAccess.READ)
	if file:
		audio_bytes = file.get_buffer(file.get_length())
		var mp3_stream = AudioStreamMP3.new()
		mp3_stream.data = audio_bytes
		stream_player.stream = mp3_stream
		stream_player.finished.connect(save_json)
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return

	_build_ui()
	_show_choice()

func _build_ui() -> void:

	choice_container = Control.new()
	choice_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	choice_container.visible = false
	add_child(choice_container)

	var title = Label.new()
	title.text = "Choisir un mode"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title.offset_top = -120
	title.offset_bottom = -60
	title.offset_left = -250
	title.offset_right =  250
	choice_container.add_child(title)

	var auto_btn = Button.new()
	auto_btn.text = "🎵  Auto-map par BPM"
	auto_btn.add_theme_font_size_override("font_size", 22)
	auto_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	auto_btn.offset_top = -40
	auto_btn.offset_bottom =  10
	auto_btn.offset_left = -160
	auto_btn.offset_right =  160
	auto_btn.pressed.connect(_show_bpm_input)
	choice_container.add_child(auto_btn)

	var manual_btn = Button.new()
	manual_btn.text = "🎹  Enregistrement manuel"
	manual_btn.add_theme_font_size_override("font_size", 22)
	manual_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	manual_btn.offset_top =  25
	manual_btn.offset_bottom =  75
	manual_btn.offset_left = -160
	manual_btn.offset_right =  160
	manual_btn.pressed.connect(_start_manual_record)
	choice_container.add_child(manual_btn)

	bpm_container = Control.new()
	bpm_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bpm_container.visible = false
	add_child(bpm_container)

	var bpm_title = Label.new()
	bpm_title.text = "BPM de la musique ?"
	bpm_title.add_theme_font_size_override("font_size", 28)
	bpm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bpm_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bpm_title.offset_top = -110
	bpm_title.offset_bottom =  -60
	bpm_title.offset_left = -220
	bpm_title.offset_right =  220
	bpm_container.add_child(bpm_title)

	bpm_input = LineEdit.new()
	bpm_input.placeholder_text = "ex: 128"
	bpm_input.add_theme_font_size_override("font_size", 30)
	bpm_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bpm_input.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bpm_input.offset_top = -45
	bpm_input.offset_bottom = 5
	bpm_input.offset_left = -100
	bpm_input.offset_right =  100
	bpm_container.add_child(bpm_input)

	var confirm_btn = Button.new()
	confirm_btn.text = "Générer les notes ✓"
	confirm_btn.add_theme_font_size_override("font_size", 22)
	confirm_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	confirm_btn.offset_top = 20
	confirm_btn.offset_bottom = 70
	confirm_btn.offset_left = -140
	confirm_btn.offset_right = 140
	confirm_btn.pressed.connect(_generate_from_bpm)
	bpm_container.add_child(confirm_btn)

	var hint = Label.new()
	hint.text = "Electro/House: 128  •  Hip-hop: 90  •  Pop: 100-120  •  Drum&Bass: 174"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	hint.offset_top = 85
	hint.offset_bottom = 115
	hint.offset_left = -300
	hint.offset_right = 300
	bpm_container.add_child(hint)

	bpm_error_label = Label.new()
	bpm_error_label.add_theme_font_size_override("font_size", 18)
	bpm_error_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	bpm_error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bpm_error_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bpm_error_label.offset_top = 120
	bpm_error_label.offset_bottom = 150
	bpm_error_label.offset_left = -200
	bpm_error_label.offset_right = 200
	bpm_error_label.visible = false
	bpm_container.add_child(bpm_error_label)

func _show_choice() -> void:
	label.visible = false
	choice_container.visible = true
	bpm_container.visible = false

func _show_bpm_input() -> void:
	choice_container.visible = false
	bpm_container.visible = true
	bpm_error_label.visible  = false
	bpm_input.text = ""
	bpm_input.grab_focus()

func _start_manual_record() -> void:
	choice_container.visible = false
	bpm_container.visible = false
	_do_countdown()

func _do_countdown() -> void:
	label.visible = true
	label.text = "3"
	await get_tree().create_timer(1).timeout
	label.text = "2"
	await get_tree().create_timer(1).timeout
	label.text = "1"
	await get_tree().create_timer(1).timeout
	label.text = "●"
	recording = true
	stream_player.play()

func _generate_from_bpm() -> void:
	var bpm = bpm_input.text.strip_edges().to_float()
	if bpm <= 0:
		bpm_error_label.text = "BPM invalide, entre un nombre positif !"
		bpm_error_label.visible = true
		return

	bpm_container.visible = false
	label.visible = true
	label.text = "..."
	await get_tree().process_frame

	tile_list.clear()

	stream_player.play()
	await get_tree().create_timer(0.1).timeout
	var duration = stream_player.stream.get_length()
	stream_player.stop()

	if duration <= 0.0:
		label.text = "Erreur durée"
		await get_tree().create_timer(2.0).timeout
		_do_countdown()
		return

	var beat_interval = 60.0 / bpm
	var current_time = beat_interval
	var lane_pattern = [0, 2, 1, 3, 0, 3, 1, 2, 0, 1, 3, 2]
	var pattern_index = 0

	while current_time < duration - beat_interval:
		tile_list.append({
			"time": current_time,
			"lane": lane_pattern[pattern_index % lane_pattern.size()]
		})
		pattern_index += 1
		current_time += beat_interval

	label.text = str(tile_list.size()) + " notes  (BPM " + str(int(bpm)) + ")"
	await get_tree().create_timer(1.5).timeout
	save_json()

func _input(event: InputEvent) -> void:
	if !recording:
		return
	var actual_time = stream_player.get_playback_position()
	var lane = -1
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_AMPERSAND:  
			lane = 0
		elif event.keycode == KEY_2:          
			lane = 1
		elif event.keycode == KEY_QUOTEDBL:   
			lane = 2
		elif event.keycode == KEY_APOSTROPHE: 
			lane = 3
	if lane >= 0:
		tile_list.append({"time": actual_time, "lane": lane})

func save_json() -> void:
	recording = false
	var json_prefix = {
		"background-texture": "res://assets/bleu.png",
		"tile-texture": "res://assets/noir.png",
		"music-path": GlobalData.selected_music,
		"data": tile_list
	}
	var file_path = "res://sounds_data/" + GlobalData.selected_music.get_basename().get_file() + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(json_prefix, "\t"))
		file.close()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
