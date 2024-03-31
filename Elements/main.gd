extends CanvasLayer


@onready var batting_score: Label = %BattingScore
@onready var batting_count: Label = %BattingCount

signal selected_pole(pole:PoleSelect)

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP}

var is_selecting:bool = false
var _batting_score := 0
var _batting_count := 0
var _pole_nodes = []

func _ready() -> void:
	_pole_nodes = [%HigtPole, %MediumPole, %LowPole, %JumpPole]
	_on_select_pole(PoleSelect.HIGH)

# 在level scene 中绑定 cueBall singal ball_inactive
func _on_cut_ball_ball_inactive() -> void:
	_all_show_pole_buttons()

# 在level scene 中绑定 cueBall singal ball_running
func _on_cut_ball_running() -> void:
	_change_batting_count_label()

func _change_batting_count_label() -> void:
	_batting_count += 1
	batting_count.set_text("次数：%d" % _batting_count)

func _on_select_pole(pole:PoleSelect) -> void:
	_only_show_selected_pole(pole)
	selected_pole.emit(pole)
	
func _all_show_pole_buttons() -> void:
	for node in _pole_nodes:
		node.show()

func _only_show_selected_pole(pole:PoleSelect) -> void:
	print(_pole_nodes)
	for i in range(len(_pole_nodes)):
		if i == pole:
			_pole_nodes[i].show()
		else:
			_pole_nodes[i].hide()

func _on_higt_pole_button_down() -> void:
	_on_select_pole(PoleSelect.HIGH)

func _on_medium_pole_button_down() -> void:
	_on_select_pole(PoleSelect.MEDIUM)

func _on_low_pole_button_down() -> void:
	_on_select_pole(PoleSelect.LOW)

func _on_jump_pole_button_down() -> void:
	_on_select_pole(PoleSelect.JUMP)
