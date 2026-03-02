class_name Player 
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Multiplier for force applied when pushing objects
const PUSH_FORCE = 0.2

@export_range(0.0, 1.0, 0.1) var mouse_sensitivity = 0.3

# References to child objects
@onready var head = $Head
@onready var interact_ray : RayCast3D = $Head/InteractRayCast
@onready var grab_ray : RayCast3D = $Head/GrabRayCast
@onready var hold_position : Marker3D = $Head/HoldMarker

# Reference to object player is currently holding
var held_object : Prop

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# Handle Camera Rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	# Attempt to interact with object player is looking at
	elif event.is_action_pressed("interact"):
		interact_object()
	# Attempt to grab object player is looking at
	elif event.is_action_pressed("grab"):
		grab_object()
	# Release held object
	elif event.is_action_released("grab"):
		release_object()
	
		
func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Handle pushing physics props
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var body : RigidBody3D = c.get_collider()
			var speed = clamp(velocity.length(), 1.0, 3.0)
			var push_direction = -c.get_normal();
			body.apply_impulse((push_direction) * PUSH_FORCE * speed, (c.get_position() - body.get_global_position()))
		

# Activate the object the player is looking at if it is interactable
func interact_object() -> void:
	if interact_ray.is_colliding():
		var object = interact_ray.get_collider()
		if object.has_method("interact"):
			object.interact(self)
			

# Grab the object the player is looking at if able to
func grab_object() -> void:
	if grab_ray.is_colliding():
		if grab_ray.get_collider() is Prop:
			var object : Prop = grab_ray.get_collider()
			if object.grab(hold_position):
				held_object = object
				add_collision_exception_with(held_object)
			
			

# Release any held objects
func release_object() -> void:
	if held_object:
		held_object.release()
		remove_collision_exception_with(held_object)
		held_object = null
