class_name Projectile
extends Area2D

@export var MAX_SPEED = 100
@export var PROJECTILE_DAMAGE = 512 # for damaging enemies only
var is_enemy_projectile: bool = true
var direction: Vector2
var has_been_parried: bool = false
var parry_origin: Vector2 = Vector2.ZERO

@onready var mana_pellet: PackedScene = preload("res://prefabs/mana_pellet.tscn")
@onready var sfx_parry: AudioStream = preload("res://sfx/parry.wav")

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * MAX_SPEED * delta
	
	if has_been_parried:
		$parry_trail.set_point_position(1, to_local(parry_origin))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if not is_enemy_projectile:
			body.take_damage(PROJECTILE_DAMAGE)
			#print(name + " hit (enemy) " + body.name)
			queue_free()
		else:
			return
	
	if body.is_in_group("player") and is_enemy_projectile:
		body.take_damage()
		#print(name + " hit (player) " + body.name)
		queue_free()
	else:
		#print(name + " hit (other) " + body.name)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("parry_collider"):
		print("parried")
		$sfx.play_sound(sfx_parry)
		$parry_particles.emitting = true
		timeloop.frame_freeze(0.05, 0.5)
		timeloop.call_camera_shake(2.0)
		is_enemy_projectile = false
		direction = -direction
		MAX_SPEED *= 4
		has_been_parried = true
		parry_origin = global_position
		$parry_trail.visible = true
		
		var new_pellet: ManaPellet = mana_pellet.instantiate()
		new_pellet.global_position = global_position + Vector2(
			randi_range(-2, 2),
			randi_range(-2, 2)
		)
		timeloop.world.add_child(new_pellet)
		
		var new_pellet_2: ManaPellet = mana_pellet.instantiate()
		new_pellet_2.global_position = global_position + Vector2(
			randi_range(-2, 2),
			randi_range(-2, 2)
		)
		timeloop.world.add_child(new_pellet_2)
