extends NinePatchRect
class_name OrderBoard

@onready var sfxPlayer:AudioStreamPlayer = %SFXPlayer
const NEW_ORDER_SFX = preload("res://Assets/sounds/sfx/NewOrder.mp3")
signal neword
@export var order_scene: PackedScene
@export var order_spacing: float = 0.0
@export var max_orders: int = 5

# --- DATABASE DEGLI 8 INGREDIENTI ---
const INGREDIENTS = {
	"insalata": {"name": "Lettuce", "icon": "res://Assets/images/742f4016-7330-48c6-b490-fbda17b97ebd-Photoroom.png"},
	"pomodoro": {"name": "Tomatoes", "icon": "res://Assets/images/faf36078-4f3f-4468-8111-1ddb28f2c2d6-Photoroom.png"},
	"pickles": {"name": "Pickles", "icon": "res://Assets/images/bab89e96-f44d-41ea-adca-1f38e306b9e7-Photoroom.png"},
	"cipolla": {"name": "Onions", "icon": "res://Assets/images/5928c274-7ee5-44b7-9a48-27ffc921c476-Photoroom.png"},
	"mayo": {"name": "Mayo", "icon": "res://Assets/images/c7bc5e01-4614-4ae1-ac76-f4373a4e885a-Photoroom.png"},
	"ketchup": {"name": "Ketchup", "icon": "res://Assets/images/cff62b82-54ad-459f-a0e1-74bd3515d832-Photoroom.png"},
	"senape": {"name": "Senape", "icon": "res://Assets/images/f0ddf1a0-aea0-40cc-9cbd-f80b722bd884-Photoroom.png"},
	"burger_sauce": {"name": "Burger Sauce", "icon": "res://Assets/images/287484e4-2159-4bab-b7f9-ba9cb71f1b22-Photoroom.png"}
}

signal spawn_order(order_details: Dictionary)
signal remove_order()

var active_orders: Array[Control] = []

func _ready() -> void:
	spawn_order.connect(_on_spawn_order)
	remove_order.connect(_on_remove_order)

# --- FUNZIONE DI GENERAZIONE CASUALE ---
func generate_random_order() -> Dictionary:
	var keys = INGREDIENTS.keys()
	keys.shuffle()
	
	var num_items = randi_range(2, 8) # Sceglie da 2 a 4 ingredienti casuali
	var order_text = "[b]ORDER:[/b]\n"
	var order_data_array = []
	
	for i in range(num_items):
		var key = keys[i]
		var item = INGREDIENTS[key]
		
		# Aggiunge icona e nome formattati con BBCode
		order_text += "[img=32x32]%s[/img] %s\n" % [item["icon"], item["name"]]
		order_data_array.append(key)
		
	return {
		"text": order_text,
		"ingredients": order_data_array
	}

func _on_spawn_order(order_details: Dictionary) -> void:
	if not order_scene or active_orders.size() >= max_orders:
		return

	var new_order = order_scene.instantiate() as Control
	if not new_order:
		return
	add_child(new_order)

	new_order.size.x = size.x
	order_details = generate_random_order()
	if new_order.has_method("setup_order"):
		new_order.setup_order(order_details)
		
	if is_visible_in_tree():
		sfxPlayer.stream = NEW_ORDER_SFX
		sfxPlayer.play()
		
	
	var start_y = size.y + 100
	new_order.position = Vector2(10.0, start_y)
	active_orders.push_back(new_order)
	neword.emit(order_details)
	_animate_board_layout()

func _on_remove_order() -> void:
	if active_orders.is_empty():
		return

	var top_order = active_orders.pop_front()
	var remove_tween = create_tween()
	remove_tween.set_trans(Tween.TRANS_QUAD)
	remove_tween.set_ease(Tween.EASE_IN)
	remove_tween.tween_property(top_order, "position:y", top_order.position.y - 100, 0.3)
	remove_tween.parallel().tween_property(top_order, "modulate:a", 0.0, 0.3)
	remove_tween.tween_callback(top_order.queue_free)

	_animate_board_layout()

#func _animate_board_layout() -> void:
	#await get_tree().process_frame
	#
	#var tween = create_tween().set_parallel(true)
	#tween.set_trans(Tween.TRANS_QUAD)
	#tween.set_ease(Tween.EASE_OUT)
#
	#var current_y = 10.0
	#for i in range(active_orders.size()):
		#var order = active_orders[i]
		#tween.tween_property(order, "position:y", current_y, 0.35)
		#current_y += order.size.y + order_spacing
		
func _animate_board_layout() -> void:
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	var current_y = 10.0 # Margine dall'alto della bacheca
	for i in range(active_orders.size()):
		var order = active_orders[i]
		
		# Posiziona l'ordine verticalmente in sequenza
		tween.tween_property(order, "position:y", current_y, 0.35)
		
		# Avanza la Y della dimensione reale del biglietto corrente più un piccolo spazio costante (es. 15 pixel)
		current_y += order.size.y + 15
