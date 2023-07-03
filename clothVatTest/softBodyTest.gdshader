shader_type spatial;
render_mode  cull_disabled;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define VAT3MODE_SOFTBODY
#define VAT_OUTPUT_FULL
//#define NO_LERPING
//#define VAT_USE_COMPRESSED_NORMALS
uniform sampler2D normalmap : hint_normal;


	
#include "res://VAT3_GodotEngine/VAT3_Wraper.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;
	vertInputs.texCoord0 = UV;
	vertInputs.texCoord1 = UV2;
	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	float biNormalSign = round(dot( cross(TANGENT,NORMAL), BINORMAL));
	NORMAL = vatOutputs.outNormal.xyz ;
	TANGENT = vatOutputs.outTangent;
	BINORMAL = cross(TANGENT,NORMAL) * biNormalSign;
	UV = vatOutputs.surfaceUv;

	//UV = UV2;
	//COLOR = vatOutputs.outColorAndAlpha.xyz;
}

void fragment() {
	NORMAL_MAP = texture(normalmap, UV).rgb;
	ALBEDO = vec3(0.2,0.7,1.0);
	// Place fragment code here.
}
