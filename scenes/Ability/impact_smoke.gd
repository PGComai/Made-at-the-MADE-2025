extends Node2D

func _ready() -> void:
	
	var smoke_rot = randf_range(0.0,360.0)
	$Smoke.rotation_degrees = smoke_rot
	$Smoke.play("default")
	
	$SmokeShadow.rotation_degrees = smoke_rot
	$SmokeShadow.play("default")
	
	var tween_rot = get_tree().create_tween()
	
	var puff_rot = randf_range(0.0,360.0)
	tween_rot.tween_property($Puff, "rotation_degrees", puff_rot, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_pos = get_tree().create_tween()
	var pos_offset = Vector2(randf_range(0.0,8.0),randf_range(0.0,8.0))
	tween_pos.tween_property($Puff, "position", $Puff.position + pos_offset, .7).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property($Puff, "scale", Vector2(1.5,1.5), 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	$Puff.play("default")
	await get_tree().create_timer(0.5).timeout
	var tween_mod = get_tree().create_tween()
	tween_mod.tween_property($Puff, "modulate", Color(.0,.0,.0,.0), .5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.5).timeout
	queue_free()
