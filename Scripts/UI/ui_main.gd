extends MarginContainer

@onready var main_space = $VBoxContainer/Space
@onready var character_chooser = $VBoxContainer/Space/CharacterChooser
@onready var upgrade_chooser = $VBoxContainer/Space/UpgradeChooser
@onready var power_up_label = %PowerUpLabel

@export var character_ui_scene: PackedScene
@export var upgrade_choice_ui_scene: PackedScene

func instance_character_ui(end_position, character_data, parent_node = main_space):
	var character_ui = character_ui_scene.instantiate()
	character_ui.set_modulate(Color(1.0,1.0,1.0,0.0))
	var start_position = end_position + Vector2(0,200)
	character_ui.position = start_position
	parent_node.add_child(character_ui)
	character_ui.set_data(character_data)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(character_ui, "position", end_position, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_vis = get_tree().create_tween()
	tween_vis.tween_property(character_ui, "modulate", Color(1.0,1.0,1.0,1.0), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	return character_ui
	#anything else needs doing after?
	#await get_tree().create_timer(.5).timeout
	
func clear_character_select():
	for character_ui_node in main_space.get_children():
		if(character_ui_node.is_in_group("character_ui")):
			character_ui_node.remove_self()
	for character_ui_node in character_chooser.get_children():
		if(character_ui_node.is_in_group("character_ui")):
			character_ui_node.remove_self()

func instance_upgrade_choice(end_position, upgrade_data, parent_node = main_space):
	var upgrade_ui = upgrade_choice_ui_scene.instantiate()
	upgrade_ui.set_modulate(Color(1.0,1.0,1.0,0.0))
	var start_position = end_position + Vector2(0,200)
	print("adding upgrade at ", start_position)
	upgrade_ui.position = start_position
	parent_node.add_child(upgrade_ui)
	upgrade_ui.set_data(upgrade_data)
	var tween_pos = get_tree().create_tween()
	tween_pos.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_pos.tween_property(upgrade_ui, "position", end_position, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_vis = get_tree().create_tween()
	tween_vis.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_vis.tween_property(upgrade_ui, "modulate", Color(1.0,1.0,1.0,1.0), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	return upgrade_ui

func clear_upgrade_chooser():
	for upgrade_ui_node in upgrade_chooser.get_children():
		if(upgrade_ui_node.is_in_group("upgrade_ui")):
			upgrade_ui_node.remove_self()
			
func update_power_up(pu_resource):
	power_up_label.text = "Power Up: %s" % pu_resource.name
	match pu_resource.ammo_type:
		"hold":
			power_up_label.text += "\n Juice: "
		"press":
			power_up_label.text += "\n Ammo: "
	power_up_label.text +=  " %s / %s "  % [pu_resource.current_ammo,pu_resource.max_ammo]

func add_xp(amount, next_lvl_needed):
	%XPLabel.text = "XP:%s/%s" % [amount,next_lvl_needed]
	
func set_character_level(level):
	%LevelLabel.text = "LVL:%s" % str(level+1)
