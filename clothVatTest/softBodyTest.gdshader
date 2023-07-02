shader_type spatial;
render_mode  cull_disabled;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define VAT3MODE_SOFTBODY
uniform sampler2D normalmap : hint_normal;


	
#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;
	vertInputs.texCoord0 = UV;
	vertInputs.texCoord1 = UV2;
	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz ;
	TANGENT = vatOutputs.outTangent;
	BINORMAL = cross(TANGENT,NORMAL);

	//UV = UV2;
	//COLOR = vatOutputs.outColorAndAlpha.xyz;
}

void fragment() {
	NORMAL_MAP = texture(normalmap, UV).rgb;
	ALBEDO = vec3(0.2,0.7,1.0);
	// Place fragment code here.
}
