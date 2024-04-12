extends RigidBody2D

@export var custom_color := Color.ANTIQUE_WHITE;
@export var is_level := true

signal ball_running
signal ball_wait
signal ball_inactive
signal ball_done
signal ball_stop_running

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}

const SPEED := 200
const MAX_RADIUS := 324
var _velocity := Vector2(0.0, 0.0)
var _pole_select := PoleSelect.HIGH
var _is_time_stop := false
#var _is_calculating_subtotal := false


func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))

func _cue_position() -> void:
	var l_mouse_position := get_local_mouse_position()
	$Mouse.position = l_mouse_position if l_mouse_position.length() < MAX_RADIUS else l_mouse_position.normalized() * MAX_RADIUS
	$Mouse/Line.points = [$Mouse.position * 0.8, ($Mouse.position - $Mouse.position.normalized() * 38.0) * -1.0]
		
func _in_running() -> void:
	var g_mouse_position := get_global_mouse_position()
	_velocity = g_mouse_position - position if (position - g_mouse_position).length() < MAX_RADIUS else (g_mouse_position - position).normalized() * MAX_RADIUS
	linear_velocity = _velocity * 4.5
	$Mouse.hide()

func _wait_to_inactive():
	$Mouse.hide()

func _inactive_to_wait():
	$Mouse.show()

func _subtotal_to_wait():
	$Mouse.show()

# level scene 中绑定 Main 信号 selected_pole
func _on_main_selected_pole(pole: PoleSelect) -> void:
	_pole_select = pole
	_is_time_stop = false
