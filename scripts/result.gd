extends Control

const HALF_W = 576.0
const HALF_H = 324.0

func _ready() -> void:
	_build_ui()

func _get_grade() -> String:
	var acc = GlobalData.result_accuracy
	if acc >= 95.0:
		return "S"
	elif acc >= 85.0:
		return "A"
	elif acc >= 70.0:
		return "B"
	elif acc >= 50.0:
		return "C"
	else:
		return "D"

func _grade_color(grade: String) -> Color:
	match grade:
		"S": return Color(1.0, 0.92, 0.1)
		"A": return Color(0.3, 1.0, 0.4)
		"B": return Color(0.3, 0.7, 1.0)
		"C": return Color(1.0, 0.6, 0.2)
		_:   return Color(1.0, 0.3, 0.3)

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.06, 0.10)
	add_child(bg)

	var grade = _get_grade()

	var grade_lbl = Label.new()
	grade_lbl.text = grade
	grade_lbl.add_theme_font_size_override("font_size", 120)
	grade_lbl.add_theme_color_override("font_color", _grade_color(grade))
	grade_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grade_lbl.offset_left = -200
	grade_lbl.offset_right = 200
	grade_lbl.offset_top = -HALF_H + 20
	grade_lbl.offset_bottom = -HALF_H + 160
	add_child(grade_lbl)

	var song_lbl = Label.new()
	song_lbl.text = GlobalData.result_song_name
	song_lbl.add_theme_font_size_override("font_size", 22)
	song_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	song_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	song_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	song_lbl.offset_left = -300
	song_lbl.offset_right = 300
	song_lbl.offset_top = -HALF_H + 165
	song_lbl.offset_bottom = -HALF_H + 205
	add_child(song_lbl)

	var score_lbl = Label.new()
	score_lbl.text = "SCORE   " + str(GlobalData.result_score)
	score_lbl.add_theme_font_size_override("font_size", 42)
	score_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	score_lbl.offset_left = -300
	score_lbl.offset_right = 300
	score_lbl.offset_top = -80
	score_lbl.offset_bottom = -20
	add_child(score_lbl)

	var combo_lbl = Label.new()
	combo_lbl.text = "MAX COMBO   x" + str(GlobalData.result_max_combo)
	combo_lbl.add_theme_font_size_override("font_size", 26)
	combo_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	combo_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	combo_lbl.offset_left = -300
	combo_lbl.offset_right = 300
	combo_lbl.offset_top = -10
	combo_lbl.offset_bottom = 40
	add_child(combo_lbl)

	var acc_lbl = Label.new()
	acc_lbl.text = "PRÉCISION   " + str(snappedf(GlobalData.result_accuracy, 0.1)) + "%"
	acc_lbl.add_theme_font_size_override("font_size", 26)
	acc_lbl.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	acc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	acc_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	acc_lbl.offset_left = -300
	acc_lbl.offset_right = 300
	acc_lbl.offset_top = 50
	acc_lbl.offset_bottom = 95
	add_child(acc_lbl)

	var detail_texts = [
		["PERFECT", str(GlobalData.result_perfect), Color(1.0, 0.92, 0.1)],
		["GOOD",    str(GlobalData.result_good),    Color(0.3, 1.0, 0.4)],
		["BAD",     str(GlobalData.result_bad),     Color(1.0, 0.5, 0.3)],
		["MISS",    str(GlobalData.result_missed),  Color(0.6, 0.6, 0.6)],
	]
	var detail_x_starts = [-300.0, -150.0, 0.0, 150.0]
	for i in range(detail_texts.size()):
		var d = detail_texts[i]
		var col_lbl = Label.new()
		col_lbl.text = d[0] + "\n" + d[1]
		col_lbl.add_theme_font_size_override("font_size", 20)
		col_lbl.add_theme_color_override("font_color", d[2])
		col_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		col_lbl.offset_left = detail_x_starts[i]
		col_lbl.offset_right = detail_x_starts[i] + 140
		col_lbl.offset_top = 110
		col_lbl.offset_bottom = 175
		add_child(col_lbl)

	var retry_btn = Button.new()
	retry_btn.text = "Rejouer"
	retry_btn.add_theme_font_size_override("font_size", 22)
	retry_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	retry_btn.offset_left = -160
	retry_btn.offset_right = -10
	retry_btn.offset_top = 195
	retry_btn.offset_bottom = 245
	retry_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	)
	add_child(retry_btn)

	var menu_btn = Button.new()
	menu_btn.text = "Menu"
	menu_btn.add_theme_font_size_override("font_size", 22)
	menu_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_btn.offset_left = 10
	menu_btn.offset_right = 160
	menu_btn.offset_top = 195
	menu_btn.offset_bottom = 245
	menu_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	add_child(menu_btn)
