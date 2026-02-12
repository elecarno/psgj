class_name ManaPellet
extends Node2D

func _ready() -> void:
	$sfx_spawn.pitch_scale += randf_range(-0.15, 0.15)

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, timeloop.player.global_position, delta*4)
	
	if global_position.distance_to(timeloop.player.global_position) < 4:
		timeloop.stored_mana += 1
		timeloop.player.sfx.play_sound(timeloop.player.sfx_mana_pickup)
		queue_free()
