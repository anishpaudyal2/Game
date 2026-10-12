extends Node2D

@export var speed: float = 500.0
@export var damage: int = 25

var target: Node2D


func _process(delta: float) -> void:
	if is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		global_position += direction * speed * delta
	else:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Area2D":
		var enemy = area.get_parent()

		print("BULLET HIT: ", enemy.name)
		print("Has take_damage: ", enemy.has_method("take_damage"))

		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			queue_free()
