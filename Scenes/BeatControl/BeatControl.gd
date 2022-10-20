extends Node2D

const GREAT_RANGE : float = 0.025
const GOOD_RANGE : float = 0.075
const MEH_RANGE : float = 0.15

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{GUARD,PLAYER}

export(Array, KEYS) var sequence : Array = []
export(int) var modulo_beats : int = 1

var current_key_in_sequence : int = -1
var current_boxer : int = BOXERS.GUARD
var score : int = 0

func play_next_in_sequence():
	current_key_in_sequence += 1
	if current_key_in_sequence >= sequence.size():
		current_key_in_sequence = 0
	var next_key = sequence[current_key_in_sequence]	
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

func _on_AudioStreamConductor_beat(total, _in_measure):
	if total % modulo_beats == 0:
		play_next_in_sequence()

func play():
	$AudioStreamConductor.play()

func _ready():
	play()

func score_beat():
	var delta = $AudioStreamConductor.get_time_to_closest_beat()
	$TimeToBeatLabel.text = "%0.5f" % delta
	if delta < GREAT_RANGE:
		score += 100
		$BigFeedback.text = "Great"
	elif delta < GOOD_RANGE:
		score += 25
		$BigFeedback.text = "Good"
	elif delta < MEH_RANGE:
		score += 10
		$BigFeedback.text = "Meh"
	else:
		$BigFeedback.text = "What?"
	$ScoreLabel.text = "%d" % score

func _refresh_input():
	$BigFeedback.text = ""
	set_process_unhandled_input(true)

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
		score_beat()
		set_process_unhandled_input(false)
		yield(get_tree().create_timer(0.4), "timeout")
		_refresh_input()

func _on_AudioStreamConductor_beat_lead_up(_total):
	$NoteTrack.drop_note()
