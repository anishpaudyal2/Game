extends Node

var music_player: AudioStreamPlayer

var music_tracks: Array[AudioStream] = [
	preload("res://Music/First.mp3"),
	preload("res://Music/Second.mp3")
]

var current_music: int = 0


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	music_player.finished.connect(_on_music_finished)

	play_music()


func play_music() -> void:
	music_player.stream = music_tracks[current_music]
	music_player.play()


func _on_music_finished() -> void:
	current_music += 1

	if current_music >= music_tracks.size():
		current_music = 0

	play_music()
