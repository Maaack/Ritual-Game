# Thanks BitBrain and Devduck!!

extends CanvasModulate
class_name DayNightCycle

enum TimeMode {
	INGAME,
	STATIC,
	SYSTEM
}

enum StaticTime {
	MORNING = 70,
	NOON = 100,
	EVENING = 80,
	NIGHT = 0
}

const GROUP_NAME: String = "DayNightCycle"
const NIGHT_COLOR: Color = Color("#091d3a")
const DAY_COLOR: Color = Color("#ffffff")
const EVENING_COLOR: Color = Color("#ff3300")
const HALF_DAY_IN_SECONDS: float = 60.0 * 60.0 * 12.0

export(TimeMode) var time_mode = TimeMode.STATIC
export(StaticTime) var static_time = StaticTime.NOON
export var time_scale: float = 1.0

var time = 0
var expected_color: Color
var darkness: float = 0

func _process(delta: float) -> void:
	var value: float
	
	match time_mode:
		TimeMode.INGAME:
			self.time += delta * time_scale
			value = (sin(time) + 1) / 2	# 0 is midnight, 1 is high noon
		TimeMode.STATIC:
			value = static_time / 100.0
		TimeMode.SYSTEM:
			var current_seconds = _seconds_from_time(OS.get_time())
			var over_twelve = current_seconds - HALF_DAY_IN_SECONDS
			if over_twelve > 0:
				var adjusted_seconds = HALF_DAY_IN_SECONDS - over_twelve
				value = adjusted_seconds / HALF_DAY_IN_SECONDS
			else:
				value = current_seconds / HALF_DAY_IN_SECONDS

	expected_color = get_source_colour(value).linear_interpolate(get_target_colour(value), value)
	self.color = expected_color.darkened(darkness)
			
func get_source_colour(value):
	return NIGHT_COLOR.linear_interpolate(EVENING_COLOR, value)

func get_target_colour(value):
	return EVENING_COLOR.linear_interpolate(DAY_COLOR, value)

func _seconds_from_time(time_dict: Dictionary) -> float:
	return (time_dict["hour"] * 60.0 * 60.0) + (time_dict["minute"] * 60.0) + time_dict["second"]
