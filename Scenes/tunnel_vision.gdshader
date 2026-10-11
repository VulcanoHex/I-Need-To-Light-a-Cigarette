shader_type canvas_item;

uniform float opening_radius : hint_range(0.0, 2.0) = 2.0; 
uniform float smoothness : hint_range(0.0, 1.5) = 0.5; // Increased range and default for a softer fade
uniform float aspect_ratio = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Center the UV coordinates at (0.5, 0.5) before scaling aspect ratio
    vec2 centered_uv = uv - 0.5;
    centered_uv.x *= aspect_ratio;
    
    float dist = length(centered_uv);
    
    // Create a wide, soft transition between the center and the black border
    float alpha = smoothstep(opening_radius, opening_radius + smoothness, dist);
    
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}