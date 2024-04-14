extends Resource
class_name SavedGame


#@export var latest_level:String
var latest_level: String = ""
@export var levels_data :Dictionary = {
	"current_level": "",
	"score": 0,
	"count":0,
	"is_successed":false
}

func _set_level_data(_current_level:StringName, _score:int, _count:int, _is_successed: bool) -> void:
	levels_data["current_level"] = _current_level
	levels_data["score"] = _score
	levels_data["count"] = _count
	levels_data["is_successed"] = _is_successed

func _get_level_data(_name:StringName) -> Dictionary:
	return levels_data
