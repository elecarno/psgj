extends Area2D

@export var item: String = "pistol"

func _physics_process(delta: float) -> void:
	rotate(deg_to_rad(15 * delta))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		match item:
			"dash":
				timeloop.player.can_dash = true
				timeloop.player.unlocked_dash = true
				timeloop.hud.show_message("Obtained DASH ability [SPACE]")
			"pistol":
				timeloop.player.possessed_weapons.append(timeloop.player.WEAPONS.PISTOL)
				timeloop.player.update_weapon()
				timeloop.hud.show_message("Obtained PISTOL [Q]")
			"cannon":
				timeloop.player.possessed_weapons.append(timeloop.player.WEAPONS.HAND_CANNON)
				timeloop.player.update_weapon()
				timeloop.hud.show_message("Obtained HAND CANNON [Q]")
			"beam":
				timeloop.player.possessed_weapons.append(timeloop.player.WEAPONS.BEAM_CANNON)
				timeloop.player.update_weapon()
				timeloop.hud.show_message("Obtained BEAM CANNON [Q]")
			"health":
				timeloop.player.MAX_HEALTH += 1
				timeloop.player.health = timeloop.player.MAX_HEALTH
				timeloop.hud.show_message("+1 maximum hitpoints")
		visible = false
		$col.set_deferred("disabled", true)
	
