extends Control


func _load_ritual(location_data : LocationData) -> void:
	SceneLoader.load_scene(location_data.ritual_scene_path)

func _attach_signals():
	for node in get_children():
		if node.is_in_group("LocationMarkers"):
			var locationbutton = node.get_node("LocationMarkerBtn")
			locationbutton.connect("pressed", self, "_load_ritual", [node.location_data])

func _ready():
	_attach_signals()
	
	var player_level : int = 0
	if not Config.has_section("Player"):
		Config.set_config("Player", "Level", player_level)
	
	player_level = Config.get_config("Player", "Level", player_level)
	var location_container = get_node("%LocationContainer")
	for child in location_container.get_children():
		if child is LocationMarker:
			var location_level = child.location_data.level
			if location_level > player_level:
				child.hide()
