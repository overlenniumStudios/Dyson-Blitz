shader_type canvas_item;

uniform float seed = 178643;
uniform float scale = 1000;

uniform float starchance = 0.99;

void fragment() {
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE.xy;
	float random_val = fract(sin(dot(uv / vec2(scale,scale), vec2(12.9898, 78.233))) * seed);
	
	if (random_val > starchance) {
		COLOR = vec4(random_val/4.0,random_val/7.0,random_val/4.0,1.0);
	} else {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
	}