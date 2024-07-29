extends Resource

class_name PieceData

enum TEAM {RED, BLUE}

@export var team: TEAM
@export var grabbable: bool
@export var coords: Vector2

var nextSpaces := {}
var space: int
var captured: bool

func _init(_team: TEAM, _space: int, _coords: Vector2, _grabbable: bool = false, _captured = false):
	team = _team
	space = _space
	grabbable = _grabbable
	captured = _captured
	coords = _coords
