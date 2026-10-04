extends Node2D 

signal its_over

@onready var nBar = $"../NicotineBar"
@onready var pBar = $TempBar

# max number of smokes (non so come si dice tiro in inglese)
@export var tiri_max = 5
# total efficiency of a cigarette
@export var cig_eff = 50.0
# maximum efficiency of a smoke (guarda su)
@export var max_eff = cig_eff / tiri_max
# max time for a smoke (min_max is in the middle, at max u cough)
@export var max_smoke = 5.0

var tempo_tiro = 0.0
var inspira = false
var tiri_fatti = 0
var progress = 0
var is_lighted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calcola_parabola(t: float, durata: float, picco: float) -> float:
	if durata <= 0.0 or t >= max_smoke:
		return 0.0
	
	# Normalizza il tempo tra 0.0 e 1.0
	var x: float = t / durata
	
	# Formula della parabola normalizzata: 4 * x * (1 - x)
	# Vale 0 quando x=0, sale a 1 quando x=0.5, torna a 0 quando x=1
	return 4.0 * picco * x * (1.0 - x)

# Funzione per l'andamento triangolare/lineare
func calcola_triangolo(t: float, durata: float, picco: float) -> float:
	if durata <= 0.0 or t >= max_smoke:
		return 0.0
	
	# Normalizza il tempo tra 0.0 e 1.0
	var x: float = t / durata
	
	# Formula triangolare: 
	# Se x < 0.5 sale linearmente con pendenza 2 (da 0 a 1)
	# Se x >= 0.5 scende linearmente con pendenza -2 (da 1 a 0)
	var fattore_lineare: float = 1.0 - abs(2.0 * x - 1.0)
	
	return picco * fattore_lineare
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_lighted:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if not inspira:
				pBar.value = nBar.value
				inspira = true
			tempo_tiro += delta
			# pBar.value += tempo_tiro
			progress = calcola_triangolo(tempo_tiro, max_smoke, max_eff)
			pBar.value = nBar.value + progress
			
			#print("stai tirando da: ", "%.2f" % tempo_tiro, "s")
		elif inspira:
			inspira = false
			print("progress: ", progress)
			nBar.value = pBar.value
			tempo_tiro = 0
			tiri_fatti += 1
			print("hai fatto ", tiri_fatti, " tiri")
			if tiri_fatti == tiri_max:
				is_lighted = false
				tiri_fatti = 0
				pBar.value = 0.0
				its_over.emit()
		pass


func _on_area_cigarette_time_to_smoke() -> void:
	is_lighted = true
	pass # Replace with function body.


func _on_go_to_kitchen_pressed() -> void:
	is_lighted = false
	tiri_fatti = 0
	pBar.value = 0.0
	its_over.emit()
	pass
