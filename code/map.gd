extends Node2D


# ============================================================
# PREFABS
# ============================================================

var enemy_prefab: PackedScene = preload("res://Enemy1.tscn")
var slow_enemy_prefab: PackedScene = preload("res://SlowEnemy.tscn")
var fast_enemy_prefab: PackedScene = preload("res://FastEnemy.tscn")
var tank_enemy_prefab: PackedScene = preload("res://TankEnemy.tscn")
var faster_enemy_prefab: PackedScene = preload("res://FasterEnemy.tscn")

var blue_tank_prefab: PackedScene = preload("res://bluetank.tscn")
var red_tank_prefab: PackedScene = preload("res://redTank.tscn")
var black_tank_prefab: PackedScene = preload("res://blacktank.tscn")
var green_tank_prefab: PackedScene = preload("res://greenTank.tscn")
var double_tank_prefab: PackedScene = preload("res://doubleTank.tscn")
var large_tank_prefab: PackedScene = preload("res://largeTank.tscn")
var game_speed: int = 1

@onready var tower_health_bar: ProgressBar = $CanvasLayer/TowerHealthBar
@onready var you_died_label: Label = $CanvasLayer/YouDiedLabel
var game_over: bool = false


func update_tower_health() -> void:
	tower_health_bar.max_value = 100
	tower_health_bar.value = GameManager.tower_health
# ============================================================
# MAP NODES
# ============================================================

@onready var path: Path2D = $Path2D
@onready var spawn_timer: Timer = $spawnTimer
@onready var placement_area: Area2D = $PlacementArea


# ============================================================
# TANK SHOP
# ============================================================

var blue_tank_price: int = 50
var red_tank_price: int = 150
var black_tank_price: int = 400
var green_tank_price: int = 800
var double_tank_price: int = 1800
var large_tank_price: int = 3000

var placing_tank: bool = false
var tank_preview = null

var can_place_tank: bool = true


# ============================================================
# MONEY DISPLAY
# ============================================================

@onready var digit0: TextureRect = $CanvasLayer/MoneyDisplay/Digit0
@onready var digit1: TextureRect = $CanvasLayer/MoneyDisplay/Digit1
@onready var digit2: TextureRect = $CanvasLayer/MoneyDisplay/Digit2
@onready var digit3: TextureRect = $CanvasLayer/MoneyDisplay/Digit3
@onready var digit4: TextureRect = $CanvasLayer/MoneyDisplay/Digit4
@onready var digit5: TextureRect = $CanvasLayer/MoneyDisplay/Digit5
@onready var digit6: TextureRect = $CanvasLayer/MoneyDisplay/Digit6
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var dollar_sign: TextureRect = $CanvasLayer/MoneyDisplay/DollarSign
@onready var wave_counter: Label = $CanvasLayer/WaveCounter
# ============================================================
# SHOP PRICE LABELS
# ============================================================

@onready var blue_tank_price_label: Label = $CanvasLayer/Shop/BlueTankPrice
@onready var red_tank_price_label: Label = $CanvasLayer/Shop/RedTankPrice
@onready var black_tank_price_label: Label = $CanvasLayer/Shop/BlackTankPrice
@onready var green_tank_price_label: Label = $CanvasLayer/Shop/GreenTankPrice
@onready var double_tank_price_label: Label = $CanvasLayer/Shop/DoubleTankPrice
@onready var large_tank_price_label: Label = $CanvasLayer/Shop/LargeTankPrice

func update_shop_prices() -> void:
	blue_tank_price_label.text = "$" + str(blue_tank_price)
	red_tank_price_label.text = "$" + str(red_tank_price)
	black_tank_price_label.text = "$" + str(black_tank_price)
	green_tank_price_label.text = "$" + str(green_tank_price)
	double_tank_price_label.text = "$" + str(double_tank_price)
	large_tank_price_label.text = "$" + str(large_tank_price)


# ============================================================
# WAVE VARIABLES
# ============================================================



