extends Control


func _load_ritual(location_data : LocationData) -> void:
	SceneLoader.load_scene(location_data.ritual_scene_path)

func _attach_signals():
	var location_container = get_node("%LocationContainer")
	for node in location_container.get_children():
		if node.is_in_group("LocationMarkers"):
			var locationbutton = node.get_node("LocationMarkerBtn")
			locationbutton.connect("pressed", self, "_load_ritual", [node.location_data])

func _ready():
	_attach_signals()
	GameLog.level_reached(0)
	var player_level : int = GameLog.get_max_level_reached()
	var location_container = get_node("%LocationContainer")
	for child in location_container.get_children():
		if child is LocationMarker:
			if child.location_data == RitualCooldownManager.left_location:
				child.start_timer()
			var location_level = child.location_data.level
			if location_level > player_level:
				child.hide()
