extends Node2D
@export var min_movement_update: int = 5
@export var circle_radius: float = 40


var old_mouse_pos: Vector2 = Vector2()
var mouse_pos: Vector2 = Vector2()

@onready var carving_area:= $carvingArea
@onready var quadrantsManager = %quadrantsManager
var Quadrant = preload("res://quadrant.tscn")


func _ready():
	_make_mouse_circle()
	quadrantsManager.position = %Sprite2D.position
	quadrantsManager.build_grid_from_image()

#
#func _process(_delta):
	#pass
	#if Input.is_action_pressed("click_left"):
		#if old_mouse_pos.distance_to(mouse_pos) > min_movement_update:
			#quadrantsManager.carve(carving_area)
			#old_mouse_pos = mouse_pos
			#%circleDraw.update(carving_area.global_position, 50)
#

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = get_global_mouse_position()
		carving_area.position = mouse_pos
		queue_redraw()


func _make_mouse_circle():
	var nb_points = 15
	var pol = []
	for i in range(nb_points):
		var angle = lerp(-PI, PI, float(i)/nb_points)
		pol.push_back(mouse_pos + Vector2(cos(angle), sin(angle)) * circle_radius)
	carving_area.update_polygon(pol)
