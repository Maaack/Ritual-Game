class_name RoundData
extends Resource

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}

export(String, FILE, "*.ogg,*.wav,*.mp3") var guard_track : String
export(String, FILE, "*.ogg,*.wav,*.mp3") var challenger_track : String
export(Array, KEYS) var guard_sequence : Array = []
export(Array, KEYS) var challenger_sequence : Array = []
