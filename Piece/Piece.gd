extends Area2D

class_name Piece

@export var data: PieceData

## Smooth Movement Variables
const FRICTION_COEF = 0.06
const MAX_SPEED = 16

## Dragging Variables
var lifted = false
signal move_made(move, space)
var doubleFlag: int = 0


func with_data(data_: PieceData) -> Piece:
	data = data_
	return self

func set_destination(new_coords: Vector2) -> void:
	data.coords = new_coords

func _smooth_move() -> void:
	var directionVector: Vector2 = data.coords - self.position
	if directionVector.length() < 0.5:
		self.position = data.coords
		return
	self.position = self.position + (directionVector * FRICTION_COEF).limit_length(MAX_SPEED)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if not data:
		pass
	elif data.team == PieceData.TEAM.RED:
		$BlueSprite.visible = false
	else:
		$RedSprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.position != data.coords and not lifted:
		self._smooth_move()
	if doubleFlag != 0:
		doubleFlag -= 1
		

func _handle_move_made():
	if doubleFlag > 0:
		if len(data.nextSpaces) == 1:
			var space = data.nextSpaces.keys()[0]
			data.coords = space
			move_made.emit(data.nextSpaces[space], self)
			doubleFlag = 0
			return
		for space in data.nextSpaces.keys():
			if space.x == (16 * 18 - 9) * Board.boardScale:
				data.coords = space
				move_made.emit(data.nextSpaces[space], self)
				doubleFlag = 0
				return
	else:
		for space in data.nextSpaces.keys():
			if self.position.distance_to(space) < 40:
				data.coords = space
				move_made.emit(data.nextSpaces[space], self)
				return

func reset_props():
	self.data.grabbable = false
	self.data.nextSpaces.clear()

## Mouse/Dragging Functions
func _unhandled_input(event):
	if event is InputEventMouseButton and not event.pressed and lifted:
		lifted = false
		self._handle_move_made()
		doubleFlag = 45
	if lifted and event is InputEventMouseMotion:
		self.position += event.relative

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and data.grabbable:
		lifted = true
	if event is InputEventMouseButton and data.grabbable:
		# Show next moves
		pass
