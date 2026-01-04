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

func remove_self():
	var end_position = position + Vector2(0,-200)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(self, "position", end_position, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_vis = get_tree().create_tween()
	tween_vis.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.0), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.5).timeout
	queue_free()
