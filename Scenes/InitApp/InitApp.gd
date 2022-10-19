extends Node

export(String, FILE, "*.tscn") var next_scene : String

func _ready():
	if AppLog.get_first_version_opened() == "0.0.0":
		Config.clear_config_file()
	AppSettings.initialize_from_config()
	SceneLoader.load_scene(next_scene)
