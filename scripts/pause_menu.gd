extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if not $"../loop_screen".visible:
			visible = !visible
			get_tree().paused = !get_tree().paused


func _on_btn_resume_pressed() -> void:
	visible = false
	get_tree().paused = false
