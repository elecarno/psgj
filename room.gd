extends Area2D

@export var enemies: Array[Enemy]

var triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	if body.is_in_group("player"):
		for enemy in enemies:
			if not enemy.activated:
				enemy.activate(body)
		triggered = true
