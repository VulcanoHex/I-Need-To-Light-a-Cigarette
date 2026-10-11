extends Area2D

# Dichiarazione del segnale per ripulire gli sprite impilati
signal clearIngredient

var current_item: Area2D = null

# Array locale che memorizza gli ordini in arrivo tramite il segnale
var active_order: Array[Dictionary] = []

@export var debugLabel: Label
@export var stack_offset_y: float = -15.0 

var stacked_count: int = 0

# Array per tracciare i nomi degli ingredienti attualmente inseriti nel panino
var current_sandwich_ingredients: Array[String] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	current_item = area

func _on_area_exited(area: Area2D) -> void:
	if current_item == area:
		current_item = null

# Chiamato dal tuo oggetto trascinato al rilascio
func receive_drop(item: Area2D) -> bool:
	if current_item == item:
		var ing_name = item.item_name if "item_name" in item else item.name
		print("Ingrediente aggiunto al panino: ", ing_name)
		
		# Aggiungiamo l'ingrediente alla lista locale del panino
		current_sandwich_ingredients.append(ing_name)
		
		if debugLabel:
			debugLabel.text += "Aggiunto: "+ ing_name + "\n"
		
		# --- GESTIONE GRAFICA DELLO STACK ---
		var source_sprite: Sprite2D = null
		for child in item.get_children():
			if child is Sprite2D:
				source_sprite = child
				break
		
		if source_sprite:
			var placed_sprite = source_sprite.duplicate() as Sprite2D
			add_child(placed_sprite)
			placed_sprite.position = Vector2(0, stacked_count * stack_offset_y)
			placed_sprite.show()
			clearIngredient.connect(placed_sprite.queue_free)
			stacked_count += 1
		
		current_item = null
		return true
		
	return false

# --- FUNZIONE DA COLLEGARE AL PULSANTE DI INVIO ---
func send_order() -> void:
	# Controlliamo se ci sono ordini attivi nel nostro array locale
	if active_order.size() == 0:
		print("Nessun ordine attivo da completare!")
		if debugLabel:
			debugLabel.text += "Nessun ordine in coda!\n"
		return
		
	# Prendiamo l'ordine in cima alla coda (il primo)
	var top_order = active_order[0]
	print("Controllo ordine in cima: ", top_order)
	
	# Verifichiamo se l'ordine contiene la chiave con la lista degli ingredienti
	if "ingredients" in top_order:
		var required_ingredients: Array = top_order.ingredients
		
		# Confrontiamo il panino assemblato con gli ingredienti richiesti
		if current_sandwich_ingredients == required_ingredients:
			print("Panino corretto! Ordine completato.")
			if debugLabel:
				debugLabel.text += "¡Ordine completato!\n"
			
			# Rimuoviamo il primo ordine dalla nostra coda locale
			active_order.pop_front()
			
			# Comunichiamo anche all'OrderBoard di rimuovere l'ordine visivo corrispondente
			var ob = $"../../../Control/OrderBoard"
			if ob:
				if ob.has_signal("remove_order"):
					ob.remove_order.emit()
				elif ob.has_method("complete_top_order"):
					ob.complete_top_order()
		else:
			print("Panino errato rispetto all'ordine in cima!")
			
			# Qui puoi aggiungere penalità o suoni di errore
			
	# A prescindere dall'esito (corretto o sbagliato), all'invio il tavolo/piatto viene pulito
	clear_sandwich()

# Funzione per pulire il panino e resettare il tavolo
func clear_sandwich() -> void:
	stacked_count = 0
	current_item = null
	current_sandwich_ingredients.clear()
	clearIngredient.emit()

# Riceve il nuovo ordine generato e lo aggiunge in coda nell'array locale
func _on_order_board_neword(curr_ord: Dictionary) -> void:
	active_order.append(curr_ord)
	print("Nuovo ordine ricevuto nell'Area2D. Ordini attivi in coda: ", active_order.size())
