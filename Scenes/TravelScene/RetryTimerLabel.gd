extends Label

# Need to try to set the wait time based on the TIME_SCALE and overall wave length of the DayNIGHT cycle
# const TIME_SCALE = .06
onready var timer = $Timer

func _ready():
	timer.wait_time = 10
	timer.one_shot = true

func _process(_delta):
	if $Timer.time_left > 0:
		text = "%0:02d" % $Timer.time_left
