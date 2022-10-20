extends AudioStreamPlayer

const SECONDS_PER_MINUTE = 60.0

export(int) var beats_per_minute : int = 100
export(int) var beats_per_measure : int = 4
export(float) var track_offset : float = 0.0
export(float) var beat_lead_time : float = 0.5

var song_position = 0.0
var song_position_in_beats = 0
var last_beat_lead_up = 0

signal beat(total, in_measure)
signal beat_lead_up(total)

func get_seconds_per_beat():
	return SECONDS_PER_MINUTE / beats_per_minute

func get_prev_beat() -> int:
	return int(floor(song_position / get_seconds_per_beat()))

func get_closest_beat() -> int:
	return int(round(song_position / get_seconds_per_beat()))

func get_next_beat() -> int:
	return int(ceil(song_position / get_seconds_per_beat()))

func get_time_to_closest_beat():
	return abs(get_closest_beat() * get_seconds_per_beat() - song_position)

func get_time_to_next_beat():
	return abs(get_next_beat() * get_seconds_per_beat() - song_position)

func _report_beat():
	var prev_beat : int = get_prev_beat()
	var next_beat : int = get_next_beat()
	if song_position_in_beats < prev_beat:
		song_position_in_beats = prev_beat
		emit_signal("beat", song_position_in_beats, song_position_in_beats % beats_per_measure)
	elif get_time_to_next_beat() < beat_lead_time and last_beat_lead_up != next_beat:
		last_beat_lead_up = next_beat
		emit_signal("beat_lead_up", last_beat_lead_up)

func _physics_process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position += track_offset
		_report_beat()

func play_from_beat(beat):
	play()
	seek(beat * get_seconds_per_beat())
