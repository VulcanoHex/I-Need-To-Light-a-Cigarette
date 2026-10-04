extends NinePatchRect
class_name OrderBoard

@onready var sfxPlayer:AudioStreamPlayer = %SFXPlayer
const NEW_ORDER_SFX = preload("res://Assets/sounds/sfx/NewOrder.mp3")

@export var order_scene: PackedScene
@export var order_height: float = 90.0
@export var order_spacing: float = 10.0
@export var max_orders: int = 5

# Custom signals as requested
signal spawn_order(order_details: Dictionary)
signal remove_order()

# Tracks active order nodes currently on the board
var active_orders: Array[Control] = []

func _ready() -> void:
	# Connect signals to their respective handler functions
	spawn_order.connect(_on_spawn_order)
	remove_order.connect(_on_remove_order)

func _on_spawn_order(order_details: Dictionary) -> void:
	if not order_scene:
		printerr("Order Scene is not assigned in the inspector!")
		return

	if active_orders.size() >= max_orders:
		return # Board is full

	# 1. Instantiate the order (supporting Control or NinePatchRect roots)
	var new_order = order_scene.instantiate() as Control
	if not new_order:
		return

	if new_order.has_method("setup_order"):
		new_order.setup_order(order_details)
	
	sfxPlayer.stream = NEW_ORDER_SFX
	sfxPlayer.play()
	add_child(new_order)
	
	# Set initial size width to match board padding
	new_order.size.x = size.x - 20
	
	# Start position: Spawn just below the bottom of the board view
	var start_y = size.y + order_height
	var margin_x = 10.0
	new_order.position = Vector2(margin_x, start_y)
	
	# Add to our active list (newest orders are pushed to the back)
	active_orders.push_back(new_order)

	# 2. Animate all orders into their updated positions
	_animate_board_layout()

func _on_remove_order() -> void:
	if active_orders.is_empty():
		return

	# Remove the topmost order (index 0)
	var top_order = active_orders.pop_front()

	# Animate the removal of the topmost order (slides up and fades out)
	var remove_tween = create_tween()
	remove_tween.set_trans(Tween.TRANS_QUAD)
	remove_tween.set_ease(Tween.EASE_IN)
	remove_tween.tween_property(top_order, "position:y", top_order.position.y - 100, 0.3)
	remove_tween.parallel().tween_property(top_order, "modulate:a", 0.0, 0.3)
	remove_tween.tween_callback(top_order.queue_free)

	# Animate remaining orders shifting into their new positions
	_animate_board_layout()

func _animate_board_layout() -> void:
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# Layout orders so that index 0 is at the TOP, and newer orders stack downwards
	for i in range(active_orders.size()):
		var order = active_orders[i]
		
		# Index 0 gets the highest slot (closest to top = smaller Y value)
		# Subsequent items stack downwards by adding (order_height + order_spacing)
		var top_margin = 10.0 # Padding from the top of the board
		var target_y = top_margin + (i * (order_height + order_spacing))
		
		tween.tween_property(order, "position:y", target_y, 0.35)
