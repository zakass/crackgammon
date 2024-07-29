extends Node

class_name Main

const rollScreenScene: PackedScene = preload("res://Die/RollScreen.tscn")

enum STATE {START, RED_ROLL, RED_PLAY, BLUE_ROLL, BLUE_PLAY}
var state := STATE.START

func _ready():
	$MainControl/ControlContainer/TextureRect/AnimationPlayer.play("Fades/fade_in")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_state_change(win: bool = false):
	# STATE STUFF
	match state:
		STATE.START:
			print('start -> red roll')
			state = STATE.RED_ROLL
			$MainControl/ControlContainer/RollScreen.play_anim("Fades/fade_in")
		STATE.RED_ROLL:
			$MainControl/ControlContainer/TextureRect/AnimationPlayer.play("Fades/fade_out")
			$MainControl/ControlContainer/RollScreen.play_anim("minimize")
			print('red roll -> red play')
			state = STATE.RED_PLAY
			$Board.dice_rolled(state, $MainControl/ControlContainer/RollScreen.dice)
		STATE.BLUE_ROLL:
			$MainControl/ControlContainer/TextureRect/AnimationPlayer.play("Fades/fade_out")
			$MainControl/ControlContainer/RollScreen.play_anim("minimize")
			print('blue roll -> blue play')
			state = STATE.BLUE_PLAY
			$Board.dice_rolled(state, $MainControl/ControlContainer/RollScreen.dice)
		STATE.RED_PLAY:
			if win:
				print("Red Win!")
				return
			$MainControl/ControlContainer/TextureRect/AnimationPlayer.play("Fades/fade_in")
			$MainControl/ControlContainer/RollScreen.play_anim("expand")
			print('red play -> blue roll')
			state = STATE.BLUE_ROLL
		STATE.BLUE_PLAY:
			if win:
				print("Blue Win!")
				return
			$MainControl/ControlContainer/TextureRect/AnimationPlayer.play("Fades/fade_in")
			$MainControl/ControlContainer/RollScreen.play_anim("expand")
			print('blue play -> red roll')
			state = STATE.RED_ROLL
