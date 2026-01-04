extends Node2D

@export var lineage: String
@export var current_character: String

@export var game_version: String = "0.1"

@export var music_volume: float = 50.0
@export var sfx_volume: float = 50.0


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"game_version" : game_version,
		"lineage" : lineage,
		"current_character": current_character,
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume
	}
	return save_dict
