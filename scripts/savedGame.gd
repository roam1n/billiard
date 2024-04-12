extends Resource
class_name SavedGame


#@export var latest_level:String
@export var levels_data:Dictionary
var latest_level: String = ""

func set_level_data(name:StringName, score:int, count:int) -> void:
	levels_data[name] = {score:score, count:count}

func get_level_data(name:StringName) -> Dictionary:
	return levels_data[name]
