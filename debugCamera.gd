extends Camera2D

var _previous_position: Vector2 = Vector2.ZERO
var _move_camera := false

# NOTE: buttons are hardcoded since this is only for debugging

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	# begin/end clicking
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT:
		get_viewport().set_input_as_handled()
		if event.is_pressed():
			_previous_position = event.position
			_move_camera = true
		else:
			_move_camera = false

	# dragging
	elif event is InputEventMouseMotion && _move_camera:
		get_viewport().set_input_as_handled()
		position += (_previous_position - event.position)
		_previous_position = event.position
	
	# Zoom
	elif event is InputEventMouseButton:
		var new_zoom := Vector2.ZERO
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_zoom = zoom.lerp(Vector2(0.5,0.5), 0.2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_zoom = zoom.lerp(Vector2(4,4), 0.2)
		
		if new_zoom != Vector2.ZERO:
			get_viewport().set_input_as_handled()
			zoom = new_zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
