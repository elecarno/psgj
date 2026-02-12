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
		
	var mod_a = $rewind_overlay.modulate.a
	$rewind_overlay.modulate = Color(1.0, 1.0, 1.0, lerp(mod_a, 0.0, delta*4))
	
