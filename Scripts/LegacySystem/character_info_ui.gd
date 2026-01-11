extends Control

@onready var portrait = $VBoxContainer/HBoxContainer/Player/Portrait
@onready var character_name = $VBoxContainer/HBoxContainer/Player/Name
@onready var stats = $VBoxContainer/HBoxContainer/Stats

var character_data

var selected := false
var selected_time := 0.0

func set_data(char_data):
	character_data = char_data
	
	character_name.text = str(char_data.first_name + " " 
	+ char_data.last_name + " " + char_data.name_suffix +
	"\n Class: " + char_data.character_class.classname)
	
	stats.get_node("Turn/StatVal").text = str(char_data.turn)
	stats.get_node("OffRoadTurn/StatVal").text = str(char_data.off_road_turn)
	stats.get_node("Grip/StatVal").text = str(char_data.grip)
	stats.get_node("OffRoadGrip/StatVal").text = str(char_data.off_road_grip)
	stats.get_node("Drift/StatVal").text = str(char_data.drift_power)
	
	stats.get_node("Accel/StatVal").text = str(char_data.acceleration)

func set_selected(state):
	selected = state
	if(selected):
		z_index = 1
	else:
		z_index = 0
		scale = Vector2(1.0,1.0)
	
func _process(delta: float) -> void:
	if(selected):
		selected_time += delta * 4.0
		selected_time = fmod(selected_time,2*PI)
		var scale_mod = 1.3 + (sin(selected_time) / 10.0)
		scale = Vector2(scale_mod, scale_mod)

func remove_self():
	var end_position = position + Vector2(0,-200)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(self, "position", end_position, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_vis = get_tree().create_tween()
	tween_vis.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.0), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.5).timeout
	queue_free()
	
