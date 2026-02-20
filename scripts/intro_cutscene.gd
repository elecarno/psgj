extends Control

var sector_one: PackedScene = preload("res://sector_one.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		load_sector_one()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	load_sector_one()
	
func load_sector_one():
	var sect_new = sector_one.instantiate()
	sect_new.name = "world"
	get_tree().get_root().add_child(sect_new)
	timeloop.world = sect_new
	timeloop.loop_is_active = true
	timeloop.initialise()
	queue_free()
