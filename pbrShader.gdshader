shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D noise;


void vertex() {
	vec2 coords = VERTEX.xz / 2.0 ;
	coords.x += TIME*0.1;
	float height = texture(noise, coords).x; //divide by the size of the PlaneMesh
VERTEX.z += sin(TIME);

}

void fragment() {
	// Place fragment code here.
}
