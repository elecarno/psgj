class_name Player
extends CharacterBody2D

enum WEAPONS {
	KNIFE,
	SWORD,
	PISTOL,
	HAND_CANNON,
	BEAM_CANNON
}

const MAX_SPEED = 115
const ACCELERATION = 15
const DASH_SPEED = 320
const GRAPPLE_MAX_SPEED = 220
const GRAPPLE_ACCELERATION = 7

const GRAPPLE_DAMAGE = 10

const MAX_HEALTH: int = 3
var health: int = 3

var can_dash: bool = true
var can_grapple: bool = true
var can_parry: bool = true
var can_rewind: bool = true

var is_grappling: bool = false
var grapple_target: Enemy = null
var possessed_weapons: Array[WEAPONS] = [
	WEAPONS.KNIFE,
	WEAPONS.SWORD,
	WEAPONS.PISTOL,
	WEAPONS.HAND_CANNON,
	WEAPONS.BEAM_CANNON
]
var current_weapon: WEAPONS = WEAPONS.KNIFE
var current_weapon_idx: int = 0
var input: Vector2 = Vector2.ZERO
var rewind_pos: Vector2 = Vector2.ZERO
var pre_rewind_pos: Vector2 = Vector2.ZERO

@onready var grapple_raycast: RayCast2D = $grapple_raycast
@onready var sfx: SfxPlayer = $sfx

@onready var sfx_damage: AudioStream = preload("res://sfx/damage2.wav")
@onready var sfx_dash: AudioStream = preload("res://sfx/dash.wav")
@onready var sfx_grapple_grab: AudioStream = preload("res://sfx/grapple_grab.wav")
@onready var sfx_grapple_extend: AudioStream = preload("res://sfx/grapple_extend.wav")
@onready var sfx_grapple_retract: AudioStream = preload("res://sfx/grapple_retract.wav")
@onready var sfx_grapple_hit: AudioStream = preload("res://sfx/gunshot4.wav")
@onready var sfx_rewind: AudioStream = preload("res://sfx/energy2.wav")

func _ready() -> void:
	rewind_pos = global_position
	$"../rewind_indicator".global_position = rewind_pos
	$"../rewind_indicator/rewind_particles".emitting = true

func _physics_process(delta):
	# main movement
	input = Input.get_vector("left", "right", "up", "down").normalized()
	if not is_grappling:
		velocity = lerp(velocity, input * MAX_SPEED, delta * ACCELERATION)
	
	#cam pivot
	$cam.position = lerp($cam.position, get_local_mouse_position() * 0.25, delta*16)
	
	# fast dash ability
	if Input.is_action_just_pressed("dash") and can_dash and not is_grappling:
		velocity += input * DASH_SPEED
		sfx.play_sound(sfx_dash)
		can_dash = false
		$cooldown_dash.start()
		
	# grapple ability
	if Input.is_action_just_pressed("grapple") and can_grapple and not is_grappling:
		var grapple_target_vector = to_local(get_global_mouse_position())
		grapple_raycast.target_position = grapple_target_vector
		grapple_raycast.force_raycast_update()
		sfx.play_sound(sfx_grapple_extend)
		if grapple_raycast.is_colliding():
			print("grapple colliding")
			if grapple_raycast.get_collider() is Enemy:
				print("grappling to " + grapple_raycast.get_collider().name)
				velocity = Vector2.ZERO
				grapple_target = grapple_raycast.get_collider()
				is_grappling = true
				can_grapple = false
				sfx.play_sound(sfx_grapple_grab)
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
		$weapon/sprite.visible = false
		
	
	# weapon switching
	if Input.is_action_just_pressed("switch"):
		if current_weapon < len(possessed_weapons)-1:
			current_weapon_idx += 1
		else:
			current_weapon_idx = 0
		current_weapon = possessed_weapons[current_weapon_idx]
		update_weapon()
		
		
	# rewind ability
	if Input.is_action_just_pressed("rewind") and can_rewind:
		pre_rewind_pos = global_position
		global_position = rewind_pos
		timeloop.rewind_enemies()
		can_rewind = false
		$rewind_line.width = 4
		$rewind_cooldown.start()
		sfx.play_sound(sfx_rewind)
		$rewind_particles.emitting = true
		
	$rewind_line.width = lerpf($rewind_line.width, 0, delta*8)
	$rewind_line.set_point_position(0, to_local(pre_rewind_pos))
	$rewind_line.set_point_position(1, to_local(rewind_pos))
		
	move_and_slide()
	

func update_weapon():
	$weapon/sprite.frame_coords = Vector2(current_weapon, 2)


func take_damage():
	health -= 1
	$cam.camera_shake(2.5)
	timeloop.frame_freeze(0.05, 0.5)
	sfx.play_sound(sfx_damage)
	print("player took 1 damage")
	$damage_particles.emitting = true
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
			sfx.play_sound(sfx_grapple_hit)
			$cam.camera_shake(2.0)
			$cooldown_grapple.start()


# timer timouts
func _on_cooldown_dash_timeout() -> void:
	can_dash = true

func _on_cooldown_grapple_timeout() -> void:
	can_grapple = true

func _on_parry_timer_timeout() -> void:
	$parry/col.set_deferred("disabled", true)
	$parry/sprite.visible = false
	$weapon/sprite.visible = true

func _on_parry_cooldown_timeout() -> void:
	can_parry = true


func _on_rewind_timer_timeout() -> void:
	rewind_pos = global_position
	$"../rewind_indicator".global_position = rewind_pos
	$"../rewind_indicator/rewind_particles".emitting = true


func _on_rewind_cooldown_timeout() -> void:
	can_rewind = true
