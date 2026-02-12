class_name HUD
extends Control

func _ready() -> void:
	$"../crt".visible = true
	visible = true
	update_data()

func update_data():
	$slider_timer.max_value = timeloop.current_loop_time

func _physics_process(delta: float) -> void:
	$lab_loop_count.text = (
		"Current Loop: " + str(timeloop.loop_count)
		+ "\nStored Mana: " + str(timeloop.stored_mana)
	)
	$lab_timer.text = (
		str(roundi(timeloop.loop_timer.time_left)) + " / " 
		+ str(timeloop.current_loop_time) + " (+"
		+ str(roundi(timeloop.stored_mana / 2)) + ")"
	)
	$slider_timer.value = timeloop.loop_timer.time_left
