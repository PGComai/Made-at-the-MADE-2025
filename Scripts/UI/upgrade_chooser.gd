extends "res://Scripts/UI/horizontal_menu.gd"

@onready var legacy_system = %LegacySystem
@onready var ui_node = get_node("../../..")
@onready var game_controller = get_node("/root/Racetrack/Main")
@export var upgrade_choice_scene: PackedScene

@export var possible_upgrades: Array[UpgradeData]

func _ready() -> void:
	pass
	
func instance_upgrades():
	#gamestate = ui_transition
	game_controller.set_game_state(3)
	for i in range(3):
		var end_position = Vector2(260 + 200 * i, 332)
		var upgrade_data = possible_upgrades.pick_random()
		ui_node.instance_upgrade_choice(end_position, upgrade_data, self)
		await get_tree().create_timer(.5).timeout
	curr_index = 1
	get_child(curr_index).set_selected(true)
	#game_state = upgrade_select
	game_controller.set_game_state(2)
	enabled_status = true

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
	var selected_upgrade = get_child(curr_index).upgrade_data
	var up_type = selected_upgrade.upgrade_type
	match(up_type):
		"car_prop_up":
			var curr_prop_val = game_controller.car.get(selected_upgrade.property_affected_name)
			var prop_type = selected_upgrade.property_affected_type
			var new_prop_val = curr_prop_val + type_convert(selected_upgrade.property_affected_amt,prop_type)
			game_controller.car.set(selected_upgrade.property_affected_name,new_prop_val)
		"prop_up":
			var powerup_resource = game_controller.get_cached_powerup(selected_upgrade.powerup_affected)
			var curr_prop_val = powerup_resource.get(selected_upgrade.property_affected_name)
			var prop_type = selected_upgrade.property_affected_type
			var new_prop_val = curr_prop_val + type_convert(selected_upgrade.property_affected_amt,prop_type)
			powerup_resource.set(selected_upgrade.property_affected_name,new_prop_val)
		"custom_prop_up":
			var powerup_resource = game_controller.get_cached_powerup(selected_upgrade.powerup_affected)
			var prop_index = powerup_resource.custom_properties_names.find(selected_upgrade.property_affected_name)
			var curr_prop_val = powerup_resource.custom_properties_values.get(prop_index)
			var prop_type = selected_upgrade.property_affected_type
			var new_prop_val = curr_prop_val + type_convert(selected_upgrade.property_affected_amt,prop_type)
			powerup_resource.custom_properties_values[prop_index] = new_prop_val
			print("up custom prop to ", new_prop_val)