var current_wave: int = 0

var enemies_to_spawn: int = 4
var enemies_spawned: int = 0
var enemies_alive: int = 0

var wave_active: bool = false


# Enemies waiting to spawn
var spawn_queue: Array[PackedScene] = []

# Enemies remaining to spawn
var normal_enemies: int = 0
var fast_enemies: int = 0
var slow_enemies: int = 0

# ============================================================
# NUMBER TEXTURES
# ============================================================

var digit_textures = [
	preload("res://money/towerDefense_tile276.png"), # 0
	preload("res://money/towerDefense_tile277.png"), # 1
	preload("res://money/towerDefense_tile278.png"), # 2
	preload("res://money/towerDefense_tile279.png"), # 3
	preload("res://money/towerDefense_tile280.png"), # 4
	preload("res://money/towerDefense_tile281.png"), # 5
	preload("res://money/towerDefense_tile282.png"), # 6
	preload("res://money/towerDefense_tile283.png"), # 7
	preload("res://money/towerDefense_tile284.png"), # 8
	preload("res://money/towerDefense_tile285.png")  # 9
]


# ============================================================
# DOLLAR SIGN
# ============================================================

var dollar_texture = preload("res://money/towerDefense_tile287.png")


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	you_died_label.visible = false

	spawn_timer.timeout.connect(spawn_enemy)

	update_money_display()
	update_wave_counter()
	update_tower_health()

# ============================================================
# PROCESS
# ============================================================

func _process(_delta: float) -> void:
	update_money_display()
	update_tower_health()

	if placing_tank and tank_preview:
		tank_preview.global_position = get_global_mouse_position()
		check_tank_placement()

	if GameManager.tower_health <= 0 and not game_over:
		game_over = true

		Engine.time_scale = 1.0

		death_sound.play()

		you_died_label.visible = true
		restart_game()
#Restart the game after a delay
		
func restart_game() -> void:
	await get_tree().create_timer(3.0).timeout

	# Reset everything
	GameManager.money = 100
	GameManager.tower_health = GameManager.max_tower_health

	# Reload the level
	get_tree().reload_current_scene()


# ============================================================
# MONEY DISPLAY
# ============================================================

