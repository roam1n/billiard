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
#var game_cueball: PackedScene = preload("res://Elements/cueBall.tscn")

@export var is_level := true
var _is_time_stop := false
var _is_calculating_subtotal := false
var _is_success := false
var _batting_score := 0
var _batting_count := 0
var level_name:StringName = ""

signal level_to_main_subtotal_completed(_batting_score, _batting_count)
signal level_to_main_done(_batting_score, _batting_count, _is_success)

func _ready() -> void:
	set_process(true)
	
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
	if cueball.linear_velocity.length() < 20:
		_running_to_subtotal()
	elif Input.is_action_just_pressed("right_mouse") and is_level:
		_wait_to_inactive()	
			
func inactive() ->void:
	if not _is_time_stop and cueball.linear_velocity.length() < 20:
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

func _inactive_to_wait():
	Engine.time_scale = 1
	game_state = Status.WAITING
	cueball._inactive_to_wait()

func _inactive_to_running():
	Engine.time_scale = 1
	game_state = Status.RUNNING
	cueball._inactive_to_running()

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
	_batting_score += score
	_batting_count += 1
	#给Main发信号更新分数
	emit_signal("level_to_main_subtotal_completed", _batting_score, _batting_count)


