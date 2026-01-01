extends Node

@onready var game_controller = get_parent()
@onready var game_car = get_parent().car
@onready var ui = get_parent().get_node("CanvasLayer/UI")
@onready var character_ui = get_parent().get_node("CanvasLayer/UI/VBoxContainer/Space/CharacterInfo")

@export var character_info_scene : PackedScene

var current_character_data

var has_started_race := false

var turn_values = {
	1 : .8,
	2 : 1.1,
	3 : 1.4,
	4 : 1.7,
	5 : 2.0,
	6 : 2.5,
	7 : 3.0
}

var grip_values = {
	1: 2,
	2: 3,
	3: 4,
	4: 6,
	5: 8,
	6: 10,
	7: 12
}

var grip_turn_adjustment_values = {
	1: .7,
	2: .5,
	3: .4,
	4: .3,
	5: .2,
	6: .1,
	7: .0
}

func _ready() -> void:
	generate_character()
	apply_stats_to_car(current_character_data)
	character_info_display(true)

func _process(delta: float) -> void:
	if(!has_started_race):
		if(Input.is_action_just_pressed("a")):
			game_car.has_started_race = true
			character_info_display(false)


func character_info_display(state):
	character_ui.set_data(current_character_data)
	character_ui.visible = state

func generate_character():
	var char_data = CharacterData.new()
	# name
	char_data.first_name = "Dale"
	char_data.last_name = "Earnhardt"
	char_data.name_suffix = "II"
	# stats
	char_data.turn = randi_range(1,7)
	char_data.grip = randi_range(1,7)
	
	current_character_data = char_data
	return char_data
	

func apply_stats_to_car(char_data):
	game_car.turn_handling = turn_values[char_data.turn]
	game_car.grip_stat = grip_values[char_data.grip]
	game_car.grip_turn_adjustment = grip_turn_adjustment_values[char_data.turn]
