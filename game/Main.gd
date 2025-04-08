extends Node2D


func _ready():
	update_score(Global.score)
	if not Global.show_help_screen:
		hide_help_screen()
	

func update_score(score):
	$CanvasLayer/Score.text = str(score)


func set_background_texture(texture):
	$CanvasLayer/TextureRect.texture = texture


func show_number_of_good_moves(value):
	$CanvasLayer/GoodMoves.text = str(value)


func hide_help_screen(animated = false):
	if animated:
		$HelpCanvas/AnimationPlayer.play("fade_out")
	else:
		$HelpCanvas/HelpScreen.visible = false
	Global.show_help_screen = false


func _on_HelpScreenButton_pressed():
	hide_help_screen(true)
