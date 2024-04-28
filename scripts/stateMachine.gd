class_name StateMachine
extends Node

var current_state: int = -1:
	set(v):
		owner.transition_state(current_state, v)
		current_state = v

func _ready() -> void:
	await owner.ready
	current_state = 0

func _physics_process(_delta: float) -> void:
	var next := owner.get_next_state(current_state) as int
	if next != current_state:
		current_state = next

	if owner.has_method("tick_physics"):
		owner.tick_physics(current_state)
