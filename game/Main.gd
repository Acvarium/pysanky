extends Node2D


func _ready():
	update_score(Global.score)
	

func update_score(score):
	$CanvasLayer/Score.text = str(score)


func set_background_texture(texture):
	$CanvasLayer/TextureRect.texture = texture


func show_number_of_good_moves(value):
	$CanvasLayer/GoodMoves.text = str(value)
