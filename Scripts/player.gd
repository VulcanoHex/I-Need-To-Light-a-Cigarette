extends Node2D
@onready var kitchen = %Kitchen
@onready var smokeRoom = %SmokeRoom
@onready var orderBoard = %OrderBoard
@export var startingOrderWaitSeconds: float = 1.2;
@export var decayRatePerOrder: float = 0.1;
# High (10): more consistent, Low (1): more unpredictable 1 is poisson
@export var orderShapeVariance: int = 7


signal startSendingOrders
signal stopSendingOrders

var running: bool = false
var stopSending: bool = false
var avg_wait: float;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avg_wait = startingOrderWaitSeconds
	
#	Remove before flight
	startSendingOrders.emit()
	await get_tree().create_timer(10).timeout
	stopSendingOrders.emit()
#	Remove before flight
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# something something poisson is shit i need some ERLANG distribution type shi
func make_orders() -> void:
	var wait_time: float = get_next_time_interval(avg_wait)
	print("Waiting for: ", snappedf(wait_time, 0.01), "s (Current Avg Target: ", snappedf(avg_wait, 0.01), "s)")
	await get_tree().create_timer(abs(wait_time)).timeout
	# flag hai perso va qui
	if(!stopSending):
		send_order()
	pass 

func send_order() -> void:
	#send order
	print("sentorder")
	orderBoard.spawn_order.emit({})
	if(avg_wait > 1.0):
		avg_wait -= decayRatePerOrder
	make_orders()

func get_next_time_interval(avg: float) -> float:
	var scale: float = avg/float(orderShapeVariance)
	var totalTime: float = 0.0
	
	for i in range(orderShapeVariance):
		var u:float = randf()
		while u == 0.0:
			u = randf()
		totalTime += -scale * log(u)
	#	-ln(x) * avg = t in poisson distribution
	return totalTime

func _on_go_to_smoke_button_pressed() -> void:
	# Disable inputs, processing and physics
	kitchen.process_mode = Node.PROCESS_MODE_DISABLED
	kitchen.visible = false
	smokeRoom.process_mode = Node.PROCESS_MODE_INHERIT
	smokeRoom.visible = true
	pass # Replace with function body.


func _on_go_to_kitchen_pressed() -> void:
	smokeRoom.process_mode = Node.PROCESS_MODE_DISABLED
	smokeRoom.visible = false
	kitchen.process_mode = Node.PROCESS_MODE_INHERIT
	kitchen.visible = true

	pass # Replace with function body.


func _on_stop_sending_orders() -> void:
	stopSending = true
	running = false
	pass # Replace with function body.


func _on_start_sending_orders() -> void:
	if(!running):
		stopSending = false
		make_orders()
	running = true
	pass # Replace with function body.
