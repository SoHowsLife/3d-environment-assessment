extends Area3D

@export var button_id : int = 1

# Emits signal that triggers objects that share id
# Player arg is unused in this func
func interact(player : Player):
	Signals.emit_signal("button_activated", button_id)
