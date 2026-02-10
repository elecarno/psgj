class_name SfxPlayer
extends Node2D

func play_sound(sound: AudioStream):
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.stream = sound
	player.autoplay = true
	player.pitch_scale += randf_range(-0.05, 0.05)
	add_child(player)
	
func _physics_process(delta: float) -> void:
	for player in get_children():
		if not player.is_playing:
			player.queue_free()
