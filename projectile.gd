class_name Projectile
extends Area2D

@export var MAX_SPEED = 100
var is_enemy_projectile: bool = true
var direction: Vector2

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * MAX_SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		return
	
	if body.is_in_group("player") and is_enemy_projectile:
		body.take_damage()
		queue_free()
	else:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("parry_collider"):
		print("parried")
		timeloop.frame_freeze(0.1, 0.4)
		queue_free()
