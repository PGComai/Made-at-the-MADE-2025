extends MarginContainer

@onready var main_space = $VBoxContainer/Space

@export var character_ui_scene: PackedScene

func instance_character_ui(end_position, character_data):
	var character_ui = character_ui_scene.instantiate()
	character_ui.set_modulate(Color(1.0,1.0,1.0,0.0))
	var start_position = end_position + Vector2(0,200)
	character_ui.position = start_position
	main_space.add_child(character_ui)
	character_ui.set_data(character_data)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(character_ui, "position", end_position, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_vis = get_tree().create_tween()
	tween_vis.tween_property(character_ui, "modulate", Color(1.0,1.0,1.0,1.0), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(.5).timeout
	#idk whatever else needs doing after

func clear_character_select():
	for character_ui_node in main_space.get_children():
		if(character_ui_node.is_in_group("character_ui")):
			character_ui_node.remove_self()
