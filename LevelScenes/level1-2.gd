extends Level

var score := 0

func _on_blue_bounce_body_entered(body) -> void:
	score = 5
	_batting_score += score
	emit_signal("level_to_main_score_completed", _batting_score)

func _score_subtotal() -> void:
	print("stop running")
	for node in get_tree().get_nodes_in_group("bonusAreas"):
		for group_name in node.get_groups():
			for ball in node.get_overlapping_bodies():
				if ball.is_in_group("balls"):
					if group_name == "score10":
						score = 10
					elif group_name == "score15":
						score = 15
					ball.is_in_group("objectBalls")
					ball.queue_free()
	var current_batting_score = get_batting_score_value()
	current_batting_score += score
	set_batting_score_value(current_batting_score)
	_batting_count += 1
	#给Main发信号更新分数
	emit_signal("level_to_main_score_completed", _batting_score)
	emit_signal("level_to_main_count_completed", _batting_count)

func subtotal() -> void:
	if not _is_calculating_subtotal:
		if _batting_score >= 30:
			_is_success = true
			_subtotal_to_done()
			print("闯关成功")
		elif _batting_score < 30 and _batting_count >=2:
			_is_success = false
			_subtotal_to_done()
			print("闯关失败")
		else:
			_subtotal_to_wait()
			print("继续统计")
