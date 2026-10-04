extends Area2D

var lighted = false
var on_fire = false
var time_of = 0.0

signal time_to_smoke

@export var time_to_light = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if on_fire:
		if time_of < time_to_light:
			time_of += delta
		else:
			lighted = true
			on_fire = false
			print("sono accesa")
			time_to_smoke.emit()
	else:
		if time_of > 0 and not lighted:
			time_of -= delta
		else:
			time_of = 0.0
	pass

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("im in")
	if not lighted:
		on_fire = true
	pass

func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("im out")
	if not lighted:
		on_fire = false
	pass

func _on_smoke_room_its_over() -> void:
	lighted = false
	pass
