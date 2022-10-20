extends Node

var beatbox_ritual_cooldown = false

enum { BEATBOX }

func _ready():
	pass # Replace with function body.

func start_cooldown(ritual_type):
	match ritual_type:
		BEATBOX:
			print("Beatbox Cooldown Started!")
