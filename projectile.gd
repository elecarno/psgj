class_name Projectile
extends Area2D

@export var MAX_SPEED = 100
@export var PROJECTILE_DAMAGE = 512 # for damaging enemies only
var is_enemy_projectile: bool = true
var direction: Vector2
var has_been_parried: bool = false
var parry_origin: Vector2 = Vector2.ZERO

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
		else:
			return
	
	if body.is_in_group("player") and is_enemy_projectile:
		body.take_damage()
		queue_free()
	else:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("parry_collider"):
		print("parried")
		timeloop.frame_freeze(0.05, 0.5)
		is_enemy_projectile = false
		direction = -direction
		MAX_SPEED *= 4
		has_been_parried = true
		parry_origin = global_position
		$parry_trail.visible = true
		#queue_free()
