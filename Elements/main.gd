extends CanvasLayer

# Main的父节点一定是level
@export var levels:Array[String] = [
	"res://LevelScenes/level1-1.tscn",
	"res://LevelScenes/level1-2.tscn"
]

@onready var batting_score: Label = %BattingScore
@onready var batting_count: Label = %BattingCount
@onready var level_complete: PanelContainer = %LevelComplete
@onready var restart_btn: Button = %Restart 
@onready var next_btn: Button = %Next
@onready var success_or_fail_label: Label = %Label

signal selected_pole(pole:PoleSelect)

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}

var _is_success:bool = false
var _is_selecting:bool = false
var _selected_pole := PoleSelect.HIGH
var _pole_nodes := []
var level_name:StringName = "1-1"
var current_level_index : int = 0
var current_level: Level:
	set(value):
		if current_level:
			current_level.successed.disconnect(_on_current_level_successed)
			current_level.failing.disconnect(_on_current_level_failing)			
		current_level = value
		get_parent().add_child(current_level)
		print("yyyyyyyy",current_level)
		current_level.successed.connect(_on_current_level_successed)
		current_level.failing.connect(_on_current_level_failing)

func _ready() -> void:
	level_complete.hide()
	level_name = get_parent().name
	%LevelName.set_text(level_name)
	_pole_nodes = [%HigtPole, %MediumPole, %LowPole, %JumpPole]
	_on_select_pole()
	var level_node = get_parent()
	if level_node:
		level_node.connect("level_to_main_subtotal_completed", _change_batting_score_label)
		level_node.connect("level_to_main_done", _level_done)
	restart_btn.pressed.connect(
		func() -> void:
			load_level()
			level_complete.hide()
	)
	next_btn.pressed.connect(
		func() -> void:
			next_level()
			level_complete.hide()
	)
		
# level scene 中绑定 cueBall 信号 ball_inactive
func _on_cut_ball_ball_inactive() -> void:
	_is_selecting = true
	_all_show_pole_buttons()

func _on_select_pole() -> void:
	_only_show_selected_pole(_selected_pole)
	selected_pole.emit(_selected_pole)

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

func _change_batting_score_label(new_batting_score, new_batting_count) -> void:
	batting_score.set_text("得分：%d" % new_batting_score)
	batting_count.set_text("次数：%d" % new_batting_count)
	print("updated_score")

func _level_done(_current_level_name, _batting_score, _batting_count) -> void:
	level_complete.show()
	SaverLoader.save_game(_current_level_name, _batting_score, _batting_count)
	print("level done",_current_level_name)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://start.tscn")

func show_popup_game_over() -> void:
	success_or_fail_label.text = "过关啦" if _is_success else "失败啦"
	level_complete.show()

#加载下一关
func next_level() -> void:
	#将当前关所在大关遍历，如当前大关号及尾号+1存在则进入该关卡，否则进入到下一大关第一关
	if levels.size() -1 > current_level_index:
		current_level_index += 1
		#levels[current_level_index].instantiate()
		call_deferred("queue_free")
		print("trrrrrrrrrrr", get_parent().name)
		var new_scene_path = "res://LevelScenes/level1-2.tscn"
		get_tree().change_scene_to_file(new_scene_path)
		
#加载当前关卡		
func load_level() -> void:
	#var scene_path = get_tree().current_scene
	get_tree().reload_current_scene()
	print("acccccccccc")
	
func _on_current_level_successed() -> void:
	_is_success = true
	show_popup_game_over()
	
func _on_current_level_failing() -> void:
	_is_success = false
	show_popup_game_over()
