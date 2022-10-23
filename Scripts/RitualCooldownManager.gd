extends Node

var bouncer_cooldown = false
var guard_cooldown = false
var guard2_cooldown = false

func start_cooldown(ritual_name : String):
	match ritual_name:
		"Beatboxing Bouncer":
			print("bouncer cooldown")
			bouncer_cooldown = true;
		"Beatboxing Guard":
			print("guard cooldown")
			guard_cooldown = true;
		"Beatboxing Guard 2":
			print("guard 2 cooldown")
			guard2_cooldown = true;
