extends Node

class_name Util

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func sum(array: Array) -> int:
	var sum = 0
	for element in array:
		sum += element
	return sum
