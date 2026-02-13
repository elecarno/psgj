extends Timer

#func _ready() -> void:
	#timeloop.initialise()

func _on_timeout() -> void:
	timeloop.new_loop()
