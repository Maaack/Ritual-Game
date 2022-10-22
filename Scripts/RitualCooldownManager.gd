extends Node

var bouncer_cooldown = false
var guard_cooldown = false

enum { BOUNCER, GUARD }

func start_cooldown(ritual_type):
	match ritual_type:
		BOUNCER:
			bouncer_cooldown = true;
		GUARD:
			guard_cooldown = true;
