extends Node2D

class_name BaseRitual

# Logic for all ritual types
export(String, FILE, "*.tscn") var return_to_scene : String

func _on_TextureButton_pressed():
	SceneLoader.load_scene(return_to_scene)
