extends RigidBody2D


@export var custom_color := Color.ANTIQUE_WHITE;

enum Status {WAIT, RUNNING, INACTIVE, DONE}
enum PoleSelect {HIGH, MEDIUM, LOW, JUMP}

signal ball_running
signal ball_wait
signal ball_inactive
signal ball_done

const SPEED := 200
const MAX_RADIUS := 324
var _velocity := Vector2(0.0, 0.0)
var _status := Status.WAIT
var _pole_select := PoleSelect.HIGH


func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))

func _physics_process(delta: float) -> void:
	var l_mouse_position := get_local_mouse_position()
	$Mouse.position = l_mouse_position if l_mouse_position.length() < MAX_RADIUS else l_mouse_position.normalized() * MAX_RADIUS
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
			_running_to_wait()
		elif Input.is_action_just_pressed("right_mouse"):
			_wait_to_inactive()
	elif _status == Status.INACTIVE:
		if Input.is_action_just_pressed("left_mouse") and linear_velocity.length() < 20:
			_inactive_to_wait()
		elif Input.is_action_just_pressed("left_mouse"):
			_inactive_to_running()

func _wait_to_running():
	_status = Status.RUNNING
	ball_running.emit()
	var g_mouse_position := get_global_mouse_position()
	_velocity = g_mouse_position - position if (position - g_mouse_position).length() < MAX_RADIUS else (g_mouse_position - position).normalized() * MAX_RADIUS
	linear_velocity = _velocity * 5.5
	$Mouse.hide()

func _running_to_wait():
	_status = Status.WAIT
	ball_wait.emit()
	$Mouse.show()

func _wait_to_inactive():
	_status = Status.INACTIVE
	ball_inactive.emit()
	$Mouse.hide()

func _inactive_to_wait():
	_status = Status.WAIT
	ball_wait.emit()
	$Mouse.show()

func _inactive_to_running():
	_status = Status.RUNNING
	ball_running.emit()
