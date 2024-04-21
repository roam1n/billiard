extends Control

@onready var label = $Label

func _on_button_pressed():
	get_tree().change_scene_to_file("res://LevelScenes/" + label.text + ".tscn")
	#TODO: 没有做返回主菜单界面功能
