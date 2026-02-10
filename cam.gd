extends Camera2D

#var cam_deadzone = 240
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#var target: Vector2 = event.position - get_viewport().size * 0.5
		#if target.length() < cam_deadzone:
			#self.position = Vector2(0, 0)
		#else:
			#self.position = target.normalized() * (target.length() - cam_deadzone) * 0.5
