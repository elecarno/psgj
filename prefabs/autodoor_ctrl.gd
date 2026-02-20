extends Node2D

@export var room: Room

func _physics_process(delta: float) -> void:
	if room.remaining_enemies <= 0:
		$sprite.visible = false
		$lock.visible = false
		$door/col.set_deferred("disabled", true)
		$sfx_open.play()
