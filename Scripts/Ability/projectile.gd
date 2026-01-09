extends Node2D

@export var impact_smoke_scene : PackedScene
@export var log_scene: PackedScene

var direction := Vector2(0,0)
var speed := 0.0

func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print("Projectile collided with ", body.name)
	#print(body.get_coords_for_body_rid(body_rid))
	var tile_coords = body.get_coords_for_body_rid(body_rid)
	body.flash_tile(body.get_coords_for_body_rid(body_rid))
	var atlas_coords = body.get_cell_atlas_coords(tile_coords)
	
		
	var smoke = impact_smoke_scene.instantiate()
	smoke.global_position = global_position
	get_parent().add_child(smoke)
	
	visible = false
	$Area2D.set_deferred("monitoring",false)
	$Area2D.set_deferred("monitorable",false)
	
	#tree
	if(atlas_coords == Vector2i(0,0)):
		var cell_global_pos = body.to_global(body.map_to_local(tile_coords))
		await get_tree().create_timer(.7).timeout
		var log = log_scene.instantiate()
		log.global_position = cell_global_pos
		get_parent().add_child(log)
		body.erase_cell(tile_coords)
	queue_free()
