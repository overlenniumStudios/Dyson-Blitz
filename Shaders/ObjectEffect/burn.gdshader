shader_type canvas_item;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D noise3: repeat_enable;

uniform float timeScale = 0.1;
uniform float intensity = 0.2;

uniform float cutoff = 0.4;
uniform float test = 0.1;

// Add a uniform for pixelation
uniform float pixelSize = 8.0; // Size of the pixelation blocks

void fragment() {
    // Pixelation: Adjust UVs to create blocky sampling
    vec2 pixelatedUV = floor(UV * pixelSize) / pixelSize;

    // Use the pixelated UV for texture sampling
    float intensity1 = texture(noise1, pixelatedUV + TIME * timeScale).r;
    float intensity2 = texture(noise2, pixelatedUV + TIME * -timeScale).r;
    float intensity3 = texture(noise3, pixelatedUV + TIME * vec2(timeScale, -timeScale)).r;

    float energy = (intensity1 + intensity2 + intensity3) / 3.0;
    vec4 noise = vec4(intensity, intensity, intensity, 0.0);

    if (energy > intensity) {
        COLOR = COLOR - (noise - vec4(test, test, test, 0.0));
    } else if (energy > intensity - cutoff) {
        float flameintensity = pow(2.0, ((energy - intensity + cutoff / 10.0) * 100.0));
        COLOR.x = COLOR.x + flameintensity * 10.0;
        COLOR.y = COLOR.y + flameintensity / 20.0;
        COLOR.z = COLOR.z - flameintensity;
        COLOR.w = COLOR.w;
    }
}
