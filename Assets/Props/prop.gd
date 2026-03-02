class_name Prop
extends RigidBody3D

# The amount of force applied to held objects
const HOLD_FORCE = 200
# Max force of a held object
const MAX_FORCE = 400

# Determine if the player can hold this object
@export var is_holdable : bool = false
var target : Marker3D
var is_held : bool = false

func _physics_process(delta: float) -> void:
	# If player is holding this object, update the position of the object
	if is_held:
		var target_position = target.global_position
		var speed = clamp(HOLD_FORCE * global_position.distance_to(target_position), 0.0, MAX_FORCE)
		var direction = global_position.direction_to(target_position)
		linear_velocity = Vector3.ZERO
		apply_central_force(speed * direction)

# Player grabs this object
# Return if the grab is successful
func grab(player_target : Marker3D) -> bool:
	if is_holdable:
		is_held = true
		gravity_scale = 0
		target = player_target
		return true
	return false

# Player releases this object
func release() -> void:
	if is_holdable:
		is_held = false
		#linear_velocity = Vector3.ZERO
		gravity_scale = 1
