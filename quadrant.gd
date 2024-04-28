extends Node2D

# an independent unit of collision
# it represents a shape using collision polygon
# it can modify the shape with dedicated functions

var default_quadrant_polygon := Array()
var initial_poly := Array()

@onready var static_body = $StaticBody2D
@onready var Collision_polygon = preload("res://collision_polygon.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	init_quadrant()


# initiates the default collision polygon in the quadrant
func init_quadrant(quadrant_polygon = Array()):
	var polygon = quadrant_polygon if quadrant_polygon.size()>0 else default_quadrant_polygon
	var collision_polygon = _new_collision_polygon(polygon)
	static_body.add_child(collision_polygon)


# removes all collision polygons and initiates a new polygon
func reset_quadrant(polygon = Array()):
	for collision_polygon in static_body.get_children():
		collision_polygon.free()
	init_quadrant(polygon)


# carves the clipping_polygon away from the polygons in the quadrant
func carve(clipping_polygon):
	for collision_polygon in static_body.get_children():
		var clipped_polygons = Geometry2D.clip_polygons(collision_polygon.polygon, clipping_polygon)
		var n_clipped_polygons = len(clipped_polygons)
		match n_clipped_polygons:
			0:
				# clipping_polygon completely overlaps collision_polygon
				collision_polygon.free()
			1:
				# Clipping produces only one polygon
				collision_polygon.update_pol(clipped_polygons[0])
			2:
				# Check if you carved a hole (one of the two polygons
				# is clockwise). If so, split the polygon in two that
				# together make a "hollow" collision shape
				if _is_hole(clipped_polygons) && _split_polygon(clipping_polygon).all(
					func (p):
						Geometry2D.intersect_polygons(p, collision_polygon.polygon).size()>0
				):
					# split and add
					for p in _split_polygon(clipping_polygon):
						var new_colpol = _new_collision_polygon(
							Geometry2D.intersect_polygons(p, collision_polygon.polygon)[0] 
							)
						static_body.add_child(new_colpol)
					collision_polygon.free()
				# if its not a hole, behave as in match _
				else:
					collision_polygon.update_pol(clipped_polygons[0])
					for i in range(n_clipped_polygons-1):
						static_body.add_child(_new_collision_polygon(clipped_polygons[i+1]))
			
			# if more than two polygons, simply add all of
			# them to the quadrant
			_:
				collision_polygon.update_pol(clipped_polygons[0])
				for i in range(n_clipped_polygons-1):
					static_body.add_child(_new_collision_polygon(clipped_polygons[i+1]))


func add(adding_polygon):
	for collision_polygon in static_body.get_children():
		var added_polygons = Geometry2D.merge_polygons(collision_polygon.polygon, adding_polygon)
		var n_added_polygons = len(added_polygons)
		match n_added_polygons:
			0:
				# no merging to be done
				static_body.add_child(_new_collision_polygon(adding_polygon))
			1:
				# adding produces only one polygon
				collision_polygon.update_pol(added_polygons[0])
			2:
				# Check if you carved a hole (one of the two polygons
				# is clockwise). If so, split the polygon in two that
				# together make a "hollow" collision shape
				#if _is_hole(added_polygons):
					## split and add
					#for p in _split_polygon(adding_polygon):
						#var new_colpol = _new_collision_polygon(
							#Geometry2D.intersect_polygons(p, collision_polygon.polygon)[0]
							#)
						#static_body.add_child(new_colpol)
					#collision_polygon.free()
				## if its not a hole, behave as in match _
				#else:
					collision_polygon.update_pol(added_polygons[0])
					for i in range(n_added_polygons-1):
						static_body.add_child(_new_collision_polygon(added_polygons[i+1]))
			
			# if more than two polygons, simply add all of
			# them to the quadrant
			_:
				collision_polygon.update_pol(added_polygons[0])
				for i in range(n_added_polygons-1):
					static_body.add_child(_new_collision_polygon(added_polygons[i+1]))


"""
Utils
"""

# Returns a new Collision_polygon instance
# with assigned polygon
func _new_collision_polygon(polygon):
	var collision_polygon = Collision_polygon.instantiate()
	collision_polygon.polygon = polygon
	return collision_polygon


func _is_hole(clipped_polygons):
	return Geometry2D.is_polygon_clockwise(clipped_polygons[0]) or Geometry2D.is_polygon_clockwise(clipped_polygons[1])


# average 2D position in a list of positions
func _avg_position(array: Array):
	var sum = Vector2()
	for p in array:
		sum += p
	return sum/len(array)


# splits a polygon vertically in half
# returns the left and right resulting polygons
func _split_polygon(clip_polygon: Array):
	var avg_x = _avg_position(clip_polygon).x
	
	var left_subquadrant = default_quadrant_polygon.duplicate()
	left_subquadrant[1] = Vector2(avg_x, left_subquadrant[1].y)
	left_subquadrant[2] = Vector2(avg_x, left_subquadrant[2].y)
	
	var right_subquadrant = default_quadrant_polygon.duplicate()
	right_subquadrant[0] = Vector2(avg_x, right_subquadrant[0].y)
	right_subquadrant[3] = Vector2(avg_x, right_subquadrant[3].y)
	
	var pol1 = Geometry2D.clip_polygons(left_subquadrant, clip_polygon)[0]
	var pol2 = Geometry2D.clip_polygons(right_subquadrant, clip_polygon)[0]
	
	return [pol1, pol2]
