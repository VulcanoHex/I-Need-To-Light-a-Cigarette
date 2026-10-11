extends NinePatchRect

@onready var rich_text_label: RichTextLabel = $OrdDet

func setup_order(order_details: Dictionary) -> void:
	rich_text_label.text = order_details.get("text", "")
	
	# Attendiamo che Godot calcoli il rendering del testo
	await get_tree().process_frame
	
	# Calcoliamo l'altezza della label e aggiungiamo un margine sopra/sotto (es. 50 pixel totali)
	var content_height = rich_text_label.get_content_height()
	if content_height <= 0:
		content_height = rich_text_label.size.y # Fallback se get_content_height() dà 0
		
	var total_height = content_height + 50 
	
	# Impostiamo l'altezza sia come minimum size che come size effettiva
	custom_minimum_size.y = total_height
	size.y = total_height
