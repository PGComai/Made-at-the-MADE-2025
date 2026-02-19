extends Node2D

class_name Destructible

var hp = 1

func _on_projectile_entered():
	print("got hit by projectile!")
	hp -= 1
	if(hp <= 0):
		queue_free()
