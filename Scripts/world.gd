extends Node2D

const DEFAULT_CURSOR = preload("res://Assets/images/ui/cursor_normal.png")
const DRAG_CURSOR = preload("res://Assets/images/ui/cursor_drag.png")
const HOTSPOT = Vector2(0, 0) # Adjust based on where the click point is on your texture

var is_dragging: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(DEFAULT_CURSOR, Input.CURSOR_ARROW, HOTSPOT)
	Input.set_custom_mouse_cursor(DRAG_CURSOR, Input.CURSOR_DRAG, HOTSPOT)
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Change to clicked cursor (Optional: add Vector2 hotspot and shape parameters)
			Input.set_custom_mouse_cursor(DRAG_CURSOR)
		else:
			# Revert back to the normal cursor when released
			Input.set_custom_mouse_cursor(DEFAULT_CURSOR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
