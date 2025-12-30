extends Node

@onready var game_controller = get_parent()
@onready var game_car = get_parent().car
@onready var ui = get_parent().get_node("CanvasLayer/UI")
@onready var character_ui = get_parent().get_node("CanvasLayer/UI/VBoxContainer/Space/CharacterInfo")

@export var character_info_scene : PackedScene

var has_started_race := false

func _ready() -> void:
	character_info_display(true)

func _process(delta: float) -> void:
	if(!has_started_race):
		if(Input.is_action_just_pressed("a")):
			game_car.has_started_race = true
			character_info_display(false)


func character_info_display(state):
	character_ui.visible = state
