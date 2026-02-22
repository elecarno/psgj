extends Control

@onready var intro_cutscene: PackedScene = preload("res://intro_cutscene.tscn")

func _ready() -> void:
	$btn_play.disabled = false
	timeloop.loop_is_active = false


func _on_btn_play_pressed() -> void:
	print("load game")
	var intro = intro_cutscene.instantiate()
	get_tree().get_root().add_child(intro)
	queue_free()
