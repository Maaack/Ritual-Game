class_name RoundData
extends Resource

enum KEYS{WAIT,UP,DOWN,LEFT,RIGHT}

export(AudioStream) var guard_stream : AudioStream
export(Array, KEYS) var guard_sequence : Array = []
export(Array, KEYS) var challenger_sequence : Array = []
export(Array, AudioStream) var challenger_streams : Array = []
