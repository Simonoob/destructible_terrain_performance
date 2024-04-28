extends Polygon2D

const SPEED = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_poly_left"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("move_poly_right"):
		position.x += SPEED * delta
