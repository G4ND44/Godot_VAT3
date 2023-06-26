shader_type spatial;
render_mode  cull_disabled;
//#define NO_VAT_NORMAL
//#define NO_VAT_TANGENT
#define _VAT3MODE_RIGIDBODY



	
#include "res://VAT3_GodotEngine/VAT3_handler.gdshaderinc"

void vertex()
{

	Vat3_Vertex_Input vertInputs;
	vertInputs.vertexPosition = VERTEX.xyz;
	vertInputs.vertexNormal = NORMAL;
	vertInputs.vertexTangent = TANGENT;
		vec4 vertColors = COLOR;
	vertInputs.texCoord0 =vec2(vertColors.x, vertColors.y);
	vertInputs.texCoord1 = vec2(vertColors.z,vertColors.w);
	//vertInputs.texCoord2 = CUSTOM0.xy;

	vertInputs.texCoord2 = vec2(UV.x, UV.y  );
	vertInputs.texCoord3 = vec2(UV2.x, UV2.y);
	Vat3_NonTexInputs nonTexInputs = GetVat3DefualtInputs(vertInputs);
	Vat3_Outputs vatOutputs = ApplyVAT3_Deformation(vertInputs,nonTexInputs);
    VERTEX = vatOutputs.outPosition.xyz;
	//NORMAL = vatOutputs.outNormal.xyz;
	//TANGENT = vatOutputs.outTangent;

	//UV = UV2;
	//COLOR = vatOutputs.outColorAndAlpha.xyz;
}

void fragment() {
	//vec2 test = UV- vec2(0.0, 30.0);
	//ALBEDO = vec3(test.x, test.y ,0.0);
	// Place fragment code here.
}
