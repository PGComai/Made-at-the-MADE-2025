extends Control

@export var text: String:
	set(value):
		if text != value:
			text = value
			if is_node_ready():
				label.text = text

@onready var label: Label = %Label

func _ready() -> void:
	label.text = text
