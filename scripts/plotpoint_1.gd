extends Area2D

var player_in_area: bool = false

func _physics_process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			timeloop.loop_pos = global_position
			#timeloop.loop_is_active = false
			$"../loop_timer".stop()
			$"../sfx_bg/mus_s2".stop()
			$sfx.play()
			$sfx2.play()
			$covers.visible = true
			timeloop.hud.get_node("lab_unlock").visible = false
			$col.set_deferred("disabled", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").visible = true
		timeloop.hud.get_node("lab_unlock").text = "[F] Disable failsafes in antimatter warheads"
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").visible = false
		player_in_area = false
