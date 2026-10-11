extends Node2D 

signal its_over


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_area_cigarette_time_to_smoke() -> void:
	pass # Replace with function body.

func _on_go_to_kitchen_pressed() -> void:
	its_over.emit()
	pass
