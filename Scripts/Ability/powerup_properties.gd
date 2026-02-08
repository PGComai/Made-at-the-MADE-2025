# CURRENTLY DEPRECATED
# Properties are just in some arrays directly on the powerup resource, at least for now

extends Resource
class_name PowerupProperties

@export var property_names: Array[String]
@export var property_types: Array[Variant.Type]
@export var property_values: Array
