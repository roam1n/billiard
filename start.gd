extends Control

@onready var cueball: RigidBody2D = $CueBall

#var next_scene:String = "res://LevelScenes/level_1-1.tscn"
var next_scene:String = ""
var continue_scene:String = ""

const MAX_RADIUS := 324

func _ready() -> void:
	#pass
	#if next_scene:
		#print("faaaaaaaaaaaaaaa", next_scene)
		#get_tree().change_scene_to_file(next_scene)
		#next_scene = ""
	continue_scene = SaverLoader.latest_scene()

func _physics_process(_delta:float) -> void:
	print("aaaaaaaa")
	if cueball:
		cueball._cue_position()
		if Input.is_action_just_pressed("left_mouse"):
			cueball._in_running()
	if next_scene:
		print(next_scene)
		get_tree().change_scene_to_file(next_scene)
		next_scene = ""

		
func _on_start_body_entered(body: Node2D) -> void:
		if body.is_in_group("balls"):
			body.call_deferred("queue_free")
			next_scene = continue_scene
	#if body.is_in_group("balls"):
		#body.call_deferred("queue_free")
		#next_scene = "res://LevelScenes/level_1-1.tscn"
			##if next_scene:
		#print("faaaaaaaaaaaaaaa", next_scene)
		#get_tree().change_scene_to_file(next_scene)
		#next_scene = ""

func _on_select_level_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.call_deferred("queue_free")
		next_scene = continue_scene
