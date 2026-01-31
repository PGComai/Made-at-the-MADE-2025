class_name Main
extends Node

const POINT_TIME := 0.1

const GAME_OVER = preload("uid://cdmwdc4fob4s2")



@export var car: Car
@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var power_up_label: Label = %PowerUpLabel
@onready var legacy_system = %LegacySystem
@onready var ui_node = $CanvasLayer/UI
@onready var character_chooser = $CanvasLayer/UI/VBoxContainer/Space/CharacterChooser
@onready var save_node = $SaveData

## state of the game
enum GameState {CHARACTER_SELECT = 0, RACING = 1}
var game_state

## The number of completed laps.
var completed_laps: int = 0

## The current score.
var score: int = 0

## How long to wait before updating the score again in seconds.
var point_cooldown: float = POINT_TIME

## A list of all checkpoints in the level.
var all_checkpoints: Array[Checkpoint] = []

## The checkpoints visited by the player
var seen_checkpoints: Array[Checkpoint] = []

## Character Lineage in use
var current_lineage: Lineage

func _ready() -> void:
	car.i_died.connect(_on_car_died)
	car.power_up_get.connect(_on_car_power_up_get)
	car.power_up_used.connect(_on_car_power_up_used)

	for node in get_tree().get_nodes_in_group("checkpoint"):
		if node is not Checkpoint:
			print(node.get_path(), " is in the checkpoint group but is not a checkpoint!")
			continue

		var checkpoint: Checkpoint = node
		var callable := record_checkpoint.bind(checkpoint)
		if not checkpoint.car_entered.is_connected(callable):
			checkpoint.car_entered.connect(callable)

		all_checkpoints.push_back(checkpoint)

	for node in get_tree().get_nodes_in_group("finish_line"):
		if node is not FinishLine:
			print(node.get_path(), " is in the finish_line group but is not a finish line!")
			continue

		var finish_line: FinishLine = node
		if not finish_line.body_entered.is_connected(_on_finish_crossed):
			finish_line.body_entered.connect(_on_finish_crossed)
	
	# game state, for _process()
	game_state = GameState.CHARACTER_SELECT
	
	# load game or create new lineage with starting character
	try_load_game()
	var is_new_game = false
	
	current_lineage = json_to_resource(save_node.lineage)
	if(current_lineage == null):
		# new game, create a new lineage
		current_lineage = legacy_system.generate_new_lineage()
		is_new_game = true
		
	var first_char_data = current_lineage.characters[0]
	var most_recent_char = current_lineage.characters[current_lineage.characters.size()-1]
	
	#save anything that might be new
	save_lineage_and_character(most_recent_char)
	
	#character UI
	if(is_new_game):
		legacy_system.apply_stats_to_car(most_recent_char)
		#instance the UI element showing the character
		ui_node.instance_character_ui(Vector2(460,332), most_recent_char)
	else:
		
		var char_ui = ui_node.instance_character_ui(Vector2(460,332), most_recent_char)
		await get_tree().create_timer(1.5)
		var tween_pos = get_tree().create_tween()
		tween_pos.tween_property(char_ui, "position", char_ui.position+Vector2(0,200), 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		var tween_vis = get_tree().create_tween()
		tween_vis.tween_property(char_ui, "modulate", Color(.3,.3,.3,.8), 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		character_chooser.instance_characters()
		await get_tree().create_timer(1.5)
		character_chooser.enabled_status = true

## Records a checkpoint for a body.
func record_checkpoint(body: Node2D, checkpoint: Checkpoint) -> void:
	if body != car:
		return
	if seen_checkpoints.has(checkpoint):
		return

	seen_checkpoints.push_back(checkpoint)
	car.toast.toast("%d/%d!" % [
		seen_checkpoints.size(),
		all_checkpoints.size(),
	])

func has_seen_all_checkpoints() -> bool:
	var to_see := all_checkpoints.duplicate()
	for seen_checkpoint in seen_checkpoints:
		to_see.erase(seen_checkpoint)
	return to_see.size() == 0

func _process(delta: float) -> void:
	match game_state:
		GameState.CHARACTER_SELECT:
			if(Input.is_action_just_pressed("a")):
				#TODO: choose_character()
				car.has_started_race = true
				car.get_random_powerup()
				ui_node.clear_character_select()
				game_state = GameState.RACING
		GameState.RACING:
			pass
	
	time_label.text = "%.2f" % car.life

	var num = int(score_label.text)
	while num != score and point_cooldown >= 0:
		var diff = (score - num)
		num = num + ceili(diff / 2.0)
		score_label.text = str(num)
		point_cooldown -= POINT_TIME
	point_cooldown += delta

func _on_finish_crossed(body: Node2D) -> void:
	if body != car:
		return

	if has_seen_all_checkpoints():
		if not car.is_dead:
			completed_laps += 1
			car._on_lap_finished(completed_laps)
			car.toast.toast("Lap %d!" % [completed_laps])
			score += floori(car.life * completed_laps)
			point_cooldown = 0
		seen_checkpoints.clear()

func _on_car_died() -> void:
	var new_game_over: GameOver = GAME_OVER.instantiate()
	new_game_over.score = score
	add_child(new_game_over)

func _on_car_power_up_get(pup: Car.PowerUp) -> void:
	if not power_up_label:
		await ready
	#power_up_label.text = "Power Up: %s" % Car.PowerUp.keys()[pup]
	
func _on_car_power_up_used() -> void:
	power_up_label.text = "Power Up: None"

# XP / Upgrades
func add_xp(amount):
	var remainder_amount = amount
	ui_node.add_xp(amount)
	
	legacy_system.current_character_data.xp = remainder_amount
	
func save_game():
	var filename = "user://save_game.save"
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	
func try_load_game():
	var filename = "user://save_game.save"
	if not FileAccess.file_exists(filename):
		#print("load game, no file exists named ", filename)
		return get_node("SaveData")# Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(filename, FileAccess.READ)
	var new_object = null
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		new_object = load(node_data["filename"]).instantiate()
		#get_node(node_data["parent"]).add_child(new_object)
		add_child(new_object)
		new_object.position = Vector2(0,0)
		print(new_object.name)
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		#print("in load game")
		#print(new_object.name)
	save_node = new_object
	print("loaded save data")
	return new_object

func save_lineage_and_character(character):
	save_node.lineage = json_string_from_resource(current_lineage)
	save_node.current_character = json_string_from_resource(character)
	save_game()
	
func json_string_from_resource(res):
	# Convert the Resource to a JSON-compatible variant
	var json_variant = JSON.from_native(res, true)  # true enables full object serialization
	return JSON.stringify(json_variant)
	
func json_to_resource(string):
	return JSON.to_native(JSON.parse_string(string),true)