func update_money_display() -> void:
	var money: int = clamp(GameManager.money, 0, 9999999)

	var millions: int = (money / 1000000) % 10
	var hundred_thousands: int = (money / 100000) % 10
	var ten_thousands: int = (money / 10000) % 10
	var thousands: int = (money / 1000) % 10
	var hundreds: int = (money / 100) % 10
	var tens: int = (money / 10) % 10
	var ones: int = money % 10

	digit0.texture = digit_textures[millions]
	digit1.texture = digit_textures[hundred_thousands]
	digit2.texture = digit_textures[ten_thousands]
	digit3.texture = digit_textures[thousands]
	digit4.texture = digit_textures[hundreds]
	digit5.texture = digit_textures[tens]
	digit6.texture = digit_textures[ones]

	dollar_sign.texture = dollar_texture
	dollar_sign.visible = true
	dollar_sign.position = Vector2(0, 0)
	dollar_sign.z_index = 10

	# Hide all digits first
	digit0.visible = false
	digit1.visible = false
	digit2.visible = false
	digit3.visible = false
	digit4.visible = false
	digit5.visible = false
	digit6.visible = false

	var digit_count: int = str(money).length()

	var start_x: int = 30
	var spacing: int = 24

	digit0.z_index = 10
	digit1.z_index = 10
	digit2.z_index = 10
	digit3.z_index = 10
	digit4.z_index = 10
	digit5.z_index = 10
	digit6.z_index = 10


	if digit_count == 1:
		digit6.visible = true
		digit6.position.x = start_x

	elif digit_count == 2:
		digit5.visible = true
		digit6.visible = true

		digit5.position.x = start_x
		digit6.position.x = start_x + spacing

	elif digit_count == 3:
		digit4.visible = true
		digit5.visible = true
		digit6.visible = true

		digit4.position.x = start_x
		digit5.position.x = start_x + spacing
		digit6.position.x = start_x + spacing * 2

	elif digit_count == 4:
		digit3.visible = true
		digit4.visible = true
		digit5.visible = true
		digit6.visible = true

		digit3.position.x = start_x
		digit4.position.x = start_x + spacing
		digit5.position.x = start_x + spacing * 2
		digit6.position.x = start_x + spacing * 3

	elif digit_count == 5:
		digit2.visible = true
		digit3.visible = true
		digit4.visible = true
		digit5.visible = true
		digit6.visible = true

		digit2.position.x = start_x
		digit3.position.x = start_x + spacing
		digit4.position.x = start_x + spacing * 2
		digit5.position.x = start_x + spacing * 3
		digit6.position.x = start_x + spacing * 4

	elif digit_count == 6:
		digit1.visible = true
		digit2.visible = true
		digit3.visible = true
		digit4.visible = true
		digit5.visible = true
		digit6.visible = true

		digit1.position.x = start_x
		digit2.position.x = start_x + spacing
		digit3.position.x = start_x + spacing * 2
		digit4.position.x = start_x + spacing * 3
		digit5.position.x = start_x + spacing * 4
		digit6.position.x = start_x + spacing * 5

	elif digit_count == 7:
		digit0.visible = true
		digit1.visible = true
		digit2.visible = true
		digit3.visible = true
		digit4.visible = true
		digit5.visible = true
		digit6.visible = true

		digit0.position.x = start_x
		digit1.position.x = start_x + spacing
		digit2.position.x = start_x + spacing * 2
		digit3.position.x = start_x + spacing * 3
		digit4.position.x = start_x + spacing * 4
		digit5.position.x = start_x + spacing * 5
		digit6.position.x = start_x + spacing * 6


# ============================================================
# GENERIC TANK BUYING SYSTEM
# ============================================================

func buy_tank(tank_prefab: PackedScene, price_name: String) -> void:
	if placing_tank:
		return

	var price: int = get(price_name)

	if GameManager.money < price:
		print("Not enough money!")
		return

	GameManager.money -= price

	# Increase price by 50%
	set(price_name, ceil(price * 1.5))

	# Update the prices shown in the shop
	update_shop_prices()

	placing_tank = true

	tank_preview = tank_prefab.instantiate()
	add_child(tank_preview)

# Don't allow the preview tank to be clicked
	tank_preview.input_pickable = false

# Show the attack range while placing
	tank_preview.get_node("RangeVisual").visible = true

	tank_preview.modulate.a = 0.5

# ============================================================
# SHOP BUTTONS
# ============================================================

func _on_buy_blue_tank_pressed() -> void:
	buy_tank(blue_tank_prefab, "blue_tank_price")


func _on_buy_red_tank_pressed() -> void:
	buy_tank(red_tank_prefab, "red_tank_price")


func _on_buy_black_tank_pressed() -> void:
	buy_tank(black_tank_prefab, "black_tank_price")


func _on_buy_green_tank_pressed() -> void:
	buy_tank(green_tank_prefab, "green_tank_price")


func _on_buy_double_tank_pressed() -> void:
	buy_tank(double_tank_prefab, "double_tank_price")


func _on_buy_large_tank_pressed() -> void:
	buy_tank(large_tank_prefab, "large_tank_price")


# ============================================================
# CHECK TANK PLACEMENT
# ============================================================

func check_tank_placement() -> void:
	if tank_preview == null:
		return

	var mouse_position := get_global_mouse_position()

	var space_state := get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()

	query.position = mouse_position

	# PlacementArea is on collision layer 2
	query.collision_mask = 2

	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := space_state.intersect_point(query)

	var on_road := false

	for result in results:
		var collider = result["collider"]

		if collider == placement_area:
			on_road = true
			break

	if on_road:
		can_place_tank = false
		tank_preview.modulate = Color(1, 0.3, 0.3, 0.5)
	else:
		can_place_tank = true
		tank_preview.modulate = Color(0.3, 1, 0.3, 0.5)


