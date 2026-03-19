extends Control

@onready var continue_button = $PanelContainer/MarginContainer/VBoxContainer/Continue

func _ready() -> void:
	var filename = "user://save_game.save"
	if(FileAccess.file_exists(filename)):
		continue_button.visible = true
		
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("a"):
		#get_tree().change_scene_to_file("res://scenes/Levels/Track1.tscn")

func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('test_timeline_1')
		get_viewport().set_input_as_handled()
		
func _on_play_newgame_button_up() -> void:
	var filename = "user://save_game.save"
	if(FileAccess.file_exists(filename)):
		DirAccess.remove_absolute(filename)
	assert(is_instance_valid(get_tree()))
	get_tree().change_scene_to_file("res://scenes/Levels/Track1.tscn")


func _on_continue_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/Levels/Track1.tscn")
