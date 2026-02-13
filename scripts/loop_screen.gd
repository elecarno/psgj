extends Control

func _on_btn_play_pressed() -> void:
	timeloop.reset_timer()
	visible = false

func set_values(is_death: bool = false):
	$lab_loop_stats.text = (
		"Loop " + str(timeloop.loop_count + 1) + " will be "
		+ str(timeloop.current_loop_time) + "s long.\n\nYou will start with "
		+ str(timeloop.stored_mana) + " energy."
	)
	
	var splash_text: String = "Something went wrong."
	randomize()
	var splash_num: int = randi_range(0, 3)
	
	if not is_death:
		$overlay_loop.visible = true
		$overlay_death.visible = false
		$lab_splash_loop.visible = true
		$lab_splash_death.visible = false
		$lab_loop_title.text = "COMPLETED LOOP " + str(timeloop.loop_count)
		
		match splash_num:
			0: splash_text = "You lead a noble cause."
			1: splash_text = "The Frontier will remember your sacrifices."
			2: splash_text = "Your victory will be celebrated by all."
			3: splash_text = "Your hand is that of mercy and grace."
		$lab_splash_loop.text = splash_text
	else:
		$overlay_loop.visible = false
		$overlay_death.visible = true
		$lab_splash_loop.visible = false
		$lab_splash_death.visible = true
		$lab_loop_title.text = "TERMINATED IN LOOP " + str(timeloop.loop_count)
		
		match splash_num:
			0: splash_text = "There will be no-one to remember your sins."
			1: splash_text = "The Frontier will not remember your sacrifices."
			2: splash_text = "You will be alone at the end of this all."
			3: splash_text = "Your hand decides many fates."
		$lab_splash_death.text = splash_text
	
