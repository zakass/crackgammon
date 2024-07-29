extends Node2D

class_name Die

var face: int

func from_face(face_: int) -> Die:
	face = face_
	return self

func from_random_face() -> Die:
	face = randi() % 6 + 1 # Change for powerups, etc. Max/Min rolling nums, special dice
	return self

func change_face(face_: int) -> void:
	assert(face < 7 and face > 0, "Die face is not valid.")
	$Sprite2D.region_rect = Rect2(36, (face - 1) * 18, 18, 18)

func randomize_face() -> void:
	face = randi() % 6 + 1
	$Sprite2D.region_rect = Rect2(36, (face - 1) * 18, 18, 18)

func get_face() -> int:
	return face

# Called when the node enters the scene tree for the first time.
func _ready():
	change_face(face)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
