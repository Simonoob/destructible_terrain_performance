extends CollisionPolygon2D

# smallest unit of collision
# it gets a polygon shape and assigns it to collision and visuals

@onready var visualPolygon = $VisualPolygon

func _ready():
	visualPolygon.polygon = polygon

func update_pol(polygon_points):
	polygon = polygon_points
	visualPolygon.polygon = polygon