# ============================================================
# MOUSE INPUT
# ============================================================

func _unhandled_input(event: InputEvent) -> void:
	if not placing_tank:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			place_tank()


# ============================================================
# PLACE TANK
# ============================================================

func place_tank() -> void:
	if tank_preview == null:
		return

	if not can_place_tank:
		print("Can't place Tank here!")
		return

	tank_preview.modulate = Color(1, 1, 1, 1)

	# Hide the attack range after placing
	tank_preview.get_node("RangeVisual").visible = false

	# Allow the placed tank to be clicked
	tank_preview.input_pickable = true

	placing_tank = false
	tank_preview = null

	print("Tank placed!")

# ============================================================
# Start WAVES
# ============================================================

func start_wave() -> void:
	if wave_active:
		return

	wave_active = true
	enemies_spawned = 0
	enemies_alive = 0

	spawn_queue.clear()


	# ========================================================
	# TOTAL NUMBER OF ENEMIES
	# ========================================================

	enemies_to_spawn = 3 + current_wave


	# ========================================================
	# WAVES 1 - 9
	# COCONUT ONLY
	# ========================================================

	if current_wave <= 9:

		for i in range(enemies_to_spawn):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVE 10 - 12
	# WATERMELON STARTS
	# ========================================================

	elif current_wave <= 12:

		# Maximum 6 watermelons
		var watermelon_amount: int = min(6, current_wave - 9)

		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)

		var coconut_amount: int = enemies_to_spawn - watermelon_amount

		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVES 13 - 20
	# WATERMELON + APPLE
	# MAXIMUM 6 OF EACH SPECIAL ENEMY
	# ========================================================

	elif current_wave <= 20:

		var watermelon_amount: int = min(6, current_wave - 9)

		var apple_amount: int = min(
			6,
			1 + int((current_wave - 13) / 2)
		)

		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)

		for i in range(apple_amount):
			spawn_queue.append(fast_enemy_prefab)

		var coconut_amount: int = enemies_to_spawn - watermelon_amount - apple_amount
		coconut_amount = max(0, coconut_amount)

		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVES 21 - 23
	# MAXIMUM 12 WATERMELON + APPLE
	# ========================================================

	elif current_wave < 24:

		var watermelon_amount: int = min(12, 6 + int((current_wave - 20) / 2))
		var apple_amount: int = min(12, 6 + int((current_wave - 20) / 2))

		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)

		for i in range(apple_amount):
			spawn_queue.append(fast_enemy_prefab)

		var coconut_amount: int = enemies_to_spawn - watermelon_amount - apple_amount
		coconut_amount = max(0, coconut_amount)

		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVES 24 - 34
	# MANGO STARTS
	# MAXIMUM 12 OF EACH SPECIAL ENEMY
	# ========================================================

	elif current_wave < 35:

		var watermelon_amount: int = min(12, 6 + current_wave - 20)
		var apple_amount: int = min(12, 6 + current_wave - 20)
		var mango_amount: int = min(12, 1 + int((current_wave - 24) / 2))

		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)

		for i in range(apple_amount):
			spawn_queue.append(fast_enemy_prefab)

		for i in range(mango_amount):
			spawn_queue.append(tank_enemy_prefab)

		var coconut_amount: int = enemies_to_spawn - watermelon_amount - apple_amount - mango_amount
		coconut_amount = max(0, coconut_amount)

		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVES 35 - 39
	# GREEN APPLE STARTS
	# MAXIMUM 12 OF EACH SPECIAL ENEMY
	# ========================================================

	elif current_wave < 40:

		var watermelon_amount: int = 12
		var apple_amount: int = 12
		var mango_amount: int = min(12, 6 + int((current_wave - 24) / 2))
		var green_apple_amount: int = min(
			12,
			1 + int((current_wave - 35) / 2)
		)

		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)

		for i in range(apple_amount):
			spawn_queue.append(fast_enemy_prefab)

		for i in range(mango_amount):
			spawn_queue.append(tank_enemy_prefab)

		for i in range(green_apple_amount):
			spawn_queue.append(faster_enemy_prefab)

		var coconut_amount: int = enemies_to_spawn - watermelon_amount - apple_amount - mango_amount - green_apple_amount
		coconut_amount = max(0, coconut_amount)

		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# WAVE 40+
	# MAXIMUM 18 OF EACH SPECIAL ENEMY
	# ========================================================

	else:

		var watermelon_amount: int = min(18, 12 + current_wave - 40)
		var apple_amount: int = min(18, 12 + current_wave - 40)
		var mango_amount: int = min(18, 12 + int((current_wave - 40) / 2))
		var green_apple_amount: int = min(18, 3 + int((current_wave - 40) / 2))


		# Add Watermelons
		for i in range(watermelon_amount):
			spawn_queue.append(slow_enemy_prefab)


		# Add Apples
		for i in range(apple_amount):
			spawn_queue.append(fast_enemy_prefab)


		# Add Mangoes
		for i in range(mango_amount):
			spawn_queue.append(tank_enemy_prefab)


		# Add Green Apples
		for i in range(green_apple_amount):
			spawn_queue.append(faster_enemy_prefab)


		# Remaining enemies are Coconuts
		var coconut_amount: int = enemies_to_spawn - watermelon_amount - apple_amount - mango_amount - green_apple_amount

		# Never let the amount go below 0
		coconut_amount = max(0, coconut_amount)


		for i in range(coconut_amount):
			spawn_queue.append(enemy_prefab)


	# ========================================================
	# RANDOMIZE ENEMY ORDER
	# ========================================================

	spawn_queue.shuffle()

	enemies_to_spawn = spawn_queue.size()

	print("Wave ", current_wave)
	print("Total enemies: ", enemies_to_spawn)

	spawn_timer.start()
	
