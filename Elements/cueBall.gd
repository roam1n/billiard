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
var _pole_select: PoleSelect = PoleSelect.HIGH


func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))
	if get_parent() is Level:
		var main_node = get_parent().get_node("Main")
		print("这个是哪个",main_node)
		main_node.connect("selected_pole", _on_main_selected_pole)

func _physics_process(_delta: float) -> void:
	_cue_position()

func _cue_position() -> void:
	var l_mouse_position := get_local_mouse_position()
	$Mouse.position = l_mouse_position if l_mouse_position.length() < MAX_RADIUS else l_mouse_position.normalized() * MAX_RADIUS
	$Mouse/Line.points = [$Mouse.position * 0.8, ($Mouse.position - $Mouse.position.normalized() * 38.0) * -1.0]

func _in_running() -> void:
	var g_mouse_position := get_global_mouse_position()
	_velocity = g_mouse_position - position if (position - g_mouse_position).length() < MAX_RADIUS else (g_mouse_position - position).normalized() * MAX_RADIUS
	linear_velocity = _velocity * 4.5
	$Mouse.hide()

func _wait_to_inactive() -> void:
	$Mouse.hide()

func _inactive_to_wait() -> void:
	$Mouse.show()

func _subtotal_to_wait() -> void:
	$Mouse.show()

func _on_main_selected_pole(newpole) -> void:
	_pole_select = newpole
	match newpole:
		PoleSelect.HIGH:
			print("It's an high!")
		PoleSelect.LOW:
			print("It's an low!")
		PoleSelect.MEDIUM:
			print("It's an medium!")

func _on_body_entered(body) -> void:
	if body is RigidBody2D:
		var other_rigidbody = body as RigidBody2D
		if other_rigidbody.is_in_group("balls"):
			print("Collision with a RigidBody2D in the specified group detected!")
			_collison_to_object_ball()

# 母球撞到的类型是其他刚体球
func _collison_to_object_ball() ->void:
	match _pole_select:
		PoleSelect.LOW:
			apply_central_impulse(-_velocity * 8)
		PoleSelect.MEDIUM:
			apply_central_impulse(-_velocity * 4)
		_:
			print("Unknown pole")

#func _on_body_exited(body):
	#linear_velocity = _velocity
