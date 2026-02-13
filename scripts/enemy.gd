class_name Enemy
extends CharacterBody2D

@onready var mana_pellet: PackedScene = preload("res://prefabs/mana_pellet.tscn")

var room: Room = null

@export var MAX_SPEED = 25
@export var ACCELERATION = 12
@export var MANA_GIVE = 0

@export var MAX_HEALTH: int = 10
var health: int

@export var PROJECTILE: PackedScene
@export var PROJECTILE_SPEED: float = 150.0

var player: Player
var activated: bool = false
var show_shoot_line: bool = false
var shoot_direction: Vector2 = Vector2.ZERO
var rewind_pos: Vector2 = Vector2.ZERO
var pre_rewind_pos: Vector2 = Vector2.ZERO
var ignore_radius: int = 0
var dead: bool = false

@onready var nav_agent: NavigationAgent2D = $nav_agent
@onready var sfx: SfxPlayer = $sfx

@export var sfx_damage: AudioStream
@export var sfx_shoot: AudioStream
@export var sfx_death: AudioStream

# behaviour variables
@export var beh_hold_distance: bool = true
@export var beh_burstfire: bool = false
@export var beh_shotgun: bool = false
@export var HOLD_DISTANCE: int = 48
@export var SHOOT_INTERVAL: float = 1
@export var SHOTGUN_ANGLE: float = 30

func _ready() -> void:
	$shoot_timer.wait_time = SHOOT_INTERVAL + randf_range(-0.1, 0.1)
	health = MAX_HEALTH
	timeloop.enemies.append(self)
	rewind_pos = global_position
	

func activate(body: Node2D):
	if not dead:
		activated = true
		player = body
		nav_agent.target_position = player.global_position
		print("activated enemy, aggro on " + str(body.name))
		$shoot_line.visible = true
		$shoot_timer.start()


func reset():
	activated = false
	dead = false
	health = MAX_HEALTH
	$sprite.rotation = deg_to_rad(0)
	$shoot_line.width = 0
	$rewind_line.width = 0
	$col.set_deferred("disabled", false)
	print("reset " + name)


func deactivate():
	activated = false
	$shoot_line.width = 0
	$rewind_line.width = 0
	print("deactivated " + name)


func _physics_process(delta: float) -> void:
	if not activated:
		return
		
	if not nav_agent.is_target_reached() and player.global_position.distance_to(global_position) > HOLD_DISTANCE:
		var nav_point_direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = lerp(velocity, nav_point_direction * MAX_SPEED, ACCELERATION * delta)
		move_and_slide()
		
	if velocity.x < 0:
		$sprite.scale = Vector2(-1, 1)
	else:
		$sprite.scale = Vector2(1, 1)
		
	if show_shoot_line:
		$shoot_line.width = lerpf($shoot_line.width, 0, delta * 2)
		
	$rewind_line.width = lerpf($rewind_line.width, 0, delta*8)
	$rewind_line.set_point_position(0, to_local(pre_rewind_pos))
	$rewind_line.set_point_position(1, to_local(rewind_pos))
	
	#if global_position.distance_to(player.global_position) > ignore_radius:
		#deactivate()
		
	
func rewind():
	if activated:
		$rewind_line.visible = true
		$rewind_line.width = 4
		pre_rewind_pos = global_position
		global_position = rewind_pos
		$rewind_particles.emitting = true
	

func take_damage(damage: int, source: String = "unknown"):
	health -= damage
	print(name + " took " + str(damage) + " damage from " + source)
	sfx.play_sound(sfx_damage)
	$sprite.material.set_shader_parameter("enabled", true)
	$hit_flash_timer.start()
	if health <= 0:
		die()
		sfx.play_sound(sfx_death)
		dead = true
		

func die():
	$sprite.rotation = deg_to_rad(90)
	velocity = Vector2.ZERO
	activated = false
	$shoot_line.visible = false
	$col.set_deferred("disabled", true)
	room.remaining_enemies -= 1
	room.update_door()
	
	for i in range(MANA_GIVE):
		var new_pellet: ManaPellet = mana_pellet.instantiate()
		new_pellet.global_position = global_position + Vector2(
			randi_range(-3, 3),
			randi_range(-3, 3)
		)
		timeloop.world.add_child(new_pellet)
		
	MANA_GIVE = round(MANA_GIVE/2)
	if MANA_GIVE < 1:
		MANA_GIVE = 1
	
	print(name + " died")
	
func shoot_projectile():
	if activated:
		var new_projectile: Projectile = PROJECTILE.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = shoot_direction
		new_projectile.MAX_SPEED = PROJECTILE_SPEED
		timeloop.world.add_child(new_projectile)
		
		if beh_shotgun:
			var new_projectile_2: Projectile = PROJECTILE.instantiate()
			new_projectile_2.global_position = global_position
			var new_angle_2 = shoot_direction.angle() + deg_to_rad(SHOTGUN_ANGLE)/2
			new_projectile_2.direction = Vector2.ONE.from_angle(new_angle_2).normalized()
			new_projectile_2.MAX_SPEED = PROJECTILE_SPEED
			timeloop.world.add_child(new_projectile_2)
			
			var new_projectile_3: Projectile = PROJECTILE.instantiate()
			new_projectile_3.global_position = global_position
			var new_angle_3 = shoot_direction.angle() - deg_to_rad(SHOTGUN_ANGLE)/2
			new_projectile_3.direction = Vector2.ONE.from_angle(new_angle_3).normalized()
			new_projectile_3.MAX_SPEED = PROJECTILE_SPEED
			timeloop.world.add_child(new_projectile_3)
		
		sfx.play_sound(sfx_shoot)
		$shoot_timer.start()


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
		$shoot_timer.wait_time = SHOOT_INTERVAL + randf_range(-0.15, 0.15)
		if beh_burstfire:
			$burst_timer.start()


func _on_rewind_timer_timeout() -> void:
	rewind_pos = global_position


func _on_hit_flash_timer_timeout() -> void:
	$sprite.material.set_shader_parameter("enabled", false)


func _on_burst_timer_timeout() -> void:
	shoot_projectile()
