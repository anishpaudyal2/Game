extends StaticBody2D


# ============================================================
# TANK STATS
# ============================================================

@export var damage: int = 25
@export var attack_speed: float = 1.0
@export var damage_increase: int = 5
@export var attack_speed_decrease: float = 0.1
@export var bullet_scene: PackedScene
@export var bullets_per_shot: int = 1
@export var tank_upgrade_image: Texture2D


# ============================================================
# UPGRADE SETTINGS
# ============================================================

var upgrade_level: int = 0
var max_upgrade_level: int = 10

@export var base_tank_price: int = 50
var upgrade_price: int = 50


# ============================================================
# ATTACK
# ============================================================

var attack_timer: float = 0.0

@onready var attack_range: Area2D = $Area2D
@onready var bullet_spawn: Marker2D = $Marker2D
@onready var bullet_spawn2: Marker2D = get_node_or_null("Marker2D2")
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

# ============================================================
# READY
# ============================================================

func _ready() -> void:
	input_pickable = true

	# First upgrade costs the same as the tank's original price
	upgrade_price = base_tank_price


# ============================================================
# ATTACK SYSTEM
# ============================================================

func _process(delta: float) -> void:

	attack_timer -= delta

	var areas = attack_range.get_overlapping_areas()

	var target = null

	for area in areas:

		var enemy = area.get_parent()

		if enemy != null and enemy.has_method("take_damage"):
			target = enemy
			break

	if target != null:

		look_at(target.global_position)

		if attack_timer <= 0:

			shoot(target)

			attack_timer = attack_speed


# ============================================================
# SHOOT
# ============================================================

func shoot(enemy) -> void:

	# Play shooting sound
	shoot_sound.play()

	var spawn_points = [bullet_spawn]

	# Only add the second marker if this tank has one
	if bullet_spawn2 != null:
		spawn_points.append(bullet_spawn2)

	var number_of_bullets = min(
		bullets_per_shot,
		spawn_points.size()
	)

	for i in range(number_of_bullets):

		var bullet = bullet_scene.instantiate()

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = spawn_points[i].global_position

		bullet.target = enemy

		bullet.damage = damage


# ============================================================
# CLICK TANK
# ============================================================

func _input_event(_viewport, event, _shape_idx) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:

			var main_scene = get_tree().current_scene

			if main_scene.placing_tank:
				return

			var upgrade_system = main_scene.get_node(
				"CanvasLayer/TankUpgradeSystem"
			)

			upgrade_system.open_upgrade_menu(self)


# ============================================================
# UPGRADE TANK
# ============================================================

func upgrade() -> bool:

	if upgrade_level >= max_upgrade_level:
		return false

	if GameManager.money < upgrade_price:

		print("Not enough money!")

		return false

	GameManager.money -= upgrade_price

	upgrade_level += 1

	damage += damage_increase

	attack_speed = max(
		0.2,
		attack_speed - attack_speed_decrease
	)

	upgrade_price = ceil(
		upgrade_price * 1.5
	)

	print("Tank upgraded!")
	print("Level: ", upgrade_level)
	print("Damage: ", damage)
	print("Attack Speed: ", attack_speed)
	print("Next Upgrade: $", upgrade_price)

	return true
