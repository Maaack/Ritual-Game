extends AudioStreamPlayer


export(int) var beats_per_minute : int = 100
export(int) var beats_per_measure : int = 4
export(float) var track_offset : float = 0.0

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 1
onready var sec_per_beat = 60.0 / beats_per_minute
var last_reported_beat = 0
var beats_before_start = 0
var beat_in_measure = 1

# Determining how close to the beat an event is
var closest = 0
var time_off_beat = 0.0

signal beat(position)
signal beat_in_measure(position)


func _physics_process(delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()


func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if beat_in_measure > beats_per_measure:
			beat_in_measure = 1
		emit_signal("beat", song_position_in_beats)
		emit_signal("beat_in_measure", beat_in_measure)
		last_reported_beat = song_position_in_beats
		beat_in_measure += 1


func play_with_beat_offset(num):
	beats_before_start = num
	$BeatTimer.wait_time = sec_per_beat
	$BeatTimer.start()


func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth) 
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)


func play_from_beat(beat, offset):
	play()
	seek(beat * sec_per_beat)
	beats_before_start = offset
	beat_in_measure = beat % beats_per_measure


func _on_BeatTimer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		$BeatTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$BeatTimer.wait_time = $BeatTimer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		$BeatTimer.start()
	else:
		play()
		$BeatTimer.stop()
	_report_beat()
