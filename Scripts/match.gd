extends Area2D

signal im_fine
signal skill_issue

@export var speed_req: float = 300.0  
@export var heat_req: float = 120.0
@export var speed_max: float = 1500.0
@export var speed_extinguish: float = 1300.0
@export var cooling_speed: float = 40.0
@export var time_to_consume: float = 4.0
@export var grav: float = 1200.0
@export var floor_y: float = 1100.0
@export var max_match: int = 5

@export_group("Textures Fiammifero")
@export var off_match: Texture2D 
@export var on_match: Texture2D 
@export var broke_match: Texture2D 
@export var consumedv1_match: Texture2D 
@export var consumedv2_match: Texture2D

@onready var area_capocchia: CollisionShape2D = $CollisionCapocchia
@onready var area_strip: Area2D = $"../../Strip/AreaStrip"
@onready var target_shape: CollisionPolygon2D = $"../../Strip/AreaStrip/CollisionStrip"
@onready var splite_match: Sprite2D = $SpriteMatch
@onready var matches_counter: RichTextLabel = $"../../Counter" 

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
var curr_match: int = 0

func _ready() -> void:
	# Mantiene memorizzata SOLO la posizione iniziale della scena
	start_position = global_position
	last_position = global_position
	curr_match = max_match
	
	matches_counter.text = str(curr_match)
	
	area_shape_entered.connect(_on_area_shape_entered)
	area_shape_exited.connect(_on_area_shape_exited)

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
		if event.pressed and not is_falling and curr_state != State.ROTTO and curr_state != State.CONSUMATO:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()

func _process(delta: float) -> void:
	if is_falling:
		velocity_y += grav * delta
		global_position.y += velocity_y * delta
		
		if global_position.y >= floor_y:
			reset_match()
		return

	var current_velocity = (global_position - last_position).length() / delta
	last_position = global_position

	match curr_state:
		State.SPENTO:
			splite_match.texture = off_match
			if is_rubbing and is_dragging:
				_handle_rubbing(current_velocity, delta)
			else:
				current_heat = max(0.0, current_heat - cooling_speed * delta)

		State.ROTTO:
			splite_match.texture = broke_match
			if is_dragging:
				is_dragging = false
				is_falling = true

		State.ACCESO:
			if burn_timer == 0:
				im_fine.emit()
				splite_match.texture = on_match
				
			if is_dragging and current_velocity > speed_extinguish:
				print("Spostamento troppo rapido! Il fiammifero si è spento.")
				change_state(State.CONSUMATO)
				return
			
			burn_timer += delta
			if burn_timer >= time_to_consume/2:
				splite_match.texture = consumedv1_match
			if burn_timer >= time_to_consume:
				change_state(State.CONSUMATO)

		State.CONSUMATO:
			skill_issue.emit()
			splite_match.texture = consumedv2_match
			pass

func _handle_rubbing(speed: float, delta: float) -> void:
	if speed > speed_max:
		print("Troppo veloce! Il fiammifero si è rotto.")
		change_state(State.ROTTO)
		return

	if speed < speed_req:
		current_heat = max(0.0, current_heat - cooling_speed * delta)
		return

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
			pass
		State.ACCESO:
			burn_timer = 0.0
		State.CONSUMATO:
			pass

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == area_strip:
		# Verifichiamo che la collisione sia avvenuta proprio tra CollisionCapocchia e CollisionStrip
		var local_shape = shape_owner_get_owner(shape_find_owner(local_shape_index))
		var hit_shape = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index))
		
		if local_shape == area_capocchia and hit_shape == target_shape:
			print("Capocchia a contatto con la striscia!")
			is_rubbing = true

func _on_area_shape_exited(_area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == area_strip:
		var local_shape = shape_owner_get_owner(shape_find_owner(local_shape_index))
		var hit_shape = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index))
		
		if local_shape == area_capocchia and hit_shape == target_shape:
			print("Capocchia ha staccato la striscia!")
			is_rubbing = false

func reset_match() -> void:
	curr_match -= 1
	matches_counter.text = str(curr_match)
	if curr_match == 0:
		print("skill issue bro")
		#inserisci roba per tornare alla cucina
	change_state(State.SPENTO)
	is_falling = false
	is_dragging = false
	is_rubbing = false
	velocity_y = 0.0
	global_position = start_position
