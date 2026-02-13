extends Node2D

@onready var player: Player = $".."
@onready var sfx: SfxPlayer = $"../sfx"
@export var PROJECTILE: PackedScene

var shoot_pivot: Vector2

var can_rotate: bool = true
var can_attack: bool = true
var melee_damage: int = 0

var beam_start: Vector2 = Vector2.ZERO
var beam_end: Vector2 = Vector2.ZERO

# sfx
@onready var sfx_pistol: AudioStream = preload("res://sfx/pistol.wav")
@onready var sfx_hand_cannon: AudioStream = preload("res://sfx/hand_cannon.wav")
@onready var sfx_beam_cannon: AudioStream = preload("res://sfx/beam_cannon.wav")

func _physics_process(delta: float) -> void:
	if not player.player_is_active:
		return
	
	shoot_pivot = $sprite/shoot_pivot.global_position
	
	var rotate_direction = global_position.direction_to(get_global_mouse_position())
	if can_rotate:
		rotation = rotate_direction.angle()
	
	if get_global_mouse_position().x > player.global_position.x:
		$sprite.scale = Vector2(1,1)
		$"../sprite".scale = Vector2(1,1)
	else:
		$sprite.scale = Vector2(1,-1)
		$"../sprite".scale = Vector2(-1,1)
		
	if Input.is_action_just_pressed("attack") and can_attack:
		var shoot_direction: Vector2 = global_position.direction_to(get_global_mouse_position())
		var new_projectile: Projectile = PROJECTILE.instantiate()
		new_projectile.global_position = shoot_pivot
		new_projectile.direction = shoot_direction
		new_projectile.is_enemy_projectile = false
		
		if player.current_weapon == 0: # knife
			$firerate.wait_time = 0.15
			$hitbox_timer.wait_time = 0.1
			melee_damage = 3
			$hitbox/col.set_deferred("disabled", false)
			$hitbox_timer.start()
			
		if player.current_weapon == 1: # sword
			$firerate.wait_time = 0.4
			$hitbox_timer.wait_time = 0.15
			melee_damage = 15
			$hitbox/col.set_deferred("disabled", false)
			$hitbox_timer.start()
			
		if player.current_weapon == 2: # pistol
			new_projectile.PROJECTILE_DAMAGE = 5
			new_projectile.MAX_SPEED = 250
			$firerate.wait_time = 0.3
			timeloop.world.add_child(new_projectile)
			sfx.play_sound(sfx_pistol)
			$sprite/shoot_pivot/flash_pistol.emitting = true
			

		if player.current_weapon == 3: # hand cannon
			new_projectile.PROJECTILE_DAMAGE = 20
			new_projectile.MAX_SPEED = 450
			$firerate.wait_time = 1
			timeloop.world.add_child(new_projectile)
			sfx.play_sound(sfx_hand_cannon)
			$sprite/shoot_pivot/flash_cannon.emitting = true
			
		if player.current_weapon == 4: # beam cannon
			$firerate.wait_time = 2
			$hitbox_timer.wait_time = 0.15
			$hitbox_timer.start()
			$sprite/beam/col.set_deferred("disabled", false)
			$sprite/beam_line.width = 4
			melee_damage = 64
			timeloop.frame_freeze(0.05, 0.5)
			sfx.play_sound(sfx_beam_cannon)
			$"../cam".camera_shake(1.5)
			can_rotate = false
			$sprite/shoot_pivot/flash_beam.emitting = true
		
		can_attack = false
		$firerate.start()
		
	$sprite/beam_line.width = lerpf($sprite/beam_line.width, 0, delta*16)


func _on_firerate_timeout() -> void:
	can_attack = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(melee_damage)

func _on_beam_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(melee_damage)

func _on_hitbox_timer_timeout() -> void:
	$hitbox/col.set_deferred("disabled", true)
	$sprite/beam/col.set_deferred("disabled", true)
	can_rotate = true
