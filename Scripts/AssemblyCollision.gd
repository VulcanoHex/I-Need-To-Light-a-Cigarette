extends Area2D

# Declare the signal so stacked sprites can clean themselves up
signal clearIngredient

var current_item: Area2D = null

@export var debugLabel: Label
@export var stack_offset_y: float = -15.0 # Editable in the Inspector (positive or negative depending on stack direction)

var stacked_count: int = 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	current_item = area
	print("Item entered zone: ", area.name)

func _on_area_exited(area: Area2D) -> void:
	if current_item == area:
		current_item = null
		print("Item left zone")

# Called by your dragged item on release - allows multiple drops
func receive_drop(item: Area2D) -> bool:
	if current_item == item:
		print("Successfully dropped onto zone!")
		if debugLabel:
			debugLabel.text += "Aggiunta "+ item.item_name+ " nel panino!\n"
		
		# solo per testing
		var ob = $"../../../Control/OrderBoard"
		if ob and ob.has_signal("remove_order"):
			ob.remove_order.emit()
		
		# Find the sprite inside the dragged item
		var source_sprite: Sprite2D = null
		for child in item.get_children():
			if child is Sprite2D:
				source_sprite = child
				break
		
		if source_sprite:
			# Duplicate the sprite and add it as a child of this drop zone
			var placed_sprite = source_sprite.duplicate() as Sprite2D
			add_child(placed_sprite)
			
			# Position locally using the stacked count and editable Y offset
			placed_sprite.position = Vector2(0, stacked_count * stack_offset_y)
			placed_sprite.show()
			
			# Connect to clearIngredient to auto-delete when cleared
			clearIngredient.connect(placed_sprite.queue_free)
			
			# Increment the stack count for the next item
			stacked_count += 1
		
		# Clear current_item so it doesn't double-trigger on the same drop action
		current_item = null
		return true
		
	return false

# Call this function from your game manager/order board when clearing the sandwich
func clear_sandwich() -> void:
	stacked_count = 0
	current_item = null
	clearIngredient.emit()
