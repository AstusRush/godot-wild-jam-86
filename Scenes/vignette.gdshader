shader_type canvas_item;

uniform float b : hint_range(0.0, 1.0, 0.01);
uniform float maxA : hint_range(0.0, 1.0, 0.01);
uniform float p;

void fragment() {
	float dist=length(UV-vec2(0.5,0.5));
	dist=smoothstep(0.3,0.5,dist);
	float f = pow(dist,p);
	f*=b*maxA;
	COLOR.a = f;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
