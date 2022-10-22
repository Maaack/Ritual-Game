extends Panel

var sliding_note_scene : PackedScene = preload("res://Scenes/BeatControl/SlidingBeat.tscn")

func show_beat(speed = 1):
	var sliding_note_instance_1 = sliding_note_scene.instance()
	var sliding_note_instance_2 = sliding_note_scene.instance()
	get_node("%SlidePosition1").add_child(sliding_note_instance_1)
	get_node("%SlidePosition2").add_child(sliding_note_instance_2)
	sliding_note_instance_1.play()
	sliding_note_instance_2.play()
	if speed != 1:
		sliding_note_instance_1.set_speed(speed)
		sliding_note_instance_2.set_speed(speed)
