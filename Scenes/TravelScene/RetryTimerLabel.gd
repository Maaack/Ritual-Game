extends Label


func _ready():
	pass 

func _process(delta):
	if $Timer.time_left > 0:
		text = $Timer.time_left

func _on_ritual_retry():
	$Timer.start()
	
