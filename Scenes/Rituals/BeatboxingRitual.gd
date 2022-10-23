extends BaseRitual

const GREAT_RANGE : float = 0.025
const GOOD_RANGE : float = 0.075
const MEH_RANGE : float = 0.15

signal ritual_completed

export(Array, Resource) var stages : Array = []
export(AudioStream) var music_stream : AudioStream
export(int) var beats_per_measure : int = 4
export(int) var beats_per_minute : int = 120
export(float) var track_offset : float = 0.0
export(Resource) var location_data : Resource

var current_stage_iter : int = 0
var score : int = 0

func _ready():
	$BeatControl.play(music_stream, beats_per_minute, beats_per_measure, track_offset)
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
	GameLog.level_reached(location_data.level + 1)
	SceneLoader.load_scene(return_to_scene)

func _complete_stage():
	current_stage_iter += 1
	if current_stage_iter >= stages.size():
		_complete_ritual()
	_start_stage()

func dialog_listener(string):
	match string:
		"return":
			leave_ritual()
		"beatbox":
			_start_challenge()
			
func leave_ritual():	
	RitualCooldownManager.start_cooldown(location_data.name)
	.leave_ritual()

func score_beat(delta):
	var feedback_node = get_node("%BigFeedback")
	var score_counter_node = get_node("%ScoreCounter")
	if delta < GREAT_RANGE:
		score += 100
		feedback_node.text = "Great"
	elif delta < GOOD_RANGE:
		score += 25
		feedback_node.text = "Good"
	elif delta < MEH_RANGE:
		score += 10
		feedback_node.text = "Meh"
	else:
		feedback_node.text = "What?"
	score_counter_node.text = "%d" % score
	yield(get_tree().create_timer(0.45), "timeout")
	feedback_node.text = ""

func _on_BeatControl_challenge_completed():
	_complete_stage()


func _on_BeatControl_beat_lead_up(total):
	$VBoxContainer/BeatVisualizer.show_beat()


func _on_BeatControl_note_played(key):
	$VBoxContainer/CenterContainer/NoteVisualizer.play_note(key)


func _on_BeatControl_beat_hit(delta):
	score_beat(delta)


func _on_BackButton_pressed():
	leave_ritual()
