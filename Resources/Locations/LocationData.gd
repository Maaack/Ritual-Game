class_name LocationData
extends Resource

export(String) var name : String
export(String, MULTILINE) var description : String
export(String, FILE, "*.tscn") var ritual_scene_path : String
export(int, "0", "1", "2") var level
