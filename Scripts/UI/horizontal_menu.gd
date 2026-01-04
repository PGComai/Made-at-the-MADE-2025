extends Node

@export var num_options: int

var enabled_status := true
var curr_index := 0

func _process(delta: float) -> void:
	
	if(!enabled_status):
		return
		
	#print(Input.get_axis("ui_down","ui_up"))
	if(Input.is_action_just_pressed("ui_down")):
		print("ui down")
		next_menu_option()
	elif(Input.is_action_just_pressed("ui_up")):
		print("up")
		previous_menu_option()
	elif(Input.is_action_just_pressed("ui_accept")):
		select_current()
	
func next_menu_option():
	print("menu next")
	#sfx_player.play_sfx(move_sfx)
	curr_index += 1
	if(curr_index >= num_options):
		curr_index = 0
	get_child(curr_index).call_deferred("grab_focus")

func previous_menu_option():
	#sfx_player.play_sfx(move_sfx)
	curr_index -= 1
	if(curr_index < 0):
		curr_index = num_options - 1
	get_child(curr_index).call_deferred("grab_focus")
	
func select_current():
	print("selecting menu item")
	enabled_status = false
	get_child(curr_index).set_pressed_no_signal(true)
