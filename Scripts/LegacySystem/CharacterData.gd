extends Resource

class_name CharacterData

@export var first_name: String
@export var last_name: String
@export var name_suffix: String

#class / stats
@export var character_class: CharacterClass

@export var base_speed: int
@export var speed_increase: int
@export var acceleration: int
@export var turn: int
@export var grip: int
@export var off_road_turn: int
@export var off_road_grip: int
@export var terrain_slip: int
@export var terrain_damp: int
@export var drift_power: int

@export var base_item_ammo: int

@export var base_health: float
@export var health_drain: float
@export var health_regen: float

#portrait
@export var portrait_face_shape: int
@export var portrait_eyes: int
@export var portrait_eyebrows: int
@export var portrait_nose: int
@export var portrait_mouth: int
@export var portrait_ears: int
@export var portrait_hair: int
@export var portrait_face_hair: int
@export var portrait_hair_color: int
@export var portrait_shirt_color: int

#non-persistent
@export var level: int
@export var xp: int
