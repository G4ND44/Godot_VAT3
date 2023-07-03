shader_type spatial;
render_mode  cull_back;
//render_mode unshaded;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT

#define VAT3MODE_PARTICLES
#define VAT_LOAD_COL_TEX
#define VAT_CAN_SPIN
#define VAT_OUTPUT_FULL
uniform sampler2D normalmap : hint_normal;




	
#include "res://VAT3_GodotEngine/VAT3_Wraper.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;

	vertInputs.texCoord0 =vec2(UV.x,  UV.y);
	vertInputs.texCoord1 = UV2;

	Vat3_NonTexInputs nonTexInputs = GetVat3Inputs(vertInputs);
	nonTexInputs.modelViewMatrix = MODELVIEW_MATRIX;
	nonTexInputs.viewToModelMatrix =  inverse(MODELVIEW_MATRIX);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	NORMAL = vatOutputs.outNormal.xyz;
	TANGENT = vatOutputs.outTangent;
	BINORMAL = cross(TANGENT,NORMAL);
	COLOR = vatOutputs.outColorAndAlpha;
	//COLOR.xyz = NORMAL;
}

void fragment() {
//vec2 test = UV;
	NORMAL_MAP = texture(normalmap, UV).rgb;
	ALBEDO = (COLOR.xyx);
	ALPHA = COLOR.w;
	// Place fragment code here.
}
