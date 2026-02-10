class_name Enemy
extends CharacterBody2D

@export var MAX_SPEED = 25
@export var ACCELERATION = 12

@export var MAX_HEALTH: int = 10
var health: int

@export var PROJECTILE: PackedScene

var player: Player
var activated: bool = false
var show_shoot_line: bool = false
var shoot_direction: Vector2 = Vector2.ZERO

@onready var nav_agent: NavigationAgent2D = $nav_agent

# behaviour variables
@export var beh_hold_distance: bool = true
@export var HOLD_DISTANCE: int = 48
@export var SHOOT_INTERVAL: float = 1

func _ready() -> void:
	$shoot_timer.wait_time = SHOOT_INTERVAL


func activate(body: Node2D):
	activated = true
	player = body
	nav_agent.target_position = player.global_position
	print("activated enemy, aggro on " + str(body.name))


func _physics_process(delta: float) -> void:
	if not activated:
		return
		
	if not nav_agent.is_target_reached() and player.global_position.distance_to(global_position) > HOLD_DISTANCE:
		var nav_point_direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = lerp(velocity, nav_point_direction * MAX_SPEED, ACCELERATION * delta)
		move_and_slide()
		
	if show_shoot_line:
		$shoot_line.width = lerpf($shoot_line.width, 0, delta * 2)
	

func take_damage(damage: int):
	health -= damage
	print(name + " took " + str(damage) + " damage")
	if health <= 0:
		die()
		

func die():
	queue_free()
	
func shoot_projectile():
	var new_projectile: Projectile = PROJECTILE.instantiate()
	new_projectile.global_position = global_position
	new_projectile.direction = shoot_direction
	timeloop.world.add_child(new_projectile)


func _on_nav_timer_timeout() -> void:
	if activated:
		if nav_agent.target_position != player.global_position:
			nav_agent.target_position = player.global_position


func _on_shoot_timer_timeout() -> void:
	if activated:
		shoot_direction = (player.global_position - global_position).normalized()
		$shoot_line.width = 1.5
		$shoot_line.rotation = shoot_direction.angle()
		show_shoot_line = true
		$shoot_delay.start()

func _on_shoot_delay_timeout() -> void:
	if activated:
		shoot_projectile()
		$shoot_timer.wait_time = SHOOT_INTERVAL + randf_range(-0.25, 0.25)
