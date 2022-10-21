extends BaseRitual

signal ritual_completed

export(Array, Resource) var stages : Array = []

var current_stage_iter : int = 0

func _ready():
	$BeatControl.play()
	_start_stage()

func start_dialogic_timeline(timeline : String):
	var dialog = Dialogic.start(timeline)
	dialog.connect("dialogic_signal", self, "dialog_listener")
	add_child(dialog)

func get_current_stage():
	return stages[current_stage_iter]

func _start_challenge():
	$BeatControl.reset()
	$BeatControl.active = true

func _start_stage():
	var current_stage = get_current_stage()
	$BeatControl.rounds = current_stage.rounds
	if current_stage.dialogic_timeline != "":
		start_dialogic_timeline(current_stage.dialogic_timeline)
	else:
		_start_challenge()

func _complete_ritual():
	current_stage_iter = 0
	emit_signal("ritual_completed")
	SceneLoader.load_scene(return_to_scene)

func _complete_stage():
	current_stage_iter += 1
	if current_stage_iter >= stages.size():
		_complete_ritual()
	_start_stage()

func dialog_listener(string):
	match string:
		"return":
			SceneLoader.load_scene(return_to_scene)
		"beatbox":
			_start_challenge()

func _on_BeatControl_challenge_completed():
	_complete_stage()
