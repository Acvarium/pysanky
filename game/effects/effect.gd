extends Node2D

export var pitch_scale_range = 0.0
export var effect_delay = 0.0
export var max_rand_delay = 0.0

func _ready():
	randomize()
	if max_rand_delay > 0:
		effect_delay = randf() * max_rand_delay
	
	if pitch_scale_range > 0:
		var pitch_shift = randf() * pitch_scale_range - (pitch_scale_range / 2.0)
		$AudioStreamPlayer.pitch_scale += pitch_shift
	if effect_delay > 0:
		$OffsetTimer.wait_time = effect_delay
		$OffsetTimer.start()
	else:
		$AudioStreamPlayer.play()


func _on_killTimer_timeout():
	queue_free()


func _on_OffsetTimer_timeout():
	$AudioStreamPlayer.play()
