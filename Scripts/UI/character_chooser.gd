extends "res://Scripts/UI/horizontal_menu.gd"

@onready var legacy_system = %LegacySystem
@onready var ui_node = get_node("../../..")

@export var character_info_scene: PackedScene

func instance_characters():
	for i in range(3):
		var end_position = Vector2(260 + 200 * i, 332)
		var char_data = legacy_system.generate_character()
		ui_node.instance_character_ui(end_position, char_data, self)
		await get_tree().create_timer(.5).timeout
	curr_index = 1
	get_child(curr_index).set_selected(true)

func next_menu_option():
	get_child(curr_index).set_selected(false)
	super.next_menu_option()
	get_child(curr_index).set_selected(true)

func previous_menu_option():
	get_child(curr_index).set_selected(false)
	super.previous_menu_option()
	get_child(curr_index).set_selected(true)
	
func select_current():
	super.select_current()
	var selected_char = get_child(curr_index).character_data
	legacy_system.apply_stats_to_car(selected_char)
	legacy_system.add_character_to_current_lineage(selected_char)
