shader_type spatial;
//render_mode unshaded;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define VAT3MODE_RIGIDBODY
#define VAT_SMOOTH_TRAJECTORIES



	
#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;
	vertInputs.vertexNormal = NORMAL;
	vertInputs.vertexTangent = TANGENT;
	vertInputs.texCoord0 =UV;
	vertInputs.texCoord1 = UV2;
	//vertInputs.texCoord2 = CUSTOM0.xy;

	vertInputs.texCoord2 =CUSTOM0.xy;
	vertInputs.texCoord3 = CUSTOM0.zw;
	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz;
	TANGENT = vatOutputs.outTangent;

	UV = clamp(	vertInputs.texCoord3.xy,vec2(0.0,0.0),vec2(1.0, 1.0));
	//COLOR = vatOutputs.outColorAndAlpha.xyz;
}

void fragment() {
//vec2 test = UV;
	ALBEDO = COLOR.xyz;
	// Place fragment code here.
}
