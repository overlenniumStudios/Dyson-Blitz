shader_type canvas_item;

uniform float r: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float g: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float b: hint_range(0.0, 1.0, 0.01) = 1.0;

// ORIGINAL SHADER FOR LIGHTNESS-CAPABLE GREYSCALE

void fragment() {
	COLOR = vec4(r, g, b, COLOR.w);
}
