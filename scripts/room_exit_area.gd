extends Area2D

@onready var room: Room = get_parent()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		room.deactivate_enemies()
		room._on_room_body_exited(body)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		room._on_room_body_entered(body)
