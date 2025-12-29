extends Line2D
class_name TireMark


const SKID_TEX = preload("uid://cbudoc5l7qh1e")


func _ready() -> void:
	z_index = 1
	top_level = true
	global_position = Vector2.ZERO
	default_color = Color.BLACK
	default_color.a = 0.4
	width = 4
	#texture = SKID_TEX
	#texture_mode = Line2D.LINE_TEXTURE_STRETCH
