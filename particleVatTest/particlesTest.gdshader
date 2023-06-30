shader_type spatial;
//render_mode  cull_disabled;
render_mode unshaded;
//#define NO_VAT_NORMAL
#define NO_VAT_TANGENT
#define _VAT3MODE_PARTICLES
#define VAT_LOAD_COL_TEX
#define VAT_CAN_SPIN




	
#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;

	vertInputs.texCoord0 =UV;
	vertInputs.texCoord1 = UV2;

	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	nonTexInputs.modelMatrix = MODEL_MATRIX;
	nonTexInputs.viewMatrix = VIEW_MATRIX;
	nonTexInputs.transposeModelViewMatrix = transpose(MODEL_MATRIX * VIEW_MATRIX);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz;
	//TANGENT = vatOutputs.outTangent;
	COLOR = vatOutputs.outColorAndAlpha;
}

void fragment() {
//vec2 test = UV;
	ALBEDO = COLOR.xyz;
	ALPHA = COLOR.w;
	// Place fragment code here.
}
