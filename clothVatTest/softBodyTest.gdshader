shader_type spatial;
render_mode  cull_disabled;
#define VAT3MODE_SOFTBODY
#include "res://VAT3_GodotEngine/VAT3_Wraper.gdshaderinc"
uniform sampler2D normalmap : hint_normal;



void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;
	vertInputs.texCoord0 = UV;
	vertInputs.texCoord1 = UV2;
	Vat3_NonTexInputs nonTexInputs = GetVat3Inputs(vertInputs); // get material inputs
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs); // apply ob object space
    VERTEX = vatOutputs.outPosition.xyz;
	float biNormalSign = round(dot( cross(TANGENT,NORMAL), BINORMAL));
	NORMAL = vatOutputs.outNormal.xyz ;
	TANGENT = vatOutputs.outTangent;
	BINORMAL = cross(TANGENT,NORMAL) * biNormalSign;
	UV = vatOutputs.surfaceUv;
}

void fragment() {
	NORMAL_MAP = texture(normalmap, UV).rgb;
	ALBEDO = vec3(0.2,0.7,1.0);
}
