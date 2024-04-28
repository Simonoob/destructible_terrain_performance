extends Node2D


@export var quadrant_size: int = 100
@export var grid_size: Vector2 = Vector2(10,5)
@export var sprite: Sprite2D
@export var carving_area: Node2D

var quadrants_grid: Array = []
var Quadrant = preload("res://quadrant.tscn")

@onready var CarvingArea = preload("res://carving_area.tscn")
@onready var inverted_viewport: SubViewport = $SubViewport


func build_grid_from_image():
	# create a bitmap of true/false values based on the image alpha
	var bitmap := BitMap.new()
	var texture = sprite.texture.get_image()
	# draw at lower res for performance
	bitmap.create_from_image_alpha(texture)
	bitmap.resize(Vector2(sprite.texture.get_image().get_width(), sprite.texture.get_image().get_height()) * sprite.scale)
	
	# generate polygons for a rectangle section of the bitmap
	# in this case, the section is the full map
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, bitmap.get_size()), 5.0)

	grid_size = ceil(sprite.get_rect().size * sprite.transform.get_scale() /quadrant_size)

	init_grid()
	global_position = _get_matching_sprite_position()	
	#await RenderingServer.frame_post_draw
	
	for polygon in polygons:
		
		var carving_area = CarvingArea.instantiate()
		add_child(carving_area)
		carving_area.global_position = _get_matching_sprite_position()
		carving_area.collision_area_shape.shape.radius = max(sprite.get_rect().size.x, sprite.get_rect().size.y)
		#await RenderingServer.frame_post_draw
		
		for row in quadrants_grid:
			for quadrant in row:
				
				var intersections = Geometry2D.intersect_polygons(quadrant.initial_poly, polygon)
				for intersecting_poly in intersections:
					carving_area.update_polygon(intersecting_poly)
					quadrant.add(carving_area.visualPolygon.polygon)
		carving_area.collision_area_shape.shape.radius = 40
		remove_child(carving_area)
		

func init_grid(polygon_shape = Array()):
	for i in range(grid_size.x):
		quadrants_grid.push_back([])
		for j in range(grid_size.y):
			var quadrant = Quadrant.instantiate()
			#quadrant.default_quadrant_polygon = [
				#Vector2(quadrant_size
			#*i,quadrant_size
			#*j),
				#Vector2(quadrant_size
			#*(i+1),quadrant_size
			#*j),
				#Vector2(quadrant_size
			#*(i+1),quadrant_size
			#*(j+1)),
				#Vector2(quadrant_size
			#*i,quadrant_size
			#*(j+1))
			#]
			
			quadrant.initial_poly = [
				Vector2(quadrant_size
			*i,quadrant_size
			*j),
				Vector2(quadrant_size
			*(i+1),quadrant_size
			*j),
				Vector2(quadrant_size
			*(i+1),quadrant_size
			*(j+1)),
				Vector2(quadrant_size
			*i,quadrant_size
			*(j+1))
			]
			quadrants_grid[-1].push_back(quadrant)
			add_child(quadrant)
			quadrant.reset_quadrant(polygon_shape)


func carve(carving_area):
	var translated_polygon = Transform2D(0, carving_area.global_position - global_position) * (carving_area.get_polygon())
	var affected_quadrants = _get_affected_quadrants(carving_area.collision_area)
	for quadrant in affected_quadrants:
		quadrant.carve(translated_polygon)
	%circleDraw.update(carving_area.global_position, carving_area.collision_area_shape.shape.radius)




"""
Utils
"""

func _get_matching_sprite_position():
	var centered = sprite.centered
	
	if centered:
		var sprite_size = sprite.get_rect().size * sprite.transform.get_scale()
		return Vector2(sprite.global_position - sprite_size / 2 )
	else:
		return sprite.global_position



# returns an array of Quadrants that are affected by the carving
func _get_affected_quadrants(collision_area):
	var affected_quadrants = {} # use a dictionary as a Set()
	var overlapping_bodies = collision_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.get_parent().has_method('carve'):
			affected_quadrants[body.get_parent()] = true
	return affected_quadrants.keys()
