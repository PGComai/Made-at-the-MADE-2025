extends Resource

class_name PowerupData

@export var name: String

@export var custom_properties_names: Array[String]
@export var custom_properties_types: Array[Variant.Type]
@export var custom_properties_values: Array

# press, hold 
@export var ammo_type: String

@export var current_ammo: int
@export var max_ammo: int