# ============================================================
# SPAWN ENEMY
# ============================================================

func spawn_enemy() -> void:

	# Stop spawning when there are no enemies left
	if spawn_queue.is_empty():

		spawn_timer.stop()

		check_wave_finished()

		return


	# Get the next random enemy
	var enemy_prefab_to_spawn: PackedScene = spawn_queue.pop_front()

	var enemy = enemy_prefab_to_spawn.instantiate()


	# Add enemy to the path
	path.add_child(enemy)


	enemies_spawned += 1
	enemies_alive += 1


	# Detect when the enemy leaves the game
	if enemy != null:
		enemy.tree_exited.connect(enemy_died)


# ============================================================
# ENEMY DIED
# ============================================================

func enemy_died() -> void:
	enemies_alive -= 1

	check_wave_finished()


# ============================================================
# CHECK WAVE FINISHED
# ============================================================

func check_wave_finished() -> void:

	if spawn_queue.is_empty() and enemies_alive <= 0:

		wave_active = false

		print("Wave finished!")


# ============================================================
# NEXT WAVE
# ============================================================

func next_wave() -> void:
	if wave_active:
		return

	current_wave += 1

	update_wave_counter()

	start_wave()
	
	
#=============================================================	
#speedup function
#==============================================================

func _on_speed_button_pressed() -> void:
	if game_speed == 1:
		game_speed = 2

	elif game_speed == 2:
		game_speed = 4

	else:
		game_speed = 1

	Engine.time_scale = game_speed

	$CanvasLayer/SpeedButton.text = str(game_speed) + "x"

# ============================================================
# NEXT WAVE BUTTON
# ============================================================

func _on_next_wave_button_pressed() -> void:
	next_wave()
	
func update_wave_counter() -> void:
	wave_counter.text = "WAVE: " + str(current_wave)
	
	
# ============================================================
#Backbutton code 
# ============================================================


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Ui.tscn")
