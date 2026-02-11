class_name Room
extends Node2D

@export var UNLOCKED: bool = false
@export var HAS_ENEMIES: bool = false
@export var enemies: Array[Enemy]
@export var door: Autodoor

var remaining_enemies: int = 0
var enemy_start_positions: Array[Vector2]

func _ready() -> void:
	if not UNLOCKED:
		$cover.visible = true
	
	if HAS_ENEMIES:
		set_enemies()
		for enemy in enemies:
			enemy_start_positions.append(enemy.global_position)

func update_door():
	if remaining_enemies <= 0:
		print("all enemies in " + name + " killed, opening door")
		door.enabled = true
		door.open_door()
		
func set_enemies():
	remaining_enemies = 0
	for enemy in enemies:
		enemy.room = self
		remaining_enemies += 1
		
func loop_reset():
	door.enabled = true
	door.close_door()
	if HAS_ENEMIES:
		set_enemies()
		for enemy in enemies:
			enemy.deactivate()
		for i in range(0, len(enemies)-1):
			enemies[i].global_position = enemy_start_positions[i]

func _on_room_body_entered(body: Node2D) -> void:
	if $cover.visible == true:
		$cover.visible = false
		$"../sfx_unlock".play()
	
	if body.is_in_group("player"):
		if HAS_ENEMIES:
			for enemy in enemies:
				if not enemy.activated:
					enemy.activate(body)
		
			if remaining_enemies > 0:
				door.enabled = false
				door.close_door()

func _on_room_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		door.enabled = true
