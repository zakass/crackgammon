extends Control

class_name RollScreen

const dieScene = preload("res://Die/Die.tscn")

var dice: Array = []
var rollAnimTimeCounter = 0
var team: PieceData.TEAM = PieceData.TEAM.RED

signal roll_done

# Called when the node enters the scene tree for the first time.
func _ready():
	pivot_offset = Vector2(self.size.x / 2, 0)
	var die1: Die = dieScene.instantiate().from_face(randi() % 6 + 1)
	$DieContainer1/Die.add_child(die1)
	var die2: Die = dieScene.instantiate().from_face(randi() % 6 + 1)
	$DieContainer2/Die.add_child(die2)
	dice.append(die1)
	dice.append(die2)
	$TeamContainer/Label.label_settings.font_color = Color(Color.RED)
	$TeamContainer/Label.text = "Red"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rollAnimTimeCounter > 0:
		if rollAnimTimeCounter % ((300 - rollAnimTimeCounter) / 10 + 1) == 0:
			for die: Die in dice:
				die.randomize_face()
		rollAnimTimeCounter -= 1
		if rollAnimTimeCounter == 1:
			roll_done.emit()

func _on_roll_button_pressed():
	rollAnimTimeCounter = 300
	$CenterContainer/RollButton.disabled = true

func switch_team(_team: PieceData.TEAM):
	team = _team
	var col: Color
	var text: String
	if team == PieceData.TEAM.RED:
		col = Color.RED
		text = "Red"
	else:
		col = Color.BLUE
		text = "Blue"
	$TeamContainer/Label.label_settings.font_color = col
	$TeamContainer/Label.text = text

func play_anim(anim_name: String):
	$AnimationPlayer.play(anim_name)
