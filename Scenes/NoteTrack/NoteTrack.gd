extends Node2D

var dropping_note_scene : PackedScene = preload("res://Scenes/DroppingNoteElement/DroppingNote.tscn")

func drop_note(speed = 1):
	var dropping_note_instance = dropping_note_scene.instance()
	add_child(dropping_note_instance)
	dropping_note_instance.play()
	if speed != 1:
		dropping_note_instance.set_speed(speed)
