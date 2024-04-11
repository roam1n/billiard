extends Node2D
class_name Level

enum Status{
	WAITING,
	RUNNING,
	SUBTOTAL,
	INACTIVE,
	DONE,
	GAME_SUCCESSED,
	GAME_FAILING
}

var game_state: Status = Status.WAITING:
	set(value):
		print("状态切换：",Status.keys()[value])
		game_state = value
		match game_state:
			Status.GAME_SUCCESSED:
				successed.emit()
			Status.GAME_FAILING:
				failing.emit()
				
@onready var cueball: RigidBody2D = $CueBall
#var game_cueball: PackedScene = preload("res://Elements/cueBall.tscn")

@export var is_level := true
var _is_time_stop := false
var _is_calculating_subtotal := false
var _batting_score := 0
var _batting_count := 0
var level_name:StringName = "level_1-1"

signal successed
signal failing	
signal level_to_main_subtotal_completed(_batting_score, _batting_count)
signal level_to_main_done(level_name, _batting_score, _batting_count)

func _ready() -> void:
	#cueball = game_cueball.instantiate()
	print("bbbbbbb")
	
func _physics_process(delta: float) -> void:
	cueball._cue_position()
	
func _process(delta):
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
	elif Input.is_action_just_pressed("right_mouse") and is_level:
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
			if len(get_tree().get_nodes_in_group("objectBalls")) > 0:
				_subtotal_to_wait()
				print("1111111")
			else:
				_subtotal_to_done()
				#少个判断成功和失败的逻辑，以及发射成功失败信号
				_success_or_fail_result()
				print("2222")
				var next_scene = "res://LevelScenes/level_1-2.tscn"
			#if next_scene:
				print("fgggggggggggg", next_scene)
				#var new_scene_path = "res://LevelScenes/level_1-2.tscn"
				#get_tree().change_scene_to_file(new_scene_path)
				#var new_scene = ResourceLoader.load(new_scene_path)
				#if new_scene:
					#get_tree().call_deferred("change_scene", new_scene)
				#else:
					#print("Failed to load new scene at path: " + new_scene_path)
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
	cueball._wait_to_inactive() #只做了隐藏，是否少了禁止操作
	#ball_inactive.emit() #给Main发送信号

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
	emit_signal("level_to_main_done", level_name, _batting_score, _batting_count)	

func _subtotal_to_wait():
	game_state = Status.WAITING
	cueball._subtotal_to_wait()

func _score_subtotal() -> void:
	print("stop running")
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
	_batting_count += 1
	#给Main发信号更新分数
	emit_signal("level_to_main_subtotal_completed", _batting_score, _batting_count)

func _success_or_fail_result() -> void:
	if _batting_score >= 10 and _batting_count <=3:
		successed.emit()
	else:
		failing.emit()

