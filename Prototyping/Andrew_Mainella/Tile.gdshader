shader_type canvas_item;



void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec3 in_color;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV - 0.5;
	float d = length(uv);
	float c = smoothstep(0.05, 0.95, d);
	COLOR = vec4(in_color, (1.0-c));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
