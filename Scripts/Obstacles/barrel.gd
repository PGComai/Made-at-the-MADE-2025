extends Destructible

class_name Barrel

@export var xp_collectable_scene: PackedScene

var collectable_amt_low = 7
var collectable_amt_high = 10

func _on_projectile_entered():
	if(hp - 1 <= 0):
		bust_open()
	super._on_projectile_entered()
		
func bust_open():
	print("busting barrel!")
	instance_collectables()
	
func instance_collectables():
	for i in randi_range(collectable_amt_low,collectable_amt_high):
		var collectable = xp_collectable_scene.instantiate()
		collectable.global_position = global_position + Vector2(randf_range(0.0,40.0),randf_range(0.0,40.0))
		get_parent().call_deferred("add_child", collectable)
