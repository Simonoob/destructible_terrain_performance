extends SubViewport

@onready var sprite:Sprite2D = %Sprite2D 

# Called when the node enters the scene tree for the first time.
func _ready():
	set_size(sprite.get_rect().size)
	#set_global_canvas_transform(Transform2D(0, sprite.global_position/2))
