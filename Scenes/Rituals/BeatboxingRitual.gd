extends BaseRitual

func _ready():
	var dialog = Dialogic.start("BeatboxRitualTimeline")
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)

func dialog_listener(string):
	match string:
		"return":
			SceneLoader.load_scene(return_to_scene)
