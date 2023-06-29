shader_type spatial;
//render_mode unshaded;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define _VAT3MODE_DYNAMICMESH




	
#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;

	vertInputs.texCoord0 =vec2(UV.x, UV.y);

	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz;
	TANGENT = vatOutputs.outTangent;

	//COLOR = vatOutputs.outColorAndAlpha.xyz;
}

void fragment() {
//vec2 test = UV;
	ALBEDO = COLOR.xyz;
	// Place fragment code here.
}
