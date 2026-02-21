extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$"../sfx_bg/mus_s2".stop()
		$"../loop_timer".stop()
