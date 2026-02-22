extends ColorRect

#func _physics_process(_delta: float) -> void:
	#if not timeloop.loop_is_active:
		#return
		#
	#if timeloop.player.health > 2:
		#material.set_shader_parameter("chroma_offset_px", 1.6)
		#material.set_shader_parameter("luma_smear_px", 2.2)
	#elif timeloop.player.health == 2:
		#material.set_shader_parameter("chroma_offset_px", 2.4)
		#material.set_shader_parameter("luma_smear_px", 3.5)
	#else:
		#material.set_shader_parameter("chroma_offset_px", 5)
		#material.set_shader_parameter("luma_smear_px", 6)
