extends Control

@onready var stream_player = $AudioStreamPlayer
@onready var node2d = $Node2D
@onready var death_line = $Line2D

@export var lane_nodes: Array[Node2D] = []

const TILE_SCENE = preload("res://scenes/tile.tscn")
const TIME_TO_TRAVEL = 4

# Le Control est centré, son origine locale = centre de l'écran
# Résolution : 1152x648 → demi-tailles : 576 x 324
# Node2D est à position.y = -324 (haut de l'écran en local)
const HALF_W = 576.0
const HALF_H = 324.0

var json_data = null
var tile_list: Array = []
var timer = 0.0

var lives: int = 3
var combo: int = 0
var combo_tween: Tween = null

var heart_labels: Array[Label] = []
var combo_label: Label
var combo_counter_label: Label
var game_over_panel: Panel

func _ready() -> void:
	_build_ui()

	var file = FileAccess.open(GlobalData.selected_json, FileAccess.READ)
	if file:
		json_data = JSON.parse_string(file.get_as_text())
		file.close()
		tile_list = json_data.get("data", [])
		init_music()
	if json_data == null:
		print("invalid json")
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

	update_hearts()

func _build_ui() -> void:
	# Le Control est ancré au centre → position (0,0) = centre écran
	# Coin haut-gauche = (-576, -324), coin haut-droit = (576, -324)

	# --- Cœurs : haut droit ---
	for i in range(3):
		var lbl = Label.new()
		lbl.text = "❤"
		lbl.add_theme_font_size_override("font_size", 40)
		lbl.add_theme_color_override("font_color", Color(1, 0.15, 0.15))
		lbl.position = Vector2(HALF_W - 160 + i * 52, -HALF_H + 8)
		lbl.z_index = 10
		add_child(lbl)
		heart_labels.append(lbl)

	# --- Compteur combo : haut gauche ---
	combo_counter_label = Label.new()
	combo_counter_label.add_theme_font_size_override("font_size", 32)
	combo_counter_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	combo_counter_label.position = Vector2(-HALF_W + 12, -HALF_H + 8)
	combo_counter_label.z_index = 10
	combo_counter_label.visible = false
	add_child(combo_counter_label)

	# --- Popup combo : centré, au-dessus de la Line2D (ligne à y=163 local) ---
	combo_label = Label.new()
	combo_label.add_theme_font_size_override("font_size", 52)
	combo_label.add_theme_color_override("font_color", Color(1, 0.75, 0.0))
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.custom_minimum_size = Vector2(400, 70)
	combo_label.position = Vector2(-200, 60)   # juste au-dessus de la ligne (163)
	combo_label.z_index = 10
	combo_label.visible = false
	add_child(combo_label)

	# --- Game Over panel ---
	game_over_panel = Panel.new()
	game_over_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_panel.z_index = 20
	game_over_panel.visible = false
	# PROCESS_MODE_ALWAYS : répond aux clics même quand le tree est en pause
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.78)
	game_over_panel.add_theme_stylebox_override("panel", style)
	add_child(game_over_panel)

	var go_label = Label.new()
	go_label.text = "GAME OVER"
	go_label.add_theme_font_size_override("font_size", 64)
	go_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	go_label.offset_top = -100
	go_label.offset_bottom = -20
	go_label.offset_left = -280
	go_label.offset_right = 280
	game_over_panel.add_child(go_label)

	var retry_btn = Button.new()
	retry_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	retry_btn.text = "Recommencer"
	retry_btn.add_theme_font_size_override("font_size", 26)
	retry_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	retry_btn.offset_top = 10
	retry_btn.offset_bottom = 60
	retry_btn.offset_left = -110
	retry_btn.offset_right = 110
	retry_btn.pressed.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
	game_over_panel.add_child(retry_btn)

	var menu_btn = Button.new()
	menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_btn.text = "Menu"
	menu_btn.add_theme_font_size_override("font_size", 22)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_btn.offset_top = 75
	menu_btn.offset_bottom = 120
	menu_btn.offset_left = -70
	menu_btn.offset_right = 70
	menu_btn.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	game_over_panel.add_child(menu_btn)

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
	# Convertit la position globale du Spawn en locale du Node2D
	var spawn_local = node2d.to_local(lane_nodes[index].global_position)
	new_tile.position = Vector2(spawn_local.x, -50)  # spawn juste au-dessus du Node2D
	# Passe la position globale RÉELLE de la ligne
	new_tile.death_line_global_y = death_line.global_position.y + 163.0
	new_tile.tile_missed.connect(_on_tile_missed)
	new_tile.tile_hit.connect(_on_tile_hit)
	node2d.add_child(new_tile)

func init_music():
	var music_path = json_data.get("music-path", "")
	var file = FileAccess.open(music_path, FileAccess.READ)
	if file:
		var stream_mp3 = AudioStreamMP3.new()
		stream_mp3.data = file.get_buffer(file.get_length())
		stream_player.stream = stream_mp3
	else:
		print("Invalid music path")
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

# --- Vies ---

func _on_tile_missed():
	combo = 0
	update_combo_display()
	lives -= 1
	update_hearts()
	if lives <= 0:
		game_over()

func update_hearts():
	for i in range(heart_labels.size()):
		heart_labels[i].modulate.a = 1.0 if lives >= (i + 1) else 0.2

func game_over():
	stream_player.stop()
	game_over_panel.visible = true
	get_tree().paused = true

# --- Combo ---

func _on_tile_hit():
	combo += 1
	show_combo_popup()
	update_combo_display()

func update_combo_display():
	if combo >= 2:
		combo_counter_label.text = "x" + str(combo)
		combo_counter_label.visible = true
	else:
		combo_counter_label.visible = false

func show_combo_popup():
	var msg = ""
	if combo >= 20:
		msg = "LEGENDARY!!"
	elif combo >= 10:
		msg = "ON FIRE!! 🔥"
	elif combo >= 5:
		msg = "AWESOME!"
	elif combo >= 3:
		msg = "NICE!"
	elif combo == 2:
		msg = "COMBO!"
	else:
		return

	combo_label.text = msg
	combo_label.visible = true
	combo_label.scale = Vector2(0.5, 0.5)
	combo_label.modulate.a = 1.0

	if combo_tween:
		combo_tween.kill()
	combo_tween = create_tween()
	combo_tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.08)
	combo_tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.05)
	combo_tween.tween_interval(0.45)
	combo_tween.tween_property(combo_label, "modulate:a", 0.0, 0.25)
	combo_tween.tween_callback(func(): combo_label.visible = false)
