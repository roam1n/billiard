extends Area2D


@onready var label: Label = %Label

@export var text := "开始游戏"

func _ready() -> void:
	label.text = text
