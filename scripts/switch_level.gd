extends Area2D

@export var message: String = ""
@export var sector: int = 2

var player_in_switcher: bool = false

func _physics_process(delta: float) -> void:
	if player_in_switcher:
		if Input.is_action_just_pressed("interact"):
			if sector == 2:
				timeloop.switch_to_sector_two()
			elif sector == 3:
				timeloop.switch_to_sector_three()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").visible = true
		timeloop.hud.get_node("lab_unlock").text = "[F] " + message
		player_in_switcher = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timeloop.hud.get_node("lab_unlock").visible = false
		player_in_switcher = false
