extends Control

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Animations/fade_in")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_down():
	$AnimationPlayer.play("Fades/fade_out")
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Fades/fade_out":
		start_game.emit()
	pass # Replace with function body.
