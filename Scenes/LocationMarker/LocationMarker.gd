tool
class_name LocationMarker
extends Control

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
	
func start_timer():
	$AnimationPlayer.play("Cooldown")
	$LocationMarkerBtn.disabled = true
	yield(get_tree().create_timer(10.0), "timeout")	
	$LocationMarkerBtn.disabled = false
	$AnimationPlayer.play("Active")	
