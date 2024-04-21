extends Node2D
class_name Level

enum Status{
	WAITING,
	RUNNING,
	SUBTOTAL,
	INACTIVE,
	DONE
}

var game_state: Status = Status.WAITING:
	set(value):
		print("状态切换：",Status.keys()[value])
		game_state = value
				
@onready var cueball: RigidBody2D = $CueBall

@export var is_level := true
var _is_time_stop := false
var _is_calculating_subtotal := false
var _is_success := false
var _batting_score := 0
var _batting_count := 0
var level_name:StringName = ""
var _lock = Mutex.new()

signal level_to_main_score_completed(_batting_score)
signal level_to_main_count_completed(_batting_count)
signal level_to_main_done(_batting_score, _batting_count, _is_success)
signal level_to_main_inactive

func get_batting_score_value():
	_lock.lock()
	var value = _batting_score
	_lock.unlock()
	return value

func set_batting_score_value(new_value):
	_lock.lock()
	_batting_score = new_value
	_lock.unlock()
	
func get_batting_count_value():
	var value = _batting_count
	return value

func _ready() -> void:
	set_process(true)
	var main_node = get_node("Main")
	if main_node.is_connected("selected_finish",_on_main_selected_finish):
		main_node.disconnect("selected_finish", _on_main_selected_finish)
	else:
		main_node.connect("selected_finish", _on_main_selected_finish)
	
	
func _process(_delta):
	if game_state == Status.WAITING:
		waiting()
	if game_state == Status.RUNNING:
		running()
	if game_state == Status.INACTIVE:
		inactive()
	if game_state == Status.SUBTOTAL:
		subtotal()
		
func waiting() ->void:
	if Input.is_action_just_pressed("left_mouse"):
		_wait_to_running()
	if Input.is_action_just_pressed("right_mouse") and is_level:
		_wait_to_inactive()		

func running() ->void:
	if cueball.linear_velocity.length() < 5:
		_running_to_subtotal()
		if Input.is_action_just_pressed("right_mouse") and is_level:
			_wait_to_inactive()	
			
func inactive() ->void:
	if not _is_time_stop and cueball.linear_velocity.length() < 10:
		_inactive_to_wait()
	elif not _is_time_stop:
		_inactive_to_running()
		
func subtotal() ->void:
		if not _is_calculating_subtotal:
			if _batting_score >= 10:
				_is_success = true
				_subtotal_to_done()
				print("闯关成功")
			elif _batting_score < 10 and _batting_count >2:
				_is_success = false
				_subtotal_to_done()
				print("闯关失败")
			else:
				_subtotal_to_wait()
				print("继续统计")

func _wait_to_running(): 
	game_state = Status.RUNNING
	cueball._in_running()

func _running_to_subtotal():
	game_state = Status.SUBTOTAL
	_is_calculating_subtotal = true
	_score_subtotal()
	_is_calculating_subtotal = false

func _wait_to_inactive():
	Engine.time_scale = 0
	_is_time_stop = true
	game_state = Status.INACTIVE
	cueball._wait_to_inactive()
	emit_signal("level_to_main_inactive")
	
func _inactive_to_wait():
	Engine.time_scale = 1
	game_state = Status.WAITING
	cueball._inactive_to_wait()
	
func _inactive_to_running():
	Engine.time_scale = 1
	game_state = Status.RUNNING
	cueball._in_running()

func _subtotal_to_done():
	game_state = Status.DONE
	emit_signal("level_to_main_done", _batting_score, _batting_count, _is_success)	

func _subtotal_to_wait():
	game_state = Status.WAITING
	cueball._subtotal_to_wait()
	
func _score_subtotal() -> void:
	print("stop running")
	var score := 0
	for node in get_tree().get_nodes_in_group("bonusAreas"):
		if node as Area2D:
			for ball in node.get_overlapping_bodies():
				if ball.is_in_group("balls"):
					score += 10
					if ball.is_in_group("objectBalls"):
						# 销毁已得分的子球
						ball.queue_free()
	var current_batting_score = get_batting_score_value()
	current_batting_score += score
	set_batting_score_value(current_batting_score)
	_batting_count += 1
	#给Main发信号更新分数
	emit_signal("level_to_main_score_completed", _batting_score)
	emit_signal("level_to_main_count_completed", _batting_count)

func _on_main_selected_finish(is_time_stop):
	_is_time_stop = is_time_stop # Replace with function body.
