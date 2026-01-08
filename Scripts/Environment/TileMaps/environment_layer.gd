extends TileMapLayer

var modulated_cells = {
	"hi": 1.0
}

var tile_animations = {}
var animating_tiles := false

func _process(delta: float) -> void:
	if tile_animations.size() > 0:
		notify_runtime_tile_data_update()
		
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	var coords_as_string = "(%s,%s)" % [coords.x,coords.y]
	return modulated_cells.has(coords_as_string)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	var coords_as_string = "(%s,%s)" % [coords.x,coords.y]
	tile_data.modulate = modulated_cells.get(coords_as_string, Color.WHITE)
	
func flash_tile(coords: Vector2i):
	# add coords to dictionary of modulated_cells
	var coords_as_string = "(%s,%s)" % [coords.x,coords.y]
	var from_color = Color(1.0,1.0,1.0,1.0)
	modulated_cells[coords_as_string] = from_color
	# reference that key for color tween
	#var dict_prop = "modulated_cells:Vector2i(%s,%s)" % [coords.x,coords.y]
	var dict_prop = "modulated_cells:(%s,%s)" % [coords.x,coords.y]
	var to_color = Color.from_hsv(.0,.0,20.0)
	var tween_color = get_tree().create_tween()
	tween_color.tween_property(self, dict_prop, to_color, .2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tile_animations[coords] = true
	await get_tree().create_timer(.2).timeout
	var tween_color_back = get_tree().create_tween()
	tween_color_back.tween_property(self, dict_prop, from_color, .2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(.3).timeout
	tile_animations.erase(coords)
	modulated_cells.erase(coords_as_string)
	
