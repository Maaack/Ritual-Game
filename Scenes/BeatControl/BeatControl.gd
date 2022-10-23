extends Node2D

signal round_completed(round_number)
signal challenge_completed
signal beat_lead_up(total)
signal note_played(key)
signal beat_hit(delta)

const INPUT_HOLD : float = 0.4
const GUARD_PAUSE_MEASURES : int = 1

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}
enum BOXERS{NONE,GUARD,CHALLENGER}

export(Array, Resource) var rounds : Array = []
export(Array, AudioStream) var mistake_sounds : Array = []

var current_round_iter : int = 0
var current_key_in_guard_sequence : int = 0
var current_boxer : int = BOXERS.GUARD
var boxer_waiting : bool = true
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

func _reset_call_and_response():
	boxer_waiting = true
	current_boxer = BOXERS.GUARD
	current_key_in_guard_sequence = 0

func play_guard_music():
	var round_data = _get_current_round_data()
	if $GuardSFX.stream != round_data.guard_stream:
		$GuardSFX.stream = round_data.guard_stream
	if not $GuardSFX.playing:
		$GuardSFX.play()

func reset():
	if rounds.size() < 1:
		emit_signal("challenge_completed")
		active = false
	current_round_iter = 0
	current_boxer = BOXERS.NONE
	yield(get_tree().create_timer(INPUT_HOLD),"timeout")
	_reset_call_and_response()

func is_guard_boxing():
	return current_boxer == BOXERS.GUARD

func is_challenger_boxing():
	return current_boxer == BOXERS.CHALLENGER

func play_note(key : int) -> void:
	emit_signal("note_played", key)

func play_next_in_sequence():
	if boxer_waiting or (not is_guard_boxing()):
		return
	var round_data = _get_current_round_data()
	if not round_data is RoundData:
		return
	play_guard_music()
	var sequence : Array = round_data.guard_sequence
	var next_key = sequence[current_key_in_guard_sequence]
	current_key_in_guard_sequence += 1
	play_note(next_key)
	if current_key_in_guard_sequence >= sequence.size():
		boxer_waiting = true
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

func _on_AudioStreamConductor_beat_lead_up(total, in_measure):
	if is_challenger_boxing() and boxer_waiting and in_measure == 0:
		boxer_waiting = false
	if not active or boxer_waiting or not is_challenger_boxing():
		return
	emit_signal("beat_lead_up", total)

func _on_AudioStreamConductor_beat(_total, in_measure):
	if not active:
		return
	if in_measure == 0 and boxer_waiting:
		boxer_waiting = false
	if is_challenger_boxing():
		_record_wait_if_no_input()
	if is_guard_boxing():
		play_next_in_sequence()

func play(audio_stream : AudioStream, beats_per_minute : int, beats_per_measure : int, track_offset : float = 0.0):
	$AudioStreamConductor.stream = audio_stream
	$AudioStreamConductor.beats_per_minute = beats_per_minute
	$AudioStreamConductor.beats_per_measure = beats_per_measure
	$AudioStreamConductor.track_offset = track_offset
	$AudioStreamConductor.play()

func score_beat():
	var delta = $AudioStreamConductor.get_time_to_closest_beat()
	emit_signal("beat_hit", delta)

func _refresh_input():
	$RoundFeedback.text = ""
	set_process_unhandled_key_input(true)

func _challenger_succeeded():
	_complete_round()
	$SuccessSFX.play()
	$RoundFeedback.text = "Scripture"
	$RoundFeedback.set("custom_colors/font_color", Color(0.22,0.92,0.2))
	yield(get_tree().create_timer(1.0), "timeout")
	_refresh_input()

func _challenger_failed():
	$FailureSFX.play()
	$RoundFeedback.text = "Blasphemy"
	$RoundFeedback.set("custom_colors/font_color", Color(1,0,0))
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
	_reset_call_and_response()

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
