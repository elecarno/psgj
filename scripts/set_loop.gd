extends Area2D

@export var room_to_unlock: Room

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.loop_pos = global_position
		room_to_unlock.is_unlocked_this_run = false
		room_to_unlock.UNLOCKED = true
