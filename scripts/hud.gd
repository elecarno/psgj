class_name HUD
extends Control

func _ready() -> void:
	update_data()

func update_data():
	$slider_timer.max_value = timeloop.current_loop_time

func _physics_process(delta: float) -> void:
	$lab_loop_count.text = (
		"Current Loop: " + str(timeloop.loop_count)
		+ "\nStored Mana: " + str(timeloop.stored_mana)
	)
	$lab_timer.text = str(round(timeloop.loop_timer.time_left))
	$slider_timer.value = timeloop.loop_timer.time_left
