extends Area2D

@export var speed_req: float = 300.0  
@export var heat_req: float = 100.0
@export var speed_max: float = 1200.0
@export var cooling_speed: float = 40.0
@export var time_to_consume: float = 2.0
@export var floor_y: float = 1100.0 

@onready var area_capocchia: CollisionShape2D = $CollisionCapocchia
@onready var area_strip: Area2D = $"../../Strip/AreaStrip"

enum State { SPENTO, ROTTO, ACCESO, CONSUMATO }
var curr_state: State = State.SPENTO

var is_dragging: bool = false
var is_falling: bool = false
var velocity_y: float = 0.0
var drag_offset: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO

var last_position: Vector2 = Vector2.ZERO
var current_heat: float = 0.0
var is_rubbing: bool = false
var burn_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = global_position
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if not is_dragging or is_falling:
		return

	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
			
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		is_falling = true
		
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_falling:
			is_dragging = true
			# Save the current position as the start position before moving
			start_position = global_position
			drag_offset = global_position - get_global_mouse_position()
			
func _process(delta: float) -> void:
	if is_falling:
		# Applica l'accelerazione di gravità
		velocity_y += gravity * delta
		global_position.y += velocity_y * delta
		
		# Quando tocca il pavimento (o supera floor_y), esegui il reset
		if global_position.y >= floor_y:
			reset_match()
	var current_velocity = (global_position - last_position).length() / delta
	last_position = global_position

	# 2. MACCHINA A STATI
	match curr_state:
		State.SPENTO:
			if is_rubbing and is_dragging:
				_handle_rubbing(current_velocity, delta)
			else:
				# Dissipa il calore se smetti di strofinare
				current_heat = max(0.0, current_heat - cooling_speed * delta)

		State.ROTTO:
			# Il fiammifero è spezzato: cade subito dalla mano
			if is_dragging:
				is_dragging = false
				is_falling = true

		State.ACCESO:
			# Avanza il timer di combustione
			burn_timer += delta
			if burn_timer >= time_to_consume:
				change_state(State.CONSUMATO)

		State.CONSUMATO:
			# Il fiammifero è del tutto bruciato
			pass
			
func _handle_rubbing(speed: float, delta: float) -> void:
	# TROPPO VELOCE -> Transizione a ROTTO
	if speed > speed_max:
		print("Troppo veloce! Il fiammifero si è rotto.")
		change_state(State.ROTTO)
		return

	# TROPPO LENTO -> Il calore non basta o si dissipa
	if speed < speed_req:
		current_heat = max(0.0, current_heat - cooling_speed * delta)
		return

	# VELOCITÀ CORRETTA -> Accumula calore
	current_heat += (speed / speed_req) * 50.0 * delta
	print("Strofino... Calore attuale: ", current_heat)

	if current_heat >= heat_req:
		print("Acceso!")
		change_state(State.ACCESO)
		
func change_state(new_state: State) -> void:
	curr_state = new_state
	
	match curr_state:
		State.SPENTO:
			current_heat = 0.0
			burn_timer = 0.0
		State.ROTTO:
			# Qui inserirai l'animazione/sprite del fiammifero spezzato
			pass
		State.ACCESO:
			burn_timer = 0.0
			# Qui attiverai le particelle del fuoco ed il suono dell'innesco
		State.CONSUMATO:
			# Qui spegnerai il fuoco lasciando lo sprite annerito/fumo
			pass

func _on_area_entered(area: Area2D) -> void:
	# Confronto diretto con il nodo referenziato
	if area == area_strip:
		print("im in")
		is_rubbing = true

func _on_area_exited(area: Area2D) -> void:
	if area == area_strip:
		print("fuck this shit im out")
		is_rubbing = false

func reset_match() -> void:
	is_falling = false
	is_dragging = false
	velocity_y = 0.0
	global_position = start_position
	change_state(State.SPENTO)
