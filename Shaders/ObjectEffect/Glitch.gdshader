shader_type canvas_item;

uniform float intensity = 0.5;
uniform float scale: hint_range(0.1, 5.0, 0.01) = 1.0;

float random() {
    return fract(sin(TIME * 1000.0) * 43758.5453);
	}

void vertex() {
	vec2 glitchOffset = vec2(
		fract(sin(VERTEX.y * TIME ) * 43758.5453) * 4.0 - 2.0
		,fract(sin(VERTEX.x * TIME ) * 43758.5453) * 4.0 - 2.0);

	VERTEX += glitchOffset * vec2(intensity*5.0);

}

void fragment() {
	vec2 sUV = vec2(
		floor((UV.x*100.0)/scale)/100.0,
		floor((UV.y*100.0)/scale)/100.0
	);

	vec4 noiseValue = vec4(
						fract(sin(COLOR.x * sUV.x * sUV.y * TIME * 1000.0) * 43758.5453),
						fract(sin(COLOR.y * sUV.x * sUV.y * TIME * 1000.0) * 43758.5453),
						fract(sin(COLOR.z * sUV.x * sUV.y * TIME * 1000.0) * 43758.5453),
						COLOR.w
						);


	COLOR = (noiseValue * intensity) + (COLOR * (1.0 - intensity));
}
