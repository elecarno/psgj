extends Timer

func _on_timeout() -> void:
	timeloop.new_loop()
