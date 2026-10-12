extends Panel


# ============================================================
# UI NODES
# ============================================================

@onready var tank_level: Label = $TankLevel
@onready var tank_damage: Label = $TankDamage
@onready var tank_attack_speed: Label = $TankAttackSpeed
@onready var upgrade_price: Label = $UpgradePrice
@onready var upgrade_button: Button = $UpgradeButton
@onready var close_button: Button = $CloseButton
@onready var tank_image: TextureRect = $Tank
@onready var tank_damage_next: Label = $TankDamageNext
@onready var tank_attack_speed_next: Label = $TankAttackSpeedNext

# ============================================================
# SELECTED TANK
# ============================================================

var selected_tank = null


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Hide the upgrade menu when the game starts
	visible = false

	# Connect the buttons
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)


# ============================================================
# OPEN UPGRADE MENU
# ============================================================

func open_upgrade_menu(tank) -> void:

	# Remember which tank was clicked
	selected_tank = tank

	# Change the picture to the selected tank
	tank_image.texture = tank.tank_upgrade_image

	# Show the upgrade menu
	visible = true

	# Update all the information
	update_upgrade_ui()


# ============================================================
# UPDATE UI
# ============================================================

func update_upgrade_ui() -> void:

	if selected_tank == null:
		return

	# Current level
	tank_level.text = str(selected_tank.upgrade_level)

	# Current damage
	tank_damage.text = str(selected_tank.damage)

	# Current attack speed
	tank_attack_speed.text = str(
		snapped(selected_tank.attack_speed, 0.1)
	)

	# Maximum level
	if selected_tank.upgrade_level >= selected_tank.max_upgrade_level:

		upgrade_button.text = ""
		upgrade_button.disabled = true

		# No next upgrade at MAX
		tank_damage_next.text = ""
		tank_attack_speed_next.text = ""

	else:

		upgrade_button.text = "   "
		upgrade_button.disabled = false

		# Calculate what the stats WILL be after the next upgrade
		var next_damage = selected_tank.damage + selected_tank.damage_increase

		var next_attack_speed = max(
			0.2,
			selected_tank.attack_speed - selected_tank.attack_speed_decrease
		)

		tank_damage_next.text = str(next_damage)

		tank_attack_speed_next.text = str(
			snapped(next_attack_speed, 0.1)
		)

	# Upgrade price
	upgrade_price.text = "$" + str(selected_tank.upgrade_price)


# ============================================================
# UPGRADE BUTTON
# ============================================================

func _on_upgrade_button_pressed() -> void:

	if selected_tank == null:
		return


	# Try to upgrade the tank
	var upgraded = selected_tank.upgrade()


	# Update the UI if the upgrade worked
	if upgraded:
		update_upgrade_ui()


# ============================================================
# CLOSE BUTTON
# ============================================================

func _on_close_button_pressed() -> void:

	# Forget the selected tank
	selected_tank = null

	# Hide the upgrade menu
	visible = false
