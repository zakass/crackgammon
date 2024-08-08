extends Node2D

class_name Board

const pieceScene: PackedScene = preload("res://Piece/Piece.tscn")
const boardScale: int = 4

signal turn_finished

@export var pieces: Array = []
@export var redCaptured: Array = []
@export var blueCaptured: Array = []
@export var redWin: Array = []
@export var blueWin: Array = []
var diceArray: Array = []
var numMoves: int = 0

#const initBoard = [[PieceData.TEAM.RED, PieceData.TEAM.RED],
			   #[],
			   #[],
			   #[],
			   #[],
			   #[PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   #[],
			   #[PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   #[],
			   #[],
			   #[],
			   #[PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   #[PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   #[],
			   #[],
			   #[],
			   #[PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   #[],
			   #[PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   #[],
			   #[],
			   #[],
			   #[],
			   #[PieceData.TEAM.BLUE, PieceData.TEAM.BLUE]]

# TEST BOARD
const initBoard = [
			   [],
			   [],
			   [PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   [PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   [PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE, PieceData.TEAM.BLUE],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [],
			   [PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   [PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   [PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED, PieceData.TEAM.RED],
			   [],
			   []
			]

func restart_game():
	for space in pieces:
		for piece in space:
			piece.queue_free()
	for list in [redCaptured, blueCaptured, redWin, blueWin]:
		for piece in list:
			piece.queue_free()
	redWin.clear()
	blueWin.clear()
	redCaptured.clear()
	blueCaptured.clear()
	pieces.clear()
	for i in len(initBoard):
		pieces.append([])
		for j in len(initBoard[i]):
			var piece: Piece
			# i is space on board (0 < i < len), j is pos (0 < j)
			var data: PieceData = PieceData.new(initBoard[i][j], i, _board_position(i, j))
			piece = pieceScene.instantiate().with_data(data)
			piece.move_made.connect(_calculate_move)
			piece.z_index = 1
			pieces[i].append(piece)
			add_child(piece)
	

func _board_position(space: int, height: int, data: PieceData = null) -> Vector2:
	if data and data.captured:
		if data.team == PieceData.TEAM.RED:
			return Vector2(8 * 18 - 9, 18 * (height + 6.5)) * boardScale
		else:
			return Vector2(8 * 18 - 9, 18 * (5.5 - height)) * boardScale
	if space <= -1:
		# Red Win
		return Vector2(16 * 18 - 9, 9 * (12 - height)) * boardScale
	elif space >= 24:
		# Blue Win
		return Vector2(16 * 18 - 9, 9 * (height + 14)) * boardScale
	elif space < 6:
		return Vector2((14 - space) * 18 - 9, 18 * (height + 2)) * boardScale
	elif space < 12:
		return Vector2((13 - space) * 18 - 9, 18 * (height + 2)) * boardScale
	elif space < 18:
		return Vector2((space - 10) * 18 - 9, 18 * (11 - height)) * boardScale
	elif space < 24:
		return Vector2((space - 9) * 18 - 9, 18 * (11 - height)) * boardScale
	else:
		push_error("This literally shouldn't happen...")
		return Vector2()
		
# Called when the node enters the scene tree for the first time.
func _ready():
	restart_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _get_moves(data: PieceData, earliest: int) -> Array:
	return _get_moves_helper(data, 0, [], earliest).slice(1)

func _get_moves_helper(data: PieceData, index: int, moves: Array, earliest: int) -> Array:
	if index >= len(diceArray):
		return [moves]
	if Util.sum(moves) >= 24 or Util.sum(moves) < 0:
		return [moves]
	var l = _get_moves_helper(data, index + 1, moves.duplicate(), earliest)
	moves.append(diceArray[index])
	var sum := Util.sum(moves)
	var nextSpace = data.space + _get_dir(data.team) * sum
	if nextSpace >= 0 and nextSpace < len(pieces):
		if len(pieces[nextSpace]) <= 1 or pieces[nextSpace][-1].data.team == data.team:
			l.append_array(_get_moves_helper(data, index + 1, moves, earliest))
	elif earliest != -1:
		var currSpace: int = nextSpace - _get_dir(data.team) * diceArray[index]
		if nextSpace == -1 or nextSpace == 24 or currSpace == earliest:
			if currSpace == earliest and len(pieces[currSpace]) == 1:
				## set earliest to next
				earliest += _get_dir(data.team)
				while earliest != nextSpace and earliest >= 0 and earliest < 24:
					if len(pieces[earliest]) == 0 or pieces[earliest][-1].data.team != data.team:
						earliest += _get_dir(data.team)
					else:
						break
			l.append_array(_get_moves_helper(data, index + 1, moves, earliest))
	return l

func _get_dir(team: PieceData.TEAM) -> int:
	return int(team == PieceData.TEAM.RED) * 2 - 1

func _reset_captured_positions() -> void:
	for index: int in len(redCaptured):
		redCaptured[index].set_destination(_board_position(redCaptured[index].data.space, index, redCaptured[index].data))
	for index: int in len(blueCaptured):
		blueCaptured[index].set_destination(_board_position(blueCaptured[index].data.space, index, blueCaptured[index].data))

func _calculate_move(moves: Array, piece: Piece) -> void:
	for move: int in moves:
		diceArray.erase(move)
		if piece in redCaptured:
			redCaptured.erase(piece)
			piece.data.captured = false
		elif piece in blueCaptured:
			blueCaptured.erase(piece)
			piece.data.captured = false
		else:
			pieces[piece.data.space].pop_back()
		var newSpace: int = piece.data.space + move * _get_dir(piece.data.team)
		piece.data.space = newSpace
		if newSpace < 0:
			blueWin.append(piece)
		elif newSpace >= 24:
			redWin.append(piece)
		else:
			if len(pieces[newSpace]) != 0 and pieces[newSpace][-1].data.team != piece.data.team:
				# Capture Enemy piece
				var enemyPiece: Piece = pieces[newSpace].pop_back()
				enemyPiece.data.space = 25 * int(enemyPiece.data.team == PieceData.TEAM.BLUE) - 1
				enemyPiece.data.captured = true
				if enemyPiece.data.team == PieceData.TEAM.RED:
					enemyPiece.set_destination(_board_position(-1, len(redCaptured), enemyPiece.data))
					redCaptured.append(enemyPiece)
				else:
					enemyPiece.set_destination(_board_position(24, len(blueCaptured), enemyPiece.data))
					blueCaptured.append(enemyPiece)
			pieces[newSpace].append(piece)
	numMoves -= len(moves)
	_reset_piece_moves()
	_reset_captured_positions()
	if numMoves == 0:
		print(len(redWin) == 15 or len(blueWin) == 15)
		turn_finished.emit(len(redWin) == 15 or len(blueWin) == 15)
	else:
		_set_piece_moves(piece.data.team)

func _reset_piece_moves() -> void:
	for space in pieces:
		for piece in space:
			piece.reset_props()

func _set_piece_moves(team: PieceData.TEAM) -> void:
	var array: Array
	var anyMove: bool = false
	if team == PieceData.TEAM.RED and len(redCaptured) != 0:
		array = redCaptured
	elif team == PieceData.TEAM.RED and _check_win_condition(team):
		var earliest: int = -1
		for space in range(18, 24):
			if len(pieces[space]) != 0 and pieces[space][-1].data.team == team:
				if earliest == -1:
					#earliest = 24 - space
					earliest = space
				var piece: Piece = pieces[space][-1]
				anyMove = _apply_moves(piece, earliest) or anyMove
	elif team == PieceData.TEAM.BLUE and len(blueCaptured) != 0:
		array = blueCaptured
	elif team == PieceData.TEAM.BLUE and _check_win_condition(team):
		var earliest := -1
		var arr: Array = range(0, 6)
		arr.reverse()
		for space in arr:
			if len(pieces[space]) != 0 and pieces[space][-1].data.team == team:
				if earliest == -1:
					earliest = space
				var piece: Piece = pieces[space][-1]
				anyMove = _apply_moves(piece, earliest) or anyMove
	else:
		for space in len(pieces):
			if len(pieces[space]) != 0 and pieces[space][-1].data.team == team:
				var piece: Piece = pieces[space][-1]
				anyMove = _apply_moves(piece) or anyMove
		return
	for piece: Piece in array:
		anyMove = _apply_moves(piece) or anyMove
	if not anyMove:
		turn_finished.emit(len(redWin) == 15 or len(blueWin) == 15)
	
func _apply_moves(piece: Piece, earliest: int = -1) -> bool:
	var dir := _get_dir(piece.data.team)
	var anyMove: bool = false
	for move in _get_moves(piece.data, earliest):
		anyMove = true
		piece.data.grabbable = true
		var nextSpace = piece.data.space + dir * Util.sum(move)
		if nextSpace < 0:
			piece.data.nextSpaces[_board_position(nextSpace, len(blueWin))] = move
		elif nextSpace >= 24:
			piece.data.nextSpaces[_board_position(nextSpace, len(redWin))] = move
		elif len(pieces[nextSpace]) != 0 and pieces[nextSpace][-1].data.team != piece.data.team:
			piece.data.nextSpaces[_board_position(nextSpace, 0)] = move
		else:
			piece.data.nextSpaces[_board_position(nextSpace, len(pieces[nextSpace]))] = move
	print(piece.data.space, ": ", piece.data.nextSpaces)
	return anyMove

func _check_win_condition(team: PieceData.TEAM) -> bool:
	var count: int = 0
	if team == PieceData.TEAM.RED:
		for index in range(18, 24):
			if len(pieces[index]) > 0 and pieces[index][-1].data.team == PieceData.TEAM.RED:
				count += len(pieces[index])
		return 15 == count + len(redWin)
	else:
		for index in range(0, 6):
			if len(pieces[index]) > 0 and pieces[index][-1].data.team == PieceData.TEAM.BLUE:
				count += len(pieces[index])
		return 15 == count + len(blueWin)

func dice_rolled(state: Main.STATE, dice: Array) -> void:
	_set_dice_array(dice)
	var color: PieceData.TEAM = PieceData.TEAM.RED
	if state == Main.STATE.BLUE_PLAY:
		color = PieceData.TEAM.BLUE
	_set_piece_moves(color)

func _set_dice_array(dice: Array) -> void:
	diceArray.clear()
	for die: Die in dice:
		diceArray.append(die.face)
	if dice[0].face == dice[1].face:
		for die: Die in dice:
			diceArray.append(die.face)
	numMoves = len(diceArray)
