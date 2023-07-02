shader_type spatial;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define VAT3MODE_DYNAMICMESH
#define VAT_LOAD_COL_TEX

#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;

	vertInputs.texCoord0 =vec2(UV.x, UV.y);

	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
	//nonTexInputs.boundMax = vec3( 6.070000171661377, 3.299999952316284, 5.550000190734863);
	//	nonTexInputs.boundMin = vec3(  -9.100000381469727,  -7.330000400543213, -6.300000190734863);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz;
	TANGENT = vatOutputs.outTangent;
	
	UV = vatOutputs.surfaceUv;

	COLOR = vatOutputs.outColorAndAlpha;
}

void fragment() {
	//float threshold = 1.1;
//vec3 test =  UV.x > threshold? vec3( 0.0f,1000000.0f,0.0f) : vec3(0.0,0.0,0.0);

ALBEDO = COLOR.rgb;
	// Place fragment code here.
}
