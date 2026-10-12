extends Polygon2D

@export var circle_color: Color = Color(0.05, 0.45, 0.05, 0.35)
@export var outline_color: Color = Color(0, 0, 0, 1)

func _ready() -> void:
	var collision_shape = get_parent().get_node("Area2D/CollisionShape2D2")

	if collision_shape.shape is CircleShape2D:
		var radius = collision_shape.shape.radius
		make_circle(radius)


func make_circle(radius: float) -> void:
	var points = PackedVector2Array()
	var segments = 64

	for i in range(segments):
		var angle = TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	polygon = points
	color = circle_color
