extends Control

@onready var icon = $VBoxContainer/HBoxContainer/Upgrade/Icon
@onready var name_label = $VBoxContainer/HBoxContainer/Upgrade/Name
@onready var description_label = $VBoxContainer/HBoxContainer/Upgrade/Description

var upgrade_data

var selected := false
var selected_time := 0.0

func set_data(data):
	upgrade_data = data
	
	name_label.text = str(upgrade_data.name)
	description_label.text = str(upgrade_data.description)
	
	
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
