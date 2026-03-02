extends AnimatableBody3D

# Signal Id that triggers elevator
@export var id : int = 1

# The end points of the elevator
@export var pos0 : Marker3D
@export var pos1 : Marker3D

@export var elevator_speed : float = 0.05

# Distance Threshold for Elevator to be considered to have arrived
@export_range(0.01, 50, 0.1) var distance_threshold = 0.1

# Possible Elevator States
enum ElevatorStates{
	Moving, # Currently Moving
	Ready, # Ready to move
}
var current_state : ElevatorStates = ElevatorStates.Ready
# Which endpoint is the Elevator currently headed to
var heading_to : int = 1

var target_position : Vector3

func _ready() -> void:
	if pos0 == null || pos1 == null:
		# pos1 or pos2 were not set in the editor
		print_debug("Missing Elevator Position")
		queue_free()
	else:
		global_position = pos0.global_position
		target_position = pos1.global_position
		Signals.connect("button_activated", activate)
		

func _physics_process(delta: float) -> void:
	if current_state == ElevatorStates.Moving:
		# Check if the elevator is close enough to the endpoint
		if global_position.distance_to(target_position) < distance_threshold:
			current_state = ElevatorStates.Ready
			heading_to = (heading_to + 1) % 2
			if heading_to == 0:
				target_position = pos0.global_position
			else:
				target_position = pos1.global_position
		else:
			global_position = lerp(global_position, target_position, elevator_speed)

func activate(signal_id : int):
	if signal_id == id && current_state == ElevatorStates.Ready:
		current_state = ElevatorStates.Moving
