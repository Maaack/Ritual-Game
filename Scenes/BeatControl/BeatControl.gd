extends Node2D

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{GUARD,PLAYER}

export(int) var modulo_beats = 2
export(Array, KEYS) var sequence : Array = []

var current_key_in_sequence = -1
var current_boxer = BOXERS.GUARD

func play_next_in_sequence():
	current_key_in_sequence += 1
	if current_key_in_sequence >= sequence.size():
		current_key_in_sequence = 0
	var next_key = sequence[current_key_in_sequence]
	var container_node : Node2D
	match(next_key):
		KEYS.UP:
			$GuardBeats/UpArrow.pulse()
		KEYS.DOWN:
			$GuardBeats/DownArrow.pulse()
		KEYS.LEFT:
			$GuardBeats/LeftArrow.pulse()
		KEYS.RIGHT:
			$GuardBeats/RightArrow.pulse()
		KEYS.WAIT:
			pass

func _on_AudioStreamConductor_beat(total, in_measure):
	if total % modulo_beats == 0:
		play_next_in_sequence()

func play():
	$AudioStreamConductor.play()

func _ready():
	play()

func _unhandled_input(event):
	var arrow_node : Node2D
	if event.is_action_pressed("move_forward"):
		arrow_node = $PlayerBeats/UpArrow
	elif event.is_action_pressed("move_backward"):
		arrow_node = $PlayerBeats/DownArrow
	elif event.is_action_pressed("move_left"):
		arrow_node = $PlayerBeats/LeftArrow
	elif event.is_action_pressed("move_right"):
		arrow_node = $PlayerBeats/RightArrow
	if arrow_node:
		arrow_node.pulse()
		set_process_unhandled_input(false)
		yield(get_tree().create_timer(0.4), "timeout")
		set_process_unhandled_input(true)
