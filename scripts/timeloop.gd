extends Node

@onready var world: Node2D = get_tree().get_root().get_node("world")
@onready var loop_timer: Timer
@onready var hud: HUD
var rooms: Array = []

@onready var player: Player

var enemies: Array[Enemy]

var current_loop_time: int = 30
var stored_mana: int = 0
var loop_count: int = 1

func _ready() -> void:
	loop_timer = world.get_node("loop_timer")
	
	player = world.get_node("player")
	
	hud = world.get_node("canvas/hud")
	
	rooms = world.get_node("rooms").get_children()
	rooms.remove_at(0) # removes "sfx_unlock"
	
	loop_timer.wait_time = current_loop_time
	loop_timer.start()
	
func frame_freeze(timescale, duration):
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1
	
func call_camera_shake(strength: float):
	player.get_node("cam").camera_shake(strength)

func reset_timer():
	current_loop_time += stored_mana
	stored_mana = 0
	loop_count += 1
	loop_timer.wait_time = current_loop_time
	loop_timer.start()
	reset_loop()
	
func reset_loop():
	player.global_position = Vector2.ZERO
	player._on_rewind_timer_timeout()
	
	for room in rooms:
		room.loop_reset()
		
	hud.update_data()
	
func rewind_enemies():
	for enemy in enemies:
		enemy.rewind()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("force_loop"):
		reset_timer()
