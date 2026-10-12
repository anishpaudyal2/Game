extends Node2D

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Ui.tscn")

func _on_volume_button_pressed() -> void:
	get_tree().change_scene_to_file("res://VolumeMenu.tscn.tscn")
