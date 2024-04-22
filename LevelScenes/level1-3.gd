extends Level

func _score_subtotal() -> void:
	print("stop running")
	var area_score := 0
	for node in get_tree().get_nodes_in_group("bonusAreas"):
		for group_name in node.get_groups():
			for ball in node.get_overlapping_bodies():
				if ball.is_in_group("balls"):
					if group_name == "score10":
						area_score = 10
					elif group_name == "score15":
						area_score = 15
				if ball.is_in_group("objectBalls"):
				# 销毁已得分的子球
					ball.queue_free()
	var current_batting_score = get_batting_score_value()
	current_batting_score += area_score
	set_batting_score_value(current_batting_score)
	_batting_count += 1
	print("多少分azzzzzzzz:",_batting_score)
	#给Main发信号更新分数
	emit_signal("level_to_main_score_completed", _batting_score)
	emit_signal("level_to_main_count_completed", _batting_count)

func subtotal() -> void:
	if not _is_calculating_subtotal:
		if _batting_score >= 40:
			_is_success = true
			_subtotal_to_done()
			print("闯关成功")
		elif _batting_score < 40 and _batting_count >=4:
			_is_success = false
			_subtotal_to_done()
			print("闯关失败")
		else:
			_subtotal_to_wait()
			print("继续统计")

func _on_blue_bounce_body_entered(body) -> void:
	var blue_bounce := 0
	blue_bounce = 5
	_batting_score += blue_bounce
	emit_signal("level_to_main_score_completed", _batting_score)

func _on_purple_bounce_body_entered(body):
	var purple_bounce := 0
	purple_bounce = -5
	_batting_score += purple_bounce
	emit_signal("level_to_main_score_completed", _batting_score)
