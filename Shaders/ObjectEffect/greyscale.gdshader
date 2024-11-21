shader_type canvas_item;

uniform float lightness: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float intensity: hint_range(0.0, 1.0, 0.01) = 1.0;

// ORIGINAL SHADER FOR LIGHTNESS-CAPABLE GREYSCALE

void fragment() {
	float brightness = (COLOR.x + COLOR.y + COLOR.z)/3.0;
	
	vec4 grayscaledColor = vec4(brightness, brightness, brightness, COLOR.w) * vec4(intensity);
	
	COLOR = ((COLOR * vec4(1.0-intensity)) + grayscaledColor) * vec4(lightness, lightness, lightness, 1.0);
	
}
