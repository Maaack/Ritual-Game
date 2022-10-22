extends Control

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}

func play_note(key : int) -> void:
	match(key):
		KEYS.UP:
			$ArrowElementUp.pulse()
		KEYS.DOWN:
			$ArrowElementDown.pulse()
		KEYS.LEFT:
			$ArrowElementLeft.pulse()
		KEYS.RIGHT:
			$ArrowElementRight.pulse()
		KEYS.WAIT:
			pass
