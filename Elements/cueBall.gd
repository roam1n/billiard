extends RigidBody2D

@onready var state_machine: StateMachine = $StateMachine

@export var custom_color := Color.ANTIQUE_WHITE;
@export var is_level := true

signal about_to_stop

enum PoleSelect {HIGH, MEDIUM, LOW, JUMP, NONE}
enum State {WAITING, RUNNING, INACTIVE, DISABLE}

const SPEED := 200
const MAX_RADIUS := 324
var _velocity := Vector2(0.0, 0.0)
var _pole_select: PoleSelect = PoleSelect.HIGH


func _ready() -> void:
	#设置球的颜色
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))

func get_next_state(state:State) -> int:
	match state :
		State.WAITING:
			if Input.is_action_just_pressed("left_mouse"):
				return State.RUNNING
		State.RUNNING:
			if linear_velocity.length() < 12:
				about_to_stop.emit()
				return State.INACTIVE
		State.DISABLE:
			if linear_velocity.length() < 12:
				about_to_stop.emit()
				return State.INACTIVE
	return state

func transition_state(_from:State, to:State) -> void:
	match to :
		State.WAITING:
			$Mouse.show()
		State.RUNNING:
			var g_mouse_position := get_global_mouse_position()
			_velocity = g_mouse_position - position if (position - g_mouse_position).length() < MAX_RADIUS else (g_mouse_position - position).normalized() * MAX_RADIUS
			linear_velocity = _velocity * 4.5
			$Mouse.hide()
		State.INACTIVE:
			$Mouse.hide()
		State.DISABLE:
			$Mouse.hide()

func _on_level_action_restored() -> void:
	if linear_velocity.length() > 12:
		state_machine.current_state = State.DISABLE
	else:
		state_machine.current_state = State.WAITING

func tick_physics(state:State) -> void:
	match state :
		State.WAITING:
			# 实时更新辅助线
			var l_mouse_position := get_local_mouse_position()
			$Mouse.position = l_mouse_position if l_mouse_position.length() < MAX_RADIUS else l_mouse_position.normalized() * MAX_RADIUS
			$Mouse/Line.points = [$Mouse.position * 0.8, ($Mouse.position - $Mouse.position.normalized() * 38.0) * -1.0]

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
