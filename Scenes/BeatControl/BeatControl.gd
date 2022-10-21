extends Node2D

signal round_completed(round_number)
signal challenge_completed

const GREAT_RANGE : float = 0.025
const GOOD_RANGE : float = 0.075
const MEH_RANGE : float = 0.15
const INPUT_HOLD : float = 0.4
const GUARD_PAUSE_MEASURES : int = 1

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{NONE,GUARD,CHALLENGER}

export(Array, Resource) var rounds : Array = []
export(int) var modulo_beats : int = 1

var current_round_iter : int = 0
var current_key_in_guard_sequence : int = 0
var current_boxer : int = BOXERS.GUARD
var score : int = 0
var guard_waiting : int = 0
var played_sequence : Array = []
var active : bool = false

func _complete_round() -> void:
	emit_signal("round_completed", current_round_iter)
	current_round_iter += 1
	if current_round_iter >= rounds.size():
		emit_signal("challenge_completed")
		current_round_iter = 0
		active = false

func _get_current_round_data():
	return rounds[current_round_iter]

func _reset_guard():
	guard_waiting = GUARD_PAUSE_MEASURES
	current_key_in_guard_sequence = 0
	var round_data = _get_current_round_data()
	if round_data is RoundData:
		$GuardSFX.stream = load(round_data.guard_track)

func reset():
	_reset_guard()
	current_round_iter = 0
	current_boxer = BOXERS.NONE
	yield(get_tree().create_timer(INPUT_HOLD),"timeout")
	current_boxer = BOXERS.GUARD

func is_guard_boxing():
	return current_boxer == BOXERS.GUARD

func is_challenger_boxing():
	return current_boxer == BOXERS.CHALLENGER

func is_guard_waiting():
	return guard_waiting > 0

func play_next_in_sequence():
	if not is_guard_boxing():
		return
	var round_data = _get_current_round_data()
	if not round_data is RoundData:
		return
	if not $GuardSFX.playing:
		$GuardSFX.play()
	var sequence : Array = round_data.guard_sequence
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
		current_boxer = BOXERS.CHALLENGER

func _record_wait_if_no_input():
	if not is_processing_unhandled_key_input():
		return
	yield(get_tree().create_timer(INPUT_HOLD/2.0), "timeout")
	if not is_processing_unhandled_key_input() or played_sequence.size() == 0:
		return
	played_sequence.append(KEYS.WAIT)
	_evaluate_played_sequence()

func _on_AudioStreamConductor_beat_lead_up(total):
	if not active or not is_challenger_boxing():
		return
	$NoteTrack.drop_note()

func _on_AudioStreamConductor_beat(total, in_measure):
	if not active:
		return
	if is_challenger_boxing():
		_record_wait_if_no_input()
	if is_guard_boxing():
		if in_measure == 0 and is_guard_waiting():
			guard_waiting -= 1
		if total % modulo_beats == 0:
			play_next_in_sequence()

func play(audio_stream : AudioStream, beats_per_minute : int, beats_per_measure : int, track_offset : float = 0.0):
	$AudioStreamConductor.stream = audio_stream
	$AudioStreamConductor.beats_per_minute = beats_per_minute
	$AudioStreamConductor.beats_per_measure = beats_per_measure
	$AudioStreamConductor.track_offset = track_offset
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
	$RoundFeedback.text = ""
	$BigFeedback.text = ""
	set_process_unhandled_key_input(true)

func _challenger_succeeded():
	_complete_round()
	$RoundFeedback.text = "Scripture"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _challenger_failed():
	$RoundFeedback.text = "Blasphemy"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _evaluate_played_sequence():
	var round_data = _get_current_round_data()
	if not round_data is RoundData:
		return
	var sequence : Array = round_data.challenger_sequence
	if played_sequence.size() == sequence.size():
		set_process_unhandled_key_input(false)
		var final_played_sequence = played_sequence.duplicate()
		played_sequence.clear()
		print(final_played_sequence)
		_reset_guard()
		current_boxer = BOXERS.NONE
		yield(get_tree().create_timer(1.0), "timeout")
		if final_played_sequence.hash() == sequence.hash():
			_challenger_succeeded()
		else:
			_challenger_failed()
		played_sequence.clear()
		current_boxer = BOXERS.GUARD
	else:
		yield(get_tree().create_timer(INPUT_HOLD), "timeout")
		_refresh_input()

func _unhandled_key_input(event):
	if is_guard_boxing():
		current_boxer = BOXERS.CHALLENGER
		return
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
		set_process_unhandled_key_input(false)
		_evaluate_played_sequence()
