extends Node2D


@export var custom_color:Color = Color.CORAL;

var shader_resource:Shader = preload("res://resources/ball.gdshader")

func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("custom_color", Vector3(custom_color.r, custom_color.g, custom_color.b))
