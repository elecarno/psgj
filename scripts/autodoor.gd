class_name Autodoor
extends Node2D

@export var enabled: bool = true

func _on_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and enabled:
		open_door()

func _on_detect_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and enabled:
		close_door()

func lock_door(silent: bool = false):
	enabled = false
	$lock.visible = true
	close_door()
	if not silent:
		$sfx_lock.play()
	
func unlock_door():
	enabled = true
	$lock.visible = false
	
func open_door():
	$sprite.visible = false
	$door/col.set_deferred("disabled", true)
	$sfx_open.pitch_scale = 1 + randf_range(-0.05, 0.05)
	$sfx_open.play()

func close_door():
	$sprite.visible = true
	$door/col.set_deferred("disabled", false)
	$sfx_close.pitch_scale = 0.9 + randf_range(-0.05, 0.05)
	$sfx_close.play()
	
