extends Camera2D

var shake_fade: float = 5.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func camera_shake(strength: float):
	shake_strength = strength

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)

func _physics_process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, delta * shake_fade)
		offset = random_offset()
