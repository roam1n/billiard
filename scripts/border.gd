extends StaticBody2D


var is_border = true;

func get_border() -> Vector4:
	var top = -$top.shape.size.y - 50
	var right = $right.position.x + $right.shape.size.x / 2 + 50
	var bottom = $bottom.position.y + $bottom.shape.size.y * 1.5 + 50
	var left = -$left.shape.size.x - 50
	return Vector4(top, right, bottom, left)
