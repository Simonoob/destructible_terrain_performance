extends RigidBody2D

@export var explosion_scene : PackedScene

@onready var visualPolygon: Polygon2D = $destruction_Polygon2D
@onready var collision_area: Area2D = $collision_area
@onready var collision_area_shape: CollisionShape2D = $collision_area/CollisionShape2D

var radius = 30

func _ready():
	update_polygon(_make_circle())
	var new_collision_shape = CircleShape2D.new()
	collision_area_shape.shape.radius = radius


func update_polygon(polygon_points: Array):
	visualPolygon.polygon = polygon_points

func get_polygon():
	return visualPolygon.polygon



func _on_body_entered(body):
	if body.get_parent().has_method('carve'):
		# display explosion animation
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
		var quadrants_manager = body.get_parent().get_parent()
		quadrants_manager.carve(self)
	
		queue_free()


func _make_circle():
	var pos = position - global_position

	var nb_points = 16
	var points_arc = PackedVector2Array()
	points_arc.push_back(pos)

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(pos + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	return points_arc
