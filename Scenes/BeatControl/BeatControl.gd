extends Node2D

signal stage_completed(stage)
signal challenge_completed

const GREAT_RANGE : float = 0.025
const GOOD_RANGE : float = 0.075
const MEH_RANGE : float = 0.15
const INPUT_HOLD : float = 0.4
const GUARD_PAUSE_MEASURES : int = 2

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{GUARD,PLAYER}

export(Array, Resource) var stages : Array = []
export(int) var modulo_beats : int = 1

var current_stage : int = 0
var current_key_in_guard_sequence : int = 0
var current_boxer : int = BOXERS.GUARD
var score : int = 0
var guard_waiting : int = 0
var played_sequence : Array = []

func _complete_stage() -> void:
	emit_signal("stage_completed", current_stage)
	current_stage += 1
	if current_stage >= stages.size():
		emit_signal("challenge_completed")
		current_stage = 0

func _get_current_stage_data():
	return stages[current_stage]

func _reset_guard():
	guard_waiting = GUARD_PAUSE_MEASURES
	current_key_in_guard_sequence = 0

func is_guard_waiting():
	return guard_waiting > 0

func play_next_in_sequence():
	if is_guard_waiting():
		return
	var stage = _get_current_stage_data()
	if not stage is StageData:
		return
	var sequence : Array = stage.guard_sequence
	var next_key = sequence[current_key_in_guard_sequence]
	current_key_in_guard_sequence += 1
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
	if current_key_in_guard_sequence >= sequence.size():
		_reset_guard()

func _record_wait_if_no_input():
	if not is_processing_unhandled_input():
		return
	yield(get_tree().create_timer(INPUT_HOLD/2.0), "timeout")
	if not is_processing_unhandled_input() or played_sequence.size() == 0:
		return
	played_sequence.append(KEYS.WAIT)
	_evaluate_played_sequence()

func _on_AudioStreamConductor_beat(total, in_measure):
	if total % modulo_beats == 0:
		play_next_in_sequence()
	if in_measure == 0 and is_guard_waiting():
		guard_waiting -= 1
	_record_wait_if_no_input()

func play():
	$AudioStreamConductor.play()

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
	$StageFeedback.text = ""
	$BigFeedback.text = ""
	set_process_unhandled_input(true)

func _challenger_succeeded():
	_complete_stage()
	$StageFeedback.text = "Scripture"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _challenger_failed():
	$StageFeedback.text = "Blasphemy"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _evaluate_played_sequence():
	set_process_unhandled_input(false)
	var stage = _get_current_stage_data()
	if not stage is StageData:
		return
	var sequence : Array = stage.challenger_sequence
	if played_sequence.size() == sequence.size():
		_reset_guard()
		yield(get_tree().create_timer(1.0), "timeout")
		if played_sequence.hash() == sequence.hash():
			_challenger_succeeded()
		else:
			_challenger_failed()
		played_sequence.clear()
	else:
		yield(get_tree().create_timer(INPUT_HOLD), "timeout")
		_refresh_input()

func _unhandled_input(event):
	var arrow_node : Node2D
	var record_key : int
	if event.is_action_pressed("move_forward"):
		arrow_node = $PlayerBeats/UpArrow
		record_key = KEYS.UP
	elif event.is_action_pressed("move_backward"):
		arrow_node = $PlayerBeats/DownArrow
		record_key = KEYS.DOWN
	elif event.is_action_pressed("move_left"):
		arrow_node = $PlayerBeats/LeftArrow
		record_key = KEYS.LEFT
	elif event.is_action_pressed("move_right"):
		arrow_node = $PlayerBeats/RightArrow
		record_key = KEYS.RIGHT
	if arrow_node:
		arrow_node.pulse()
		played_sequence.append(record_key)
		score_beat()
		_evaluate_played_sequence()

func _on_AudioStreamConductor_beat_lead_up(total):
	$NoteTrack.drop_note()
