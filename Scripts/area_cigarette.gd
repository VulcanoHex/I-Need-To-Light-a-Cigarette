extends Area2D

var lighted = false
var on_fire = false
var match_state = false
var time_of = 0.0

@export var cig_texture: Texture2D
@export var cig_lighted_texture: Texture2D

@onready var splite_cig: Sprite2D = $textCig

signal time_to_smoke

@export var time_to_light = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if on_fire and match_state:
		if time_of < time_to_light:
			time_of += delta
		else:
			lighted = true
			splite_cig.texture = cig_lighted_texture
			on_fire = false
			print("sono accesa")
	else:
		if time_of > 0 and not lighted:
			time_of -= delta
		else:
			time_of = 0.0
	pass

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print(area)
	if not lighted:
		on_fire = true
	pass

func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("im out")
	if not lighted:
		on_fire = false
	pass

func _on_area_match_im_fine() -> void:
	match_state = true
	pass # Replace with function body.

func _on_area_match_skill_issue() -> void:
	match_state = false
	pass # Replace with function body.
