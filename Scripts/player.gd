extends Node2D
@onready var kitchen = %Kitchen
@onready var smokeRoom = %SmokeRoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_go_to_smoke_button_pressed() -> void:
	# Disable inputs, processing and physics
	kitchen.process_mode = Node.PROCESS_MODE_DISABLED
	kitchen.visible = false
	smokeRoom.process_mode = Node.PROCESS_MODE_INHERIT
	smokeRoom.visible = true
	pass # Replace with function body.


func _on_go_to_kitchen_pressed() -> void:
	smokeRoom.process_mode = Node.PROCESS_MODE_DISABLED
	smokeRoom.visible = false
	kitchen.process_mode = Node.PROCESS_MODE_INHERIT
	kitchen.visible = true

	pass # Replace with function body.
