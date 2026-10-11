extends NinePatchRect
class_name OrderBoard

@onready var sfxPlayer:AudioStreamPlayer = %SFXPlayer
const NEW_ORDER_SFX = preload("res://Assets/sounds/sfx/NewOrder.mp3")

@export var order_scene: PackedScene
@export var order_spacing: float = 0.0
@export var max_orders: int = 5

# --- DATABASE DEGLI 8 INGREDIENTI ---
const INGREDIENTS = {
	"insalata": {"name": "Insalata", "icon": "res://Assets/images/4ab9f1bb-725c-4edd-b880-3cf58599dafd-Photoroom.png"},
	"pomodoro": {"name": "Pomodoro", "icon": "res://Assets/images/57f4d7b2-2d7a-4203-a7f4-78b2b676bd67.png"},
	"pickles": {"name": "Pickles", "icon": "res://Assets/images/1i2iilgkbqda.png"},
	"cipolla": {"name": "Cipolla", "icon": "res://Assets/images/a3e02c66-3d8e-40f5-b889-d7ff81e779f1.png"},
	"mayo": {"name": "Mayo", "icon": "res://Assets/images/d31fc04b-68e1-4d7d-8ae7-093566d0ab85-Photoroom.png"},
	"ketchup": {"name": "Ketchup", "icon": "res://Assets/images/cff62b82-54ad-459f-a0e1-74bd3515d832-Photoroom.png"},
	"senape": {"name": "Senape", "icon": "res://Assets/images/67c38807-3457-4143-aa14-3b1b288d3b71-Photoroom.png"},
	"burger_sauce": {"name": "Burger Sauce", "icon": "res://Assets/images/35aa6550-718d-48ee-9c16-55899250783d-Photoroom.png"}
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
	
	var num_items = randi_range(2, 4) # Sceglie da 2 a 4 ingredienti casuali
	var order_text = "[b]ORDINE:[/b]\n"
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

	new_order.size.x = size.x - 20
	order_details = generate_random_order()
	if new_order.has_method("setup_order"):
		new_order.setup_order(order_details)
		
	if is_visible_in_tree():
		sfxPlayer.stream = NEW_ORDER_SFX
		sfxPlayer.play()
		
	
	var start_y = size.y + 100
	new_order.position = Vector2(10.0, start_y)
	active_orders.push_back(new_order)

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
	await get_tree().process_frame
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	var current_y = 10.0
	for i in range(active_orders.size()):
		var order = active_orders[i]
		
		# Muove il biglietto alla posizione Y calcolata
		tween.tween_property(order, "position:y", current_y, 0.35)
		
		# Aggiunge l'altezza reale del biglietto corrente + lo spazio tra un ordine e l'altro
		current_y += order.size.y + order_spacing
