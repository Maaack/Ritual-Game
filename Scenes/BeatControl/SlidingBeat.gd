extends Node2D

func play() -> void:
	$AnimationPlayer.play("SlideAndFadeOut")

func set_speed(value : float) -> void:
	$AnimationPlayer.playback_speed = value
