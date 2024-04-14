extends Control

@onready var cueball: RigidBody2D = $CueBall

var next_scene:String = ""
var continue_scene:String = ""
var select_level: bool = false
var select_level_scene_path = "res://Elements/selectLevel.tscn"

const MAX_RADIUS := 324

func _ready() -> void:
	continue_scene = SaverLoader._get_first_level_scene()

func _physics_process(_delta:float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
			cueball._in_running()
	if next_scene:
		print(next_scene)
		get_tree().change_scene_to_file(next_scene)
		next_scene = ""
	if select_level:
		get_tree().change_scene_to_file(select_level_scene_path)

		
func _on_start_body_entered(body: Node2D) -> void:
		if body.is_in_group("balls"):
			body.call_deferred("queue_free")
			next_scene = continue_scene

func _on_select_level_body_entered(body: Node2D) -> void:
		if body.is_in_group("balls"):
			body.call_deferred("queue_free")
			select_level = true
