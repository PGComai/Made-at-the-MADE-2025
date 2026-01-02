extends Control

@onready var portrait = $VBoxContainer/HBoxContainer/Player/Portrait
@onready var character_name = $VBoxContainer/HBoxContainer/Player/Name
@onready var stats = $VBoxContainer/HBoxContainer/Stats

func set_data(char_data):
	character_name.text = str(char_data.first_name + " " 
	+ char_data.last_name + " " + char_data.name_suffix)
	
	stats.get_node("Turn/StatVal").text = str(char_data.turn)
	
	stats.get_node("Grip/StatVal").text = str(char_data.grip)
	
	stats.get_node("Drift/StatVal").text = str(char_data.drift_power)
	
	stats.get_node("Accel/StatVal").text = str(char_data.acceleration)
