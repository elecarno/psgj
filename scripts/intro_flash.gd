extends ColorRect

func _ready() -> void:
	visible = true
	
func _physics_process(delta: float) -> void:
	modulate = Color(1.0, 1.0, 1.0, lerp(modulate.a, 0.0, delta*6))
	
	if modulate.a < 0.005:
		queue_free()
