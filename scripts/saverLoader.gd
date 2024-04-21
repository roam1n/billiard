extends Node

var saved_game:SavedGame
var _path := "user://savegame.tres"
var level_file_path = "res://LevelScenes/"
var level_file_list = []
var level_base_name_list = []
var first_level_path = ""
var method_executed = false

func _ready() -> void:
	saved_game = load(_path) as SavedGame
	if not saved_game:
		saved_game = SavedGame.new()
	print(saved_game)

func save_game(current_level:StringName, score:int, count:int, is_successed:bool) -> void:
	saved_game._set_level_data(current_level, score, count, is_successed)
	ResourceSaver.save(saved_game, _path)

func next_level(current_level:StringName) -> StringName:
	var next_level_name = ""
	print("所有关卡名称:", level_base_name_list)
	if level_base_name_list.size() > 0:
		for i in range(0, level_base_name_list.size()):
			if level_base_name_list[i] == current_level:
				if i+1 < level_base_name_list.size():
					next_level_name = level_base_name_list[i+1]
					print("这个关卡名称:", next_level_name)
					break
		if next_level_name:
			return next_level_name
		else:
			return current_level
	return current_level
	
func _get_first_level_scene() -> String:
	_get_all_level()
	#第一关路径
	first_level_path = level_file_path + level_file_list[0]
	return first_level_path
	
func _get_all_level() ->void:
	if not method_executed:
		var dir = DirAccess.open(level_file_path)
		if dir:
			var pattern = "level[0-9]+-[0-9].tscn"
			var regexp = RegEx.new()
			regexp.compile(pattern)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if regexp.search(file_name):
					print("匹配的文件名：" + file_name)
					var base_name = file_name.left(file_name.length() - 5)	#将.tscn去掉
					level_file_list.append(file_name)
					level_base_name_list.append(base_name)
				file_name = dir.get_next()
		method_executed = true
	
