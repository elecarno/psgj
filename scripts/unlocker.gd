extends Area2D

@onready var room: Room = get_parent()
var hud: HUD

var player_in_unlocker: bool = false

func _ready() -> void:
	hud = timeloop.hud

func _physics_process(delta: float) -> void:
	if player_in_unlocker:
		if Input.is_action_just_pressed("interact"):
			if timeloop.stored_mana >= room.MANA_COST:
				timeloop.stored_mana -= room.MANA_COST
				room.unlock()
				room.door.open_door()
				$col.set_deferred("disabled", true)
				$sprite.visible = false

func reset():
	$col.set_deferred("disabled", false)
	$sprite.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hud.get_node("lab_unlock").visible = true
		hud.get_node("lab_unlock").text = "[F] use " + str(room.MANA_COST) + " energy to expand reach to " + room.ROOM_NAME
		player_in_unlocker = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		hud.get_node("lab_unlock").visible = false
		player_in_unlocker = false
