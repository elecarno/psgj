extends Control

func show_text(text: String = "no text"):
	$lab_text.text = text
	visible = true
	get_tree().paused = true

func _on_btn_close_pressed() -> void:
	visible = false
	get_tree().paused = false
