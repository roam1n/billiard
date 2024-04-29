extends Node2D
class_name Level

@onready var cue_ball: RigidBody2D = $CueBall
@onready var main: CanvasLayer = $Main
@onready var state_machine: StateMachine = $StateMachine

enum State {
	PLAYING,
	SCORE_CALC,
	SCORE_COMPLETED,
	SELECT_INPROGRESS,
	SELECT_DONE,
	SUCCESS,
	FAIL
}

@export var target_score: int = 10
@export var max_batting_count: int = 2

var _batting_score := 0
var _batting_count := 0
var game_state: State = State.PLAYING

signal action_restored
signal updated_score(batting_score: int)
signal selection_in_progress
signal selection_done(pole: int)
signal game_success(batting_score:int, batting_count:int)
signal game_fail


func _ready() -> void:
	# level根节点、子节点之间的信号连接
	cue_ball.about_to_stop.connect(_on_cue_ball_to_stop)
	action_restored.connect(cue_ball._on_level_action_restored)
	updated_score.connect(main.change_batting_score_label)
	selection_in_progress.connect(main._on_player_selection_in_progress)
	selection_done.connect(cue_ball._on_main_selected_pole)
	game_success.connect(main.game_success)
	game_fail.connect(main.game_fail)
	main.selected_pole.connect(_on_selected_pole)

func get_next_state(state: State) -> int:
	match state:
		State.PLAYING:
			if Input.is_action_just_pressed("right_mouse"):
				return State.SELECT_INPROGRESS
		State.SCORE_CALC:
			return State.SCORE_COMPLETED
		State.SCORE_COMPLETED:
			if _batting_score >= target_score:
				#print("闯关成功")
				return State.SUCCESS
			elif _batting_count >= max_batting_count:
				#print("闯关失败")
				return State.FAIL
			else:
				#print("继续游戏")
				return State.PLAYING
		State.SELECT_DONE:
			return State.PLAYING
	
	return state

func transition_state(from:State, to:State) -> void:
	match to :
		State.PLAYING:
			print("from:  ", from)
			if from == State.SELECT_DONE:
				Engine.time_scale = 1
			action_restored.emit()
		State.SCORE_COMPLETED:
			_score_subtotal()
		State.SELECT_INPROGRESS:
			Engine.time_scale = 0
			selection_in_progress.emit()
		State.SUCCESS:
			game_success.emit(_batting_score, _batting_count)
		State.FAIL:
			game_fail.emit(_batting_score, _batting_count)

func _on_cue_ball_to_stop() -> void:
	state_machine.current_state = State.SCORE_CALC

func _on_selected_pole(pole: int) -> void:
	selection_done.emit(pole)
	state_machine.current_state = State.SELECT_DONE

func _score_subtotal() -> void:
	print("stop running")
	var score := 0
	for node in get_tree().get_nodes_in_group("bonusAreas"):
		if node as Area2D:
			for ball in node.get_overlapping_bodies():
				if ball.is_in_group("balls"):
					score += node.get_meta("score")
					if ball.is_in_group("objectBalls"):
						# 销毁已得分的子球
						ball.queue_free()
	_batting_score += score
	_batting_count += 1
	#更新main击打次数数值
	main.change_batting_count_label(_batting_count)
	#发布得分更新
	updated_score.emit(_batting_score)
