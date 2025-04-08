extends Node2D
var color_index = -1
var matched = false


func move(target, ease_mode = Tween.EASE_IN_OUT):
	$Tween.interpolate_property(self, "position", position, target, 0.3, \
		Tween.TRANS_ELASTIC, ease_mode)
	$Tween.start()

func highlite(to_highlite = true):
	$Halo.visible = to_highlite

func _ready():
	randomize()
	scale = Vector2(0.0, 0.0)
	$ScaleEffectTimer.start()
	
	
func scale_effect():
	var effect_time = 0.3 + randf() 
	$Tween.interpolate_property(self, "scale", scale, Vector2(1, 1), effect_time, \
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()


func _on_ScaleEffectTimer_timeout():
	scale_effect()
