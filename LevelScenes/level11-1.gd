extends Level

func subtotal() ->void:
		if not _is_calculating_subtotal:
			if _batting_score >= 40:
				_is_success = true
				_subtotal_to_done()
				print("闯关成功")
			elif _batting_score < 40 and _batting_count >5:
				_is_success = false
				_subtotal_to_done()
				print("闯关失败")
			else:
				_subtotal_to_wait()
				print("继续统计")
