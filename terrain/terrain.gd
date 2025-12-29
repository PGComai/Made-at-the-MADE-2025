extends Area2D
class_name Terrain


@export_enum("oil", "rough", "sand", "dirt") var terrain_type: String


func _ready() -> void:
	add_to_group("terrain")
