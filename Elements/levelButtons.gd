extends Control

@onready var label = $Label

func _on_button_pressed():
	get_tree().change_scene_to_file("res://LevelScenes/" + label.text + ".tscn")
	#TODO: 统一路径
	#TODO: 按键会一直存在没有释放，导致页面按键重复
