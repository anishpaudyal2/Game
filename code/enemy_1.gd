extends PathFollow2D

@export var speed: float = 100.0
@export var health: int = 100
@export var money_reward: int = 7

@onready var health_bar: ProgressBar = $HealthBar

@onready var melon = get_node_or_null("Melon")
@onready var apple = get_node_or_null("Apple")
@onready var coconut = get_node_or_null("coconut Visual")
@onready var mango = get_node_or_null("Mango")
@onready var green_apple = get_node_or_null("GreenApple")


func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health


func _process(delta: float) -> void:
	progress += delta * speed

	# Roll the melon
	if melon != null:
		melon.rotation += delta * speed * 0.05

	# Roll the apple
	if apple != null:
		apple.rotation += delta * speed * 0.05

	# Roll the coconut
	if coconut != null:
		coconut.rotation += delta * speed * 0.05

	# Roll the mango
	if mango != null:
		mango.rotation += delta * speed * 0.05

	# Roll the green apple
	if green_apple != null:
		green_apple.rotation += delta * speed * 0.05

	# Enemy reached the end of the path
	if progress_ratio >= 1.0:
		GameManager.take_damage(3)
		queue_free()


func take_damage(damage: int) -> void:
	health -= damage
	health_bar.value = health

	if health <= 0:
		GameManager.add_money(money_reward)
		print("+$", money_reward)
		queue_free()
