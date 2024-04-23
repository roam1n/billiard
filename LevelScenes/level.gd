extends Node2D
class_name Level

enum Status{
	WAITING,
	RUNNING,
	SUBTOTAL,
	INACTIVE,
	DONE
}

@onready var cueball: RigidBody2D = $CueBall

@export var target_score: int = 10
@export var max_batting_count: int = 2

var _is_time_stop := false
var _is_calculating_subtotal := false
var _is_success := false
var _batting_score := 0
var _batting_count := 0
var game_state: Status = Status.WAITING


signal level_to_main_score_completed(batting_score)
signal level_to_main_count_completed(batting_count)
signal level_to_main_done(batting_score, batting_count, is_success)
signal level_to_main_inactive


func _ready() -> void:
	set_process(true)
	var main_node = get_node("Main")
	if main_node.is_connected("selected_finish",_on_main_selected_finish):
		main_node.disconnect("selected_finish", _on_main_selected_finish)
	else:
		main_node.connect("selected_finish", _on_main_selected_finish)

func _process(_delta) -> void:
	match game_state:
		Status.WAITING:
			waiting()
		Status.RUNNING:
			running()
		Status.INACTIVE:
			inactive()
		Status.SUBTOTAL:
			subtotal()

func get_batting_count_value() -> int:
	var value: int = _batting_count
	return value

func waiting() -> void:
	if Input.is_action_just_pressed("left_mouse"):
		_wait_to_running()
	if Input.is_action_just_pressed("right_mouse"):
		_wait_to_inactive()

func running() -> void:
	if cueball.linear_velocity.length() < 5:
		_running_to_subtotal()
		if Input.is_action_just_pressed("right_mouse"):
			_wait_to_inactive()

func inactive() -> void:
	if not _is_time_stop and cueball.linear_velocity.length() < 10:
		_inactive_to_wait()
	elif not _is_time_stop:
		_inactive_to_running()

func subtotal() -> void:
	if not _is_calculating_subtotal:
		if _batting_score >= target_score:
			_is_success = true
			_subtotal_to_done()
			print("闯关成功")
		elif  _batting_count >= max_batting_count:
			_is_success = false
			_subtotal_to_done()
			print("闯关失败")
		else:
			_subtotal_to_wait()
			print("继续统计")

func _wait_to_running() -> void: 
	game_state = Status.RUNNING
	cueball._in_running()

func _running_to_subtotal() -> void:
	game_state = Status.SUBTOTAL
	_is_calculating_subtotal = true
	_score_subtotal()
	_is_calculating_subtotal = false

func _wait_to_inactive() -> void:
	Engine.time_scale = 0
	_is_time_stop = true
	game_state = Status.INACTIVE
	cueball._wait_to_inactive()
	level_to_main_inactive.emit()

func _inactive_to_wait() -> void:
	Engine.time_scale = 1
	game_state = Status.WAITING
	cueball._inactive_to_wait()

func _inactive_to_running() -> void:
	Engine.time_scale = 1
	game_state = Status.RUNNING
	cueball._in_running()

func _subtotal_to_done() -> void:
	game_state = Status.DONE
	level_to_main_done.emit(_batting_score, _batting_count, _is_success)

func _subtotal_to_wait() -> void:
	game_state = Status.WAITING
	cueball._subtotal_to_wait()

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
	#给Main发信号更新分数
	level_to_main_score_completed.emit(_batting_score)
	level_to_main_count_completed.emit(_batting_count)

func _on_main_selected_finish(is_time_stop) -> void:
	_is_time_stop = is_time_stop # Replace with function body.
	
func _on_blue_bounce_body_entered(_body) -> void:
	_batting_score += 5
	level_to_main_score_completed.emit(_batting_score)

func _on_purple_bounce_body_entered(_body):
	_batting_score += -5
	level_to_main_score_completed.emit(_batting_score)
