extends Node


var LEVELS_PATH := {
	"level1-1": {"path": "res://LevelScenes/level1-1.tscn", "next": "level1-2"},
	"level1-2": {"path": "res://LevelScenes/level1-2.tscn", "next": "level1-3"}
}
var saved_game:SavedGame
var _path := "user://savegame.tres"
var level_file_path = "res://LevelScenes/"
var level_file_list = []
var level_base_name_list = []
var first_level_path = ""

func _ready() -> void:
	saved_game = load(_path) as SavedGame
	if not saved_game:
		saved_game = SavedGame.new()
	print(saved_game)
	_check_all_level_scene()

func save_game(current:StringName, score:int, count:int) -> void:
	saved_game.latest_level = _next_level(current)
	saved_game.set_level_data(current, score, count)
	ResourceSaver.save(saved_game, _path)

func _next_level(current:StringName) -> StringName:
	return LEVELS_PATH[current]["next"]   #这里current肯定是拿到关卡名称了

func latest_scene() -> String: #一开始和返回都会调用这个方法 saved_game.latest_level这个是全局变量
	if saved_game and saved_game.latest_level:
		print("xxxxx",saved_game.latest_level)
		return LEVELS_PATH[saved_game.latest_level]["path"]
	return first_level_path

func _is_next_level_exist() -> void:
	pass #检查是否有下一关
	
func _check_all_level_scene() -> void:
	var dir = DirAccess.open(level_file_path)
	if dir:
		var pattern = "level[0-9]+-[0-9]"
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
	#第一关路径
	first_level_path = level_file_path + level_file_list[0]
