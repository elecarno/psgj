extends Node

var loop_is_active: bool = true

var was_loop_death: bool = false

@onready var world: Node2D
@onready var loop_timer: Timer
@onready var hud: HUD
var rooms: Array = []

@onready var player: Player

var enemies: Array[Enemy]

var current_loop_time: int = 16
var stored_mana: int = 0
var loop_count: int = 1

var loop_pos: Vector2 = Vector2.ZERO

var sector_two: PackedScene = preload("res://sector_two.tscn")
var sector_three: PackedScene = preload("res://sector_three.tscn")

func initialise():
	loop_timer = world.get_node("loop_timer")
	player = world.get_node("player")
	hud = world.get_node("canvas/hud")
	
	rooms = world.get_node("rooms").get_children()
	rooms.remove_at(0) # removes "sfx_unlock"
	
	loop_timer.wait_time = current_loop_time
	if loop_is_active:
		loop_timer.start()
	
func frame_freeze(timescale, duration):
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1
	
func call_camera_shake(strength: float):
	player.get_node("cam").camera_shake(strength)
	
	
func new_loop(is_death: bool = false):
	was_loop_death = is_death
	
	current_loop_time += round(stored_mana / 2)
	stored_mana = round(stored_mana / 2)
	
	player.is_grappling = false
	player.velocity = Vector2.ZERO
	player.global_position = loop_pos
	player._on_rewind_timer_timeout()
	player.health = player.MAX_HEALTH
	for room in rooms:
		room.loop_reset(was_loop_death)
	
	player.player_is_active = false
	loop_timer.stop()
	timeloop.hud.set_loop_screen(was_loop_death)
	

func reset_timer():
	if not loop_is_active:
		return
	
	loop_count += 1
	loop_timer.wait_time = current_loop_time
	loop_timer.start()
	reset_loop()
	
func reset_loop():
	if not loop_is_active:
		return
	
	# duped code from new_loop() to fix grapple bleeding into next loop bug
	player.is_grappling = false
	player.velocity = Vector2.ZERO
	player.global_position = loop_pos
	player._on_rewind_timer_timeout()
	player.health = player.MAX_HEALTH
	
	for room in rooms:
		room.loop_reset(was_loop_death)
		
	player.player_is_active = true
	hud.update_data()
	
func rewind_enemies():
	if not loop_is_active:
		return
	
	for enemy in enemies:
		enemy.rewind()
		
		
func switch_to_sector_two():
	var current_player_max_health = player.MAX_HEALTH
	var current_player_weapons = player.possessed_weapons
	var current_player_weapon_idx = player.current_weapon_idx
	var current_player_weapon = player.current_weapon
	var current_player_dash = player.unlocked_dash
	
	loop_is_active = false
	get_tree().get_root().get_node("world").queue_free()
	var sect_new = sector_two.instantiate()
	sect_new.name = "world"
	get_tree().get_root().add_child(sect_new)
	world = sect_new
	loop_is_active = true
	initialise()
	
	player.MAX_HEALTH = current_player_max_health
	player.health = player.MAX_HEALTH
	player.possessed_weapons = current_player_weapons
	player.current_weapon_idx = current_player_weapon_idx
	player.current_weapon = current_player_weapon
	player.can_dash = current_player_dash
	
func switch_to_sector_three():
	var current_player_max_health = player.MAX_HEALTH
	var current_player_weapons = player.possessed_weapons
	var current_player_weapon_idx = player.current_weapon_idx
	var current_player_weapon = player.current_weapon
	var current_player_dash = player.unlocked_dash
	
	loop_is_active = false
	get_tree().get_root().get_node("world").queue_free()
	var sect_new = sector_three.instantiate()
	sect_new.name = "world"
	get_tree().get_root().add_child(sect_new)
	world = sect_new
	loop_is_active = true
	initialise()
	
	player.MAX_HEALTH = current_player_max_health
	player.health = player.MAX_HEALTH
	player.possessed_weapons = current_player_weapons
	player.current_weapon_idx = current_player_weapon_idx
	player.current_weapon = current_player_weapon
	player.can_dash = current_player_dash
	
func _physics_process(delta: float) -> void:
	if not loop_is_active:
		return
	
	if Input.is_action_just_pressed("force_loop"):
		new_loop()
