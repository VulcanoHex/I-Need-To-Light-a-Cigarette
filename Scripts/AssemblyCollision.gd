extends Area2D

var current_item: Area2D = null
var is_occupied: bool = false
@export var debugLabel: Label;

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if not is_occupied:
		current_item = area
		print("Item entered zone: ", area.name)

func _on_area_exited(area: Area2D) -> void:
	if current_item == area:
		current_item = null
		is_occupied = false
		print("Item left zone")

# Called by your dragged item on release - executes exactly once
func receive_drop(item: Area2D) -> bool:
	if current_item == item and not is_occupied:
		is_occupied = true
		print("Successfully dropped onto zone (Triggered once)!")
		debugLabel.text += "Aggiunta "+ item.item_name+ " nel panino!\n"
#		solo per testing
		var ob = $"../../../Control/OrderBoard"
		ob.spawn_order.emit({})
		
		
		item.global_position = global_position
		return true
	return false
