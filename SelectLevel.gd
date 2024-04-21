extends Control

var grid_gap_size = 0

func _ready():
	if SaverLoader.level_base_name_list:
		for level_name in SaverLoader.level_base_name_list:
				#按关卡数动态增加关卡选择按键
				print("打印文件名：",level_name)
				var custom_button = preload("res://Elements/levelButtons.tscn").instantiate()
				add_child(custom_button)
				var label = custom_button.get_node("Label") 
				label.text = level_name
				#每个关卡按键摆放位置
				custom_button.position = Vector2(200, grid_gap_size)
				grid_gap_size += 100
