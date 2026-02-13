extends Area2D

var player_in_interact: bool = false
@export_multiline var text: String

func _input(event: InputEvent) -> void:
	if event.is_action("interact") and player_in_interact:
		timeloop.hud.get_parent().get_node("text_screen").show_text(text)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").text = "[F] Show Log"
		timeloop.hud.get_node("lab_unlock").visible = true
		player_in_interact = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").visible = false
		player_in_interact = false
