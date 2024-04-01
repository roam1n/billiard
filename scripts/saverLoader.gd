extends Node


var LEVELS_PATH := {
	"1-1": {"path": "res://LevelScenes/1-1.tscn", "next": "1-2"},
	"1-2": {"path": "res://LevelScenes/1-2.tscn", "next": "1-2"}
}
var saved_game:SavedGame
var _path := "user://savegame.tres"

func _ready() -> void:
	saved_game = load(_path) as SavedGame
	if not saved_game:
		saved_game = SavedGame.new()
	print(saved_game)

func save_game(current:StringName, score:int, count:int) -> void:
	saved_game.latest_level = _next_level(current)
	saved_game.set_level_data(current, score, count)
	ResourceSaver.save(saved_game, _path)

func _next_level(current:StringName) -> StringName:
	return LEVELS_PATH[current]["next"]

func latest_scene() -> String:
	if saved_game and saved_game.latest_level:
		return LEVELS_PATH[saved_game.latest_level]["path"]
	return LEVELS_PATH["1-1"]["path"]
