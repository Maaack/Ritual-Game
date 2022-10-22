extends Node2D

signal round_completed(round_number)
signal challenge_completed
signal beat_lead_up(total)
signal note_played(key)

const GREAT_RANGE : float = 0.025
const GOOD_RANGE : float = 0.075
const MEH_RANGE : float = 0.15
const INPUT_HOLD : float = 0.4
const GUARD_PAUSE_MEASURES : int = 1

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{NONE,GUARD,CHALLENGER}

export(Array, Resource) var rounds : Array = []
export(Array, AudioStream) var mistake_sounds : Array = []

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
		$GuardSFX.stream = round_data.guard_stream

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

func play_note(key : int) -> void:
	emit_signal("note_played", key)

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
	play_note(next_key)
	if current_key_in_guard_sequence >= sequence.size():
		current_boxer = BOXERS.CHALLENGER

func _record_wait_if_no_input():
	if not is_processing_unhandled_key_input():
		return
	yield(get_tree().create_timer(INPUT_HOLD/2.0), "timeout")
	if (not is_processing_unhandled_key_input()) or played_sequence.size() == 0:
		return
	_play_challenger_sound(KEYS.WAIT)
	played_sequence.append(KEYS.WAIT)
	_check_sequence_after_waiting()

func _on_AudioStreamConductor_beat_lead_up(total):
	if not active or not is_challenger_boxing():
		return
	emit_signal("beat_lead_up", total)

func _on_AudioStreamConductor_beat(_total, in_measure):
	if not active:
		return
	if is_challenger_boxing():
		_record_wait_if_no_input()
	if is_guard_boxing():
		if in_measure == 0 and is_guard_waiting():
			guard_waiting -= 1
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
	$SuccessSFX.play()
	$RoundFeedback.text = "Scripture"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _challenger_failed():
	$FailureSFX.play()
	$RoundFeedback.text = "Blasphemy"
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _has_played_full_sequence():
	var round_data = _get_current_round_data()
	return played_sequence.size() == round_data.challenger_sequence.size()

func _evaluate_full_played_sequence():
	set_process_unhandled_key_input(false)
	var round_data = _get_current_round_data()
	var final_played_sequence = played_sequence.duplicate()
	print(final_played_sequence)
	current_boxer = BOXERS.NONE
	$ProcessingSFX.play()
	yield(get_tree().create_timer(1.0), "timeout")
	if final_played_sequence.hash() == round_data.challenger_sequence.hash():
		_challenger_succeeded()
	else:
		_challenger_failed()
	played_sequence.clear()
	_reset_guard()
	current_boxer = BOXERS.GUARD

func _check_sequence_after_waiting():
	if _has_played_full_sequence():
		_evaluate_full_played_sequence()

func _check_sequence_after_input():
	if _has_played_full_sequence():
		_evaluate_full_played_sequence()
	else:
		yield(get_tree().create_timer(INPUT_HOLD), "timeout")
		_refresh_input()

func _play_challenger_sound(played_key):
	var round_data = _get_current_round_data()
	var current_note : int = played_sequence.size()
	if current_note >= round_data.challenger_streams.size():
		return
	var expected_key = round_data.challenger_sequence[current_note]
	var audio_stream : AudioStream
	if expected_key == played_key:
		audio_stream = round_data.challenger_streams[current_note]
	else:
		mistake_sounds.shuffle()
		audio_stream = mistake_sounds[0]
	$ChallengerSFX.stream = audio_stream
	$ChallengerSFX.play()

func _unhandled_key_input(event):
	print("input")
	if is_guard_boxing():
		current_boxer = BOXERS.CHALLENGER
		return
	var record_key : int
	if event.is_action_pressed("move_forward"):
		record_key = KEYS.UP
	elif event.is_action_pressed("move_backward"):
		record_key = KEYS.DOWN
	elif event.is_action_pressed("move_left"):
		record_key = KEYS.LEFT
	elif event.is_action_pressed("move_right"):
		record_key = KEYS.RIGHT
	if record_key:
		play_note(record_key)
		_play_challenger_sound(record_key)
		played_sequence.append(record_key)
		score_beat()
		set_process_unhandled_key_input(false)
		_check_sequence_after_input()
