extends Control

class_name BaseRitual

# Logic for all ritual types
export(String, FILE, "*.tscn") var return_to_scene : String

func _on_TextureButton_pressed():
	RitualCooldownManager.start_cooldown(RitualCooldownManager.BOUNCER) # TODO - from parameter specific to ritual event
	SceneLoader.load_scene(return_to_scene)
