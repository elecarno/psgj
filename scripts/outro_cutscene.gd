extends Control

var title_screen: PackedScene = preload("res://title_screen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		load_title()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	load_title()
	
func load_title():
	var title = title_screen.instantiate()
	get_tree().get_root().add_child(title)
	queue_free()
