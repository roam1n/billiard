extends Node

func _ready() -> void:
	if owner is RigidBody2D:
		owner.body_entered.connect(_on_ball_body_entered)
		#print(owner.is_connected("body_entered", _on_ball_body_entered))

func _on_ball_body_entered(body: Node) -> void:
	if owner.owner is Level and body.is_in_group("bonusLine"):
		owner.owner._batting_score += body.get_meta("score")
		owner.owner.level_to_main_score_completed.emit(owner.owner._batting_score)
