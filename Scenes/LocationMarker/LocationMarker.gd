tool
class_name LocationMarker
extends TextureButton

export(Resource) var location_data : Resource setget set_location_data
export(Array, NodePath) var neighbors : Array = []

func set_location_data(value : Resource) -> void:
	location_data = value
	var label = get_node_or_null("Label")
	if location_data == null or label == null:
		return
	label.text = location_data.name

func _ready():
	self.location_data = location_data
