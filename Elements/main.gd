extends CanvasLayer


@onready var batting_score: Label = %BattingScore
@onready var batting_count: Label = %BattingCount
@onready var level_complete: PanelContainer = %LevelComplete

signal selected_pole(pole:PoleSelect)
signal subtotal_completed
#signal level_completed

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}

var _is_selecting:bool = false
var _selected_pole := PoleSelect.HIGH
var _batting_score := 0
var _batting_count := 0
var _pole_nodes = []

func _ready() -> void:
	level_complete.hide()
	_pole_nodes = [%HigtPole, %MediumPole, %LowPole, %JumpPole]
	_on_select_pole()

# level scene 中绑定 cueBall 信号 ball_inactive
func _on_cut_ball_ball_inactive() -> void:
	_is_selecting = true
	_all_show_pole_buttons()

# level scene 中绑定 cueBall 信号 ball_running
func _on_cut_ball_running() -> void:
	_change_batting_count_label()

func _change_batting_count_label() -> void:
	_batting_count += 1
	batting_count.set_text("次数：%d" % _batting_count)

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

# 每次击球后，计算得分并更新label
func _on_cut_ball_stop_running() -> void:
	_score_subtotal()
	_change_batting_score_label()
	print("stop running")

func _score_subtotal() -> void:
	var score := 0
	for node in get_tree().get_nodes_in_group("bonusAreas"):
		if node as Area2D:
			for ball in node.get_overlapping_bodies():
				print(ball)
				if ball.is_in_group("balls"):
					score += 10
					if ball.is_in_group("objectBalls"):
						# 销毁已得分的子球
						ball.queue_free()
	_batting_score += score
	subtotal_completed.emit()

func _change_batting_score_label() -> void:
	batting_score.set_text("得分：%d" % _batting_score)
	print("updated_score")

func _on_cut_ball_done() -> void:
	level_complete.show()
	print("level done")
