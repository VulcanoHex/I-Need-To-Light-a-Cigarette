extends Area2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
@onready var item_name: String = "Sborra"

func _ready() -> void:
	# Ensure the Area2D can detect mouse clicks
	input_pickable = true

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			# Save the current position as the start position before moving
			start_position = global_position
			drag_offset = global_position - get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if not is_dragging:
		return

	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		
		var dropped_on_target = false
		for area in get_overlapping_areas():
			if area.has_method("receive_drop"):
				if area.receive_drop(self):
					dropped_on_target = false
					break
		
		if not dropped_on_target:
			global_position = start_position
