extends Node2D

@onready var visualPolygon: Polygon2D = $Polygon2D
@onready var collision_area: Area2D = $Area2D
@onready var collision_area_shape: CollisionShape2D = $Area2D/CollisionShape2D



func update_polygon(polygon_points: Array):
	visualPolygon.polygon = polygon_points

func get_polygon():
	return visualPolygon.polygon
