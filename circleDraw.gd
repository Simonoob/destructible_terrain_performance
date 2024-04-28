extends Sprite2D

var _radius = 50

@onready var _world_size = %Sprite2D.get_rect().size

func update(pos: Vector2, radius: float):
	visible = true
	
	global_position = _world_to_viewport(pos)
	
	_radius = radius
	scale = Vector2(
		radius*2/texture.get_width(), radius*2/texture.get_width()
	) * 0.9


func _world_to_viewport(point : Vector2) -> Vector2:
	var dynamic_texture_size = %damageMap.get_size()
	var parent_offset = Vector2(%Sprite2D.position.x  - _world_size.x/2, %Sprite2D.position.y  - _world_size.y/2) 
	return Vector2(
		((point.x - parent_offset.x ) / _world_size.x) * dynamic_texture_size.x + get_viewport_rect().position.x,
		((point.y - parent_offset.y ) / _world_size.y) * dynamic_texture_size.y + get_viewport_rect().position.y
	)
