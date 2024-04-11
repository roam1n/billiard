extends Camera2D


@onready var border: StaticBody2D = %Border

func _ready() -> void:
	var limit_size:Vector4 = border.get_border()
	limit_top = ceil(limit_size.x)
	limit_right = ceil(limit_size.y)
	limit_bottom = ceil(limit_size.z)
	limit_left = ceil(limit_size.w)
	print("打印下相机范围",limit_size.x,limit_size.y,limit_size.z,limit_size.w)
	editor_draw_screen = true
