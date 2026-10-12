extends Node

var money: int = 100

var max_tower_health: int = 100
var tower_health: int = 100


func add_money(amount: int) -> void:
	money += amount


func take_damage(amount: int) -> void:
	tower_health -= amount
	tower_health = max(tower_health, 0)

	print("Tower Health: ", tower_health)

	if tower_health <= 0:
		game_over()


func game_over() -> void:
	print("GAME OVER")
