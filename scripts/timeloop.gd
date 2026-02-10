extends Node

@onready var world: Node2D = get_tree().get_root().get_node("world")
@onready var loop_timer: Timer

@onready var player: Player

@onready var lab_timer: Label
@onready var slider_timer: HSlider
@onready var lab_loop_count: Label

var enemies: Array[Enemy]

var current_loop_time: float = 300
var loop_count: int = 1

func _ready() -> void:
	loop_timer = world.get_node("loop_timer")
	
	player = world.get_node("player")
	
	var hud = world.get_node("canvas/hud")
	
	lab_timer = hud.get_node("lab_timer")
	slider_timer = hud.get_node("slider_timer")
	lab_loop_count = hud.get_node("lab_loop_count")
	
	reset_timer()
	
func frame_freeze(timescale, duration):
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1
	
func call_camera_shake(strength: float):
	player.get_node("cam").camera_shake(strength)

func reset_timer():
	loop_timer.wait_time = current_loop_time
	slider_timer.max_value = current_loop_time
	loop_timer.start()
	reset_loop()
	
func reset_loop():
	loop_count += 1
	
	player.global_position = Vector2.ZERO
	
func rewind_enemies():
	for enemy in enemies:
		enemy.rewind()
	
func _physics_process(delta: float) -> void:
	lab_timer.text = str(round(loop_timer.time_left))
	slider_timer.value = loop_timer.time_left
