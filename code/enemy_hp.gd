extends PathFollow2D

var health: int = 100


func take_damage(damage: int) -> void:
	health -= damage

	if health <= 0:
		queue_free()
