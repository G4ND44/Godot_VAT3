shader_type spatial;
render_mode unshaded;

uniform sampler2D testTex: filter_nearest, repeat_disable;
void fragment() {
	vec4 tex =  textureLod(testTex,UV,0);
	bool toggle = false;
	float stepper = toggle ? 2048.0f : 255.0f; 
	vec3 test=  tex.x> 1.0? vec3(1.0, 1.0, 1.0) : vec3(0.0,0.0,0.0);
	//vec3 test =  (tex.ggg);
	ALBEDO =  test;
}
