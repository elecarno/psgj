class_name Room
extends Node2D

@export var UNLOCKED: bool = false
@export var MANA_COST: int = 2
@export var ROOM_NAME: String = "Unknown Room"
@export var ROOM_RADIUS: int = 64
var is_unlocked_this_run: bool = true
var HAS_ENEMIES: bool = false
var enemies: Array[Enemy]
var door: Autodoor

var remaining_enemies: int = 0
var enemy_start_positions: Array[Vector2]

func _ready() -> void:
	$cover.visible = true
	
	if MANA_COST == 0:
		is_unlocked_this_run = false
	
	for child in get_children():
		if child is Enemy:
			HAS_ENEMIES = true
			enemies.append(child)
		if child is Autodoor:
			door = child
	
	if MANA_COST == 0:
		door.unlock_door()
	else:
		door.lock_door(true)
	
	if HAS_ENEMIES:
		set_enemies()
		for enemy in enemies:
			enemy_start_positions.append(enemy.global_position)

func unlock():
	UNLOCKED = true
	door.unlock_door()
	
func relock():
	UNLOCKED = false
	door.lock_door(true)
	$unlocker.reset()

func update_door():
	if remaining_enemies <= 0:
		print("all enemies in " + name + " killed, opening door")
		door.unlock_door()
		door.open_door()
		
func set_enemies():
	remaining_enemies = 0
	for enemy in enemies:
		enemy.room = self
		enemy.ignore_radius = ROOM_RADIUS
		remaining_enemies += 1
		

func deactivate_enemies():
	for enemy in enemies:
		if enemy.activated and not enemy.dead:
			enemy.deactivate()
		
		
func loop_reset(is_death: bool = false):
	if HAS_ENEMIES:
		set_enemies()
		for enemy in enemies:
			enemy.reset()
		for i in range(0, len(enemies)-1):
			enemies[i].global_position = enemy_start_positions[i]
	
	if UNLOCKED:
		if is_death:
			if is_unlocked_this_run:
				$cover.visible = true
				door.lock_door(true)
				door.close_door()
				$unlocker.reset()
			else:
				is_unlocked_this_run = false
				door.unlock_door()
				door.close_door()
		else:
			is_unlocked_this_run = false
			door.unlock_door()
			door.close_door()
	else:
		$cover.visible = true

func _on_room_body_entered(body: Node2D) -> void:
	if MANA_COST == 0:
		UNLOCKED = true
	
	if $cover.visible == true:
		$cover.visible = false
		$"../sfx_unlock".play()
		
	if not UNLOCKED:
		return
	
	if body.is_in_group("player"):
		if HAS_ENEMIES:
			for enemy in enemies:
				if not enemy.activated:
					enemy.activate(body)
		
			if remaining_enemies > 0:
				door.lock_door()
				door.close_door()

func _on_room_body_exited(body: Node2D) -> void:
	if not UNLOCKED:
		return
	
	if body.is_in_group("player"):
		if remaining_enemies <= 0:
			door.unlock_door()
