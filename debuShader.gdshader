shader_type spatial;
render_mode unshaded;

uniform sampler2D testTex;
void fragment() {
	vec4 test=  textureLod(testTex,UV,0);
	ALBEDO =test.b > 0.9 ? vec3(1.0, 1.0, 1.0) : vec3(0.0,0.0,0.0);
}
