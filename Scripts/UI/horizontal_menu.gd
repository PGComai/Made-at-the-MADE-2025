extends Node

@export var num_options: int

var enabled_status := false
var curr_index := 0

func _process(delta: float) -> void:
	
	if(!enabled_status):
		return
		
	#print(Input.get_axis("ui_down","ui_up"))
	if(Input.is_action_just_pressed("right")):
		next_menu_option()
	elif(Input.is_action_just_pressed("left")):
		previous_menu_option()
	elif(Input.is_action_just_pressed("a")):
		select_current()
	
func next_menu_option():
	#sfx_player.play_sfx(move_sfx)
	curr_index += 1
	if(curr_index >= num_options):
		curr_index = 0
	if(get_child(curr_index) is Button):
		get_child(curr_index).call_deferred("grab_focus")

func previous_menu_option():
	#sfx_player.play_sfx(move_sfx)
	curr_index -= 1
	if(curr_index < 0):
		curr_index = num_options - 1
	if(get_child(curr_index) is Button):
		get_child(curr_index).call_deferred("grab_focus")
	
func select_current():
	print("selecting menu item")
	enabled_status = false
	if(get_child(curr_index) is Button):
		get_child(curr_index).set_pressed_no_signal(true)
