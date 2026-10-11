extends Area2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
@onready var item_name: String = get_parent().name
var drop_sprite: Sprite2D


func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			drop_sprite = child
			break
	
	# Ensure the Area2D can detect mouse clicks
	input_pickable = true

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_dragging:
			is_dragging = true
			drop_sprite.show()
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
		var target_area = null
		
		for area in get_overlapping_areas():
			if area.has_method("receive_drop"):
				target_area = area
				if area.receive_drop(self):
					dropped_on_target = true
					break
		
		if dropped_on_target and target_area:
			# 1. Spawn a permanent copy of the sprite inside the drop zone
			var placed_sprite = drop_sprite.duplicate() as Sprite2D
			target_area.add_child(placed_sprite)
			placed_sprite.global_position = global_position
			placed_sprite.show()
			
			# 2. Connect to the drop zone's clearIngredient signal to clean itself up later
			if target_area.has_signal("clearIngredient"):
				target_area.clearIngredient.connect(placed_sprite.queue_free)
			
			# 3. Snap the original item back to its start position and hide it
			global_position = start_position
			drop_sprite.hide()
			placed_sprite.hide()
		else:
			# Failed drop: snap back and hide
			global_position = start_position
			drop_sprite.hide()
