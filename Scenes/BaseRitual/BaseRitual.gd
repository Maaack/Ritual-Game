extends Control

class_name BaseRitual

# Logic for all ritual types
export(String, FILE, "*.tscn") var return_to_scene : String


func leave_ritual():	
	SceneLoader.load_scene(return_to_scene)
