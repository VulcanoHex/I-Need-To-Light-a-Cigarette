extends ColorRect

@export var max_radius: float = 1.0
@export var MAX_DIP:float = 50.0
@onready var nicotineBar: TextureProgressBar = %NicotineBar
var active_tween: Tween
var is_tweening: bool = false

func _ready() -> void:
	# 1. Listen for any changes to nicotinebar.value
	nicotineBar.value_changed.connect(_on_nicotine_bar_value_changed)
	
	# Example: Start the 60-second transition right away
	start_dipendenza()

func start_dipendenza() -> void:
	# Kill any existing tween to avoid overlapping animations
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween()
	is_tweening = true
	# Animate 'value' property of nicotinebar to 80.0 over 60 seconds
	active_tween.tween_property(nicotineBar, "value", MAX_DIP, 5.0)
	
	# Optional: Execute code when the 60 seconds/animation finishes

	active_tween.finished.connect(func(): 
		is_tweening = false
		print("Reached maxDipendenza and stopped!"))

# This function automatically triggers whenever nicotinebar.value changes
func _on_nicotine_bar_value_changed(new_value: float) -> void:
	if (not is_tweening):
		print("Nicotine bar value changed to: ", new_value)
		# Put any custom logic here that needs to respond when the value changes
		if (new_value < MAX_DIP):
			start_dipendenza()

func _process(_delta: float) -> void:
	# Keep aspect ratio synced to window size changes
	var viewport_size = get_viewport_rect().size
	var aspect = viewport_size.x / viewport_size.y
	material.set_shader_parameter("aspect_ratio", aspect)
	
	# Assuming %Variable is a unique node in your scene tree with a property (e.g., .value)
	# Adjust the property name based on your specific script setup:
	var current_value = nicotineBar.value
	#print("nicotine "+str(nicotineBar.value))
	
	# Map your variable to the shader radius. 
	# If your variable starts at 0 (fully transparent), set it accordingly:
	var mapped_radius = remap(current_value, 0.0, 100.0, max_radius, 0.0)
	
	material.set_shader_parameter("opening_radius", mapped_radius)
