extends Node2D


func _load_ritual(location_data : LocationData) -> void:
	SceneLoader.load_scene(location_data.ritual_scene_path)

func _attach_signals():
	for node in get_children():
		if node.is_in_group("LocationMarkers"):
			var locationbutton = node.get_node("LocationMarkerBtn")
			locationbutton.connect("pressed", self, "_load_ritual", [node.location_data])

func _ready():
	_attach_signals()
	
	if !Config.has_section("Player"):
		Config.set_config("Player", "Level", 0)
		
	if Config.get_config("Player", "Level", 0) == 1:
		$HandshakeGuard.visible = true #can loop through all level 1 levels here rather than hard code eventually?
