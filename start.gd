extends Control


var next_scene:String = ""

func _physics_process(delta:float) -> void:
	if next_scene:
		get_tree().change_scene_to_file(next_scene)
		next_scene = ""

func _on_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.call_deferred("queue_free")
		next_scene = "res://LevelScenes/1-1.tscn"


func _on_continue_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.call_deferred("queue_free")
		next_scene = "res://LevelScenes/1-1.tscn"
