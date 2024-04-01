extends Control


var next_scene:String = ""
var continue_scene:String = ""

func _ready() -> void:
	continue_scene = SaverLoader.latest_scene()

func _physics_process(delta:float) -> void:
	if next_scene:
		get_tree().change_scene_to_file(next_scene)
		next_scene = ""

func _on_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.call_deferred("queue_free")
		next_scene = continue_scene

func _on_select_level_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.call_deferred("queue_free")
		next_scene = "res://LevelScenes/1-1.tscn"
