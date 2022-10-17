extends Node2D


func _load_ritual(location_data : LocationData) -> void:
	SceneLoader.load_scene(location_data.ritual_scene_path)

func _attach_signals():
	for node in $Map.get_children():
		if node is LocationMarker:
			node.connect("pressed", self, "_load_ritual", [node.location_data])

func _ready():
	_attach_signals()
