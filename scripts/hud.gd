class_name HUD
extends Control

@export var health_markers: Array[TextureRect]

func _ready() -> void:
	$"../crt".visible = true
	visible = true
	update_data()

func update_data():
	$slider_timer.max_value = timeloop.current_loop_time
	
func set_rewind_overlay():
	$rewind_overlay.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
func set_mana_notif():
	$mana_notif.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
func set_loop_screen(is_death: bool = false):
	$"../loop_screen".visible = true
	$"../loop_screen".set_values(is_death)
	if is_death:
		$"../loop_screen/flash_death".modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		$"../loop_screen/flash".modulate = Color(1.0, 1.0, 1.0, 1.0)
	$"../loop_screen/sfx_flash".play()
	

func show_message(message: String):
	$lab_message.visible = true
	$lab_message.text = message
	$message_timeout.start()

func _physics_process(delta: float) -> void:
	$lab_loop_count.text = str(timeloop.loop_count)
	$lab_mana.text = str(timeloop.stored_mana)
	$lab_timer.text = (
		str(roundi(timeloop.loop_timer.time_left)) + " / " 
		+ str(timeloop.current_loop_time)
	)
	$lab_addition.text = "+" + str(round(timeloop.stored_mana / 2))
	$slider_timer.value = timeloop.loop_timer.time_left
	
	for marker in health_markers:
		marker.visible = false
	
	for i in range(0, (timeloop.player.health )):
		health_markers[i].visible = true
		
	var rewind_alpha = $rewind_overlay.modulate.a
	$rewind_overlay.modulate = Color(1.0, 1.0, 1.0, lerp(rewind_alpha, 0.0, delta*4))
	var mana_alpha = $mana_notif.modulate.a
	$mana_notif.modulate = Color(1.0, 1.0, 1.0, lerp(mana_alpha, 0.0, delta*8))
	
	var loop_flash_alpha = $"../loop_screen/flash".modulate.a
	$"../loop_screen/flash".modulate = Color(1.0, 1.0, 1.0, lerp(loop_flash_alpha, 0.0, delta*6))
	var loop_flash_death_alpha = $"../loop_screen/flash_death".modulate.a
	$"../loop_screen/flash_death".modulate = Color(1.0, 1.0, 1.0, lerp(loop_flash_death_alpha, 0.0, delta*6))
	
func _on_message_timeout_timeout() -> void:
	$lab_message.visible = false
