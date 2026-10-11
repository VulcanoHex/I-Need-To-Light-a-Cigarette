extends NinePatchRect

@onready var rich_text_label: RichTextLabel = $OrdDet

func _ready() -> void:
	# Colleghiamo il segnale di cambio dimensione del padre (resized)
	resized.connect(_on_parent_resized)

func setup_order(order_details: Dictionary) -> void:

	rich_text_label.text = order_details.get("text", "")
	
	# Attendiamo un frame per calcolare l'altezza del testo con le immagini
	await get_tree().process_frame
	
	var content_height = rich_text_label.get_content_height()
	if content_height <= 0:
		content_height = 60
		
	# Scaliamo l'altezza del NinePatchRect in proporzione al contenuto + padding
	var final_height = content_height + 40
	custom_minimum_size.y = final_height
	size.y = final_height
	
	# Aggiorniamo anche la label in proporzione
	_update_label_proportions()

func _on_parent_resized() -> void:
	_update_label_proportions()

func _update_label_proportions() -> void:
	if not rich_text_label:
		return
		
	# Definiamo i margini proporzionali (es. 15% a sinistra e a destra rispetto alla larghezza del padre)
	var margin_x = size.x * 0.12 # 12% di margine laterale
	var margin_y = 100.0          # Margine verticale fisso dall'alto
	
	# Impostiamo la posizione X e la larghezza in proporzione alla taglia del NinePatchRect
	rich_text_label.position.x = margin_x
	rich_text_label.position.y = margin_y
	rich_text_label.size.x = size.x - (margin_x * 2)
