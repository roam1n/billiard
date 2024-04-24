extends CanvasLayer

@onready var batting_score: Label = %BattingScore
@onready var batting_count: Label = %BattingCount
@onready var level_complete: PanelContainer = %LevelComplete
@onready var restart_btn: Button = %Restart 
@onready var next_btn: Button = %Next
@onready var success_or_fail_label: Label = %Label

signal selected_pole(pole:PoleSelect)
signal selected_finish(is_time_stop:bool)

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}

var level_name:StringName = ""
var _is_selecting:bool = false
var _selected_pole := PoleSelect.HIGH
var _pole_nodes := []
var _is_time_stop := false


func _ready() -> void:
	level_complete.hide()
	level_name = get_parent().name
	print("打印当前关卡:", level_name)
	%LevelName.set_text(level_name)
	_pole_nodes = [%HigtPole, %MediumPole, %LowPole, %JumpPole]
	_on_select_pole()
	var level_node:Node = get_parent()
	if level_node:
		level_node.level_to_main_score_completed.connect(_change_batting_score_label)
		level_node.level_to_main_count_completed.connect(_change_batting_count_label)
		level_node.level_to_main_inactive.connect(_ball_inactive_player_select)
		level_node.level_to_main_done.connect(_level_done)

	restart_btn.pressed.connect(
		func() -> void:
			load_level()
			level_complete.hide()
	)
	next_btn.pressed.connect(
		func() -> void:
			get_next_level()
			level_complete.hide()
	)

func _ball_inactive_player_select() -> void:
	_is_selecting = true
	_all_show_pole_buttons()

func _on_select_pole() -> void:
	_only_show_selected_pole(_selected_pole)
	selected_pole.emit(_selected_pole)
	selected_finish.emit(_is_time_stop)

func _all_show_pole_buttons() -> void:
	for node in _pole_nodes:
		node.show()

# 切换杆法
func _only_show_selected_pole(pole:PoleSelect) -> void:
	for i in range(len(_pole_nodes)):
		if i == pole:
			_pole_nodes[i].show()
		else:
			_pole_nodes[i].hide()

func _on_higt_pole_button_down() -> void:
	_selected_pole = PoleSelect.HIGH
	_on_select_pole()

func _on_medium_pole_button_down() -> void:
	_selected_pole = PoleSelect.MEDIUM
	_on_select_pole()

func _on_low_pole_button_down() -> void:
	_selected_pole = PoleSelect.LOW
	_on_select_pole()

func _on_jump_pole_button_down() -> void:
	_selected_pole = PoleSelect.JUMP
	_on_select_pole()

func _change_batting_score_label(new_batting_score) -> void:
	batting_score.set_text("得分：%d" % new_batting_score)
	print("updated_score")

func _change_batting_count_label(new_batting_count) -> void:
	batting_count.set_text("次数：%d" % new_batting_count)
	print("updated_count")

func _level_done(_batting_score, _batting_count, _is_level_success) -> void:
	show_popup_game_over(_is_level_success)
	SaverLoader.save_game(level_name, _batting_score, _batting_count, _is_level_success)
	print("level done:",level_name)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://start.tscn")

func show_popup_game_over(is_level_success: bool) -> void:
	success_or_fail_label.text = "过关啦" if is_level_success else "失败啦"
	level_complete.show()

func get_next_level() -> void:
	print("当前关卡:", level_name)
	var next_level:StringName = SaverLoader.next_level(level_name)
	print("下一关卡:", next_level)
	call_deferred("queue_free")
	var new_scene_path:String = "res://LevelScenes/" + next_level + ".tscn"
	get_tree().change_scene_to_file(new_scene_path)

func load_level() -> void:
	get_tree().reload_current_scene()
