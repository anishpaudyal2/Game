extends Node2D

@onready var volume_slider: HSlider = $Panel/VolumeSlider
@onready var volume_label: Label = $Panel/VolumeLabel

var master_bus: int


func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")

	# Connect slider automatically
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)

	# Get current volume
	if AudioServer.is_bus_mute(master_bus):
		volume_slider.value = 0
	else:
		volume_slider.value = db_to_linear(
			AudioServer.get_bus_volume_db(master_bus)
		) * 100

	update_volume_label()


func _on_volume_slider_value_changed(value: float) -> void:

	# Update the text
	volume_label.text = "Volume: " + str(int(value)) + "%"

	# Mute at 0
	if value <= 0:
		AudioServer.set_bus_mute(master_bus, true)

	else:
		AudioServer.set_bus_mute(master_bus, false)

		var volume_linear: float = value / 100.0

		AudioServer.set_bus_volume_db(
			master_bus,
			linear_to_db(volume_linear)
		)


func update_volume_label() -> void:
	volume_label.text = "Volume: " + str(int(volume_slider.value)) + "%"


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://options_menu.tscn")
