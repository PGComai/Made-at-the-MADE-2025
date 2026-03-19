extends Node2D

@onready var game_controller = get_node("/root/Racetrack/Main")
@onready var ui_node = get_node("/root/Racetrack/Main/CanvasLayer/UI")

@export var xp_amt := 1

var game_car

var pull_to_car := false
var dist_from_car : float

func _ready() -> void:
	game_car = game_controller.car
	
func _physics_process(delta: float) -> void:
	if(pull_to_car):
		dist_from_car = (global_position - game_car.global_position).length()
		global_position = lerp(global_position, game_car.global_position, .1)# max(.05 * dist_from_car/20, .05))
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		game_controller.add_xp(xp_amt)
		queue_free()


func _on_magnet_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		pull_to_car = true
