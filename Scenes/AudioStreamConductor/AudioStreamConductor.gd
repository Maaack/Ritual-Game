extends AudioStreamPlayer

const SECONDS_PER_MINUTE = 60.0

export(int) var beats_per_minute : int = 100
export(int) var beats_per_measure : int = 4
export(float) var track_offset : float = 0.0

var song_position = 0.0
var song_position_in_beats = 0

signal beat(total, in_measure)

func get_seconds_per_beat():
	return SECONDS_PER_MINUTE / beats_per_minute

func get_closest_beat():
	return int(round(song_position / get_seconds_per_beat()))

func get_time_to_closest_beat():
	return abs(get_closest_beat() * get_seconds_per_beat() - song_position)

func _physics_process(delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position += track_offset
		_report_beat()

func _report_beat():
	var next_song_position_in_beats : int = int(floor(song_position / get_seconds_per_beat()))
	if song_position_in_beats < next_song_position_in_beats:
		song_position_in_beats = next_song_position_in_beats
		emit_signal("beat", song_position_in_beats, song_position_in_beats % beats_per_measure)

func play_from_beat(beat):
	play()
	seek(beat * get_seconds_per_beat())
