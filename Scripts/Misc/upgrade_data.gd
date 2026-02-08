extends Resource
class_name UpgradeData

# data related to a non-persistent upgrade

@export var name: String
@export var description: String

@export var upgrade_type: String
@export var powerup_affected: String
@export var property_affected_name: String
@export var property_affected_type: Variant.Type
@export var property_affected_amt: float
