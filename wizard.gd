extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var reticule_anchor: Node2D = %reticuleAnchor
@onready var reticule: Sprite2D = %reticule


var _attack_power: float = 0
var _attack_scale: float = 3
var _attack_clicked: bool = false

@export var weapon_projectile: PackedScene
@export var weapon_speed: float = 2

# once _attack_power reaches this value we shoot automatically (max power per shot)
@onready var _auto_attack_power: float = reticule_anchor.get_child_count() / _attack_scale


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func rotate_reticule():
	reticule_anchor.rotate(reticule_anchor.get_angle_to(get_global_mouse_position()))

func redraw_power():
	var sprites_to_show: int = int(_attack_power * _attack_scale)
	for i in range(reticule_anchor.get_child_count() -1): # don't loop over the reticulate
			if i < sprites_to_show:
				reticule_anchor.get_child(i).visible = true
			else: 
				reticule_anchor.get_child(i).visible = false


func handle_shoot_input(event):
	# click and drag
	if event is InputEventMouseButton && event.button_index  == MOUSE_BUTTON_LEFT:
		if event.is_pressed(): # drag start
			_attack_clicked = true
		else: #drag end
			if _attack_clicked: # this will be false if we auto attacked
				shoot()
			_attack_clicked = false

func charge_attack(delta):
	if _attack_clicked:
		_attack_power += delta
	if _attack_power >= _auto_attack_power: # auto shoot if needed
		shoot()
	
	
func shoot():
	# spawn projectile
	var new_projectile := weapon_projectile.instantiate() as RigidBody2D
	new_projectile.global_position = lerp(global_position, reticule.global_position, 0.2)
	#new_projectile.global_position = global_position
	new_projectile.linear_velocity = (reticule.global_position - global_position) * weapon_speed * (_attack_power * _attack_scale)
	get_parent().add_child(new_projectile)
	
	# reset attack state
	_attack_power = 0
	_attack_clicked = false

func _process(delta):
	rotate_reticule()
	redraw_power()

func _physics_process(delta):
	move(delta)
	charge_attack(delta)
	
	

func _unhandled_input(event):
	handle_shoot_input(event)

