extends Node2D


func play() -> void:
	$AnimationPlayer.play("DropAndFadeOut")

func set_speed(value : float) -> void:
	$AnimationPlayer.playback_speed = value
