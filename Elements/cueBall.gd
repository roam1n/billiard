extends RigidBody2D


@export var custom_color := Color.ANTIQUE_WHITE;

enum Status {WAIT, RUNNING, INACTIVE, DONE, SUBTOTAL}
enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}

signal ball_running
signal ball_wait
signal ball_inactive
signal ball_done
signal ball_stop_running

const SPEED := 200
const MAX_RADIUS := 324
var _velocity := Vector2(0.0, 0.0)
var _status := Status.WAIT
var _pole_select := PoleSelect.HIGH
var _is_time_stop := false
var _is_calculating_subtotal := false


func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))

func _physics_process(delta: float) -> void:
	var l_mouse_position := get_local_mouse_position()
	$Mouse.position = l_mouse_position if l_mouse_position.length() < MAX_RADIUS else l_mouse_position.normalized() * MAX_RADIUS
	$Mouse/Line.points = [$Mouse.position * 0.8, ($Mouse.position - $Mouse.position.normalized() * 38.0) * -1.0]
	_transform()

# 什么状态在什么情况下，发生转换
func _transform() -> void:
	if _status == Status.WAIT:
		if Input.is_action_just_pressed("left_mouse"):
			_wait_to_running()
		elif Input.is_action_just_pressed("right_mouse"):
			_wait_to_inactive()
	elif _status == Status.RUNNING:
		if linear_velocity.length() < 20:
			_running_to_subtotal()
		elif Input.is_action_just_pressed("right_mouse"):
			_wait_to_inactive()
	elif _status == Status.INACTIVE:
		if not _is_time_stop and linear_velocity.length() < 20:
			_inactive_to_wait()
		elif not _is_time_stop:
			_inactive_to_running()
	elif _status == Status.SUBTOTAL:
		if not _is_calculating_subtotal:
			if len(get_tree().get_nodes_in_group("objectBalls")) > 0:
				_subtotal_to_wait()
			else:
				_subtotal_to_done()

func _wait_to_running():
	_status = Status.RUNNING
	ball_running.emit()
	var g_mouse_position := get_global_mouse_position()
	_velocity = g_mouse_position - position if (position - g_mouse_position).length() < MAX_RADIUS else (g_mouse_position - position).normalized() * MAX_RADIUS
	linear_velocity = _velocity * 4.5
	$Mouse.hide()

func _running_to_subtotal():
	_status = Status.SUBTOTAL
	_is_calculating_subtotal = true
	ball_stop_running.emit()

func _wait_to_inactive():
	Engine.time_scale = 0
	_is_time_stop = true
	_status = Status.INACTIVE
	ball_inactive.emit()
	$Mouse.hide()

func _inactive_to_wait():
	Engine.time_scale = 1
	_status = Status.WAIT
	ball_wait.emit()
	$Mouse.show()

func _inactive_to_running():
	Engine.time_scale = 1
	_status = Status.RUNNING
	ball_running.emit()

func _subtotal_to_done():
	_status = Status.DONE
	ball_done.emit()

func _subtotal_to_wait():
	_status = Status.WAIT
	ball_wait.emit()
	$Mouse.show()

# level scene 中绑定 Main 信号 selected_pole
func _on_main_selected_pole(pole: int) -> void:
	_is_time_stop = false

# level scene 中绑定 Main 信号 subtotal_completed
func _on_main_subtotal_completed() -> void:
	_is_calculating_subtotal = false
