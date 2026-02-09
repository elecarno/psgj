extends Node

@onready var world: Node2D = get_tree().get_root().get_node("world")
@onready var loop_timer: Timer

@onready var player: Player

@onready var lab_timer: Label
@onready var slider_timer: HSlider

var current_loop_time: float = 5

func _ready() -> void:
	loop_timer = world.get_node("loop_timer")
	
	player = world.get_node("player")
	
	lab_timer = world.get_node("canvas/control/lab_timer")
	slider_timer = world.get_node("canvas/control/slider_timer")
	
	reset_timer()

func reset_timer():
	loop_timer.wait_time = current_loop_time
	slider_timer.max_value = current_loop_time
	loop_timer.start()
	reset_loop()
	
func reset_loop():
	player.global_position = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	lab_timer.text = str(round(loop_timer.time_left))
	slider_timer.value = loop_timer.time_left
