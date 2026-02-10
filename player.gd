class_name Player
extends CharacterBody2D

enum WEAPONS {
	KNIFE,
	SWORD,
	PISTOL,
	HAND_CANNON,
	BEAM_CANNON
}

const MAX_SPEED = 75
const ACCELERATION = 15
const DASH_SPEED = 250
const GRAPPLE_MAX_SPEED = 220
const GRAPPLE_ACCELERATION = 7

const GRAPPLE_DAMAGE = 10

const MAX_HEALTH: int = 3
var health: int = 3

var can_dash: bool = true
var can_grapple: bool = true
var can_parry: bool = true

var is_grappling: bool = false
var grapple_target: Enemy = null
var possessed_weapons: Array[WEAPONS] = [WEAPONS.KNIFE]
var current_weapon: WEAPONS = WEAPONS.KNIFE
var input: Vector2

@onready var grapple_raycast: RayCast2D = $grapple_raycast

func _physics_process(delta):
	# main movement
	input = Input.get_vector("left", "right", "up", "down").normalized()
	if not is_grappling:
		velocity = lerp(velocity, input * MAX_SPEED, delta * ACCELERATION)
	
	# fast dash ability
	if Input.is_action_just_pressed("dash") and can_dash and not is_grappling:
		velocity += input * DASH_SPEED
		can_dash = false
		$cooldown_dash.start()
		
	# grapple ability
	if Input.is_action_just_pressed("grapple") and can_grapple and not is_grappling:
		var grapple_target_vector = to_local(get_global_mouse_position())
		grapple_raycast.target_position = grapple_target_vector
		grapple_raycast.force_raycast_update()
		if grapple_raycast.is_colliding():
			print("grapple colliding")
			if grapple_raycast.get_collider() is Enemy:
				print("grappling to " + grapple_raycast.get_collider().name)
				velocity = Vector2.ZERO
				grapple_target = grapple_raycast.get_collider()
				is_grappling = true
				can_grapple = false
				timeloop.frame_freeze(0.05, 0.5)
			else:
				print("not a valid grapple target")
				grapple_target = null
	else:
		grapple_raycast.target_position = lerp(grapple_raycast.target_position, Vector2.ZERO, delta * GRAPPLE_ACCELERATION)
		$grapple_line.set_point_position(1, grapple_raycast.target_position)
	
	if is_grappling:
		#$grapple_line.set_point_position(1, to_local(grapple_target.global_position))
		global_position = lerp(global_position, grapple_target.global_position, delta * GRAPPLE_ACCELERATION)

	
	# parry ability
	if Input.is_action_just_pressed("parry") and can_parry:
		var parry_direction = (get_global_mouse_position() - global_position).normalized()
		$parry.rotation = parry_direction.angle()
		$parry/col.disabled = false
		$parry/sprite.visible = true
		can_parry = false
		$parry_timer.start()
		$parry_cooldown.start()

	move_and_slide()
	

func take_damage():
	health -= 1
	print("player took 1 damage")
	if health <= 0:
		timeloop.reset_loop()
		health = MAX_HEALTH
	$"../canvas/hud/lab_health".text = "Health: " + str(health)


func _on_grapple_detect_body_entered(body: Node2D) -> void:
	if grapple_target != null:
		if body.name == grapple_target.name:
			print("grapple stop")
			velocity = Vector2.ZERO
			grapple_target.take_damage(GRAPPLE_DAMAGE)
			is_grappling = false
			grapple_target = null
			grapple_raycast.target_position = Vector2.ZERO
			$cooldown_grapple.start()


# timer timouts
func _on_cooldown_dash_timeout() -> void:
	can_dash = true
	print("can dash")

func _on_cooldown_grapple_timeout() -> void:
	can_grapple = true
	print("can grapple")

func _on_parry_timer_timeout() -> void:
	$parry/col.disabled = true
	$parry/sprite.visible = false

func _on_parry_cooldown_timeout() -> void:
	can_parry = true
