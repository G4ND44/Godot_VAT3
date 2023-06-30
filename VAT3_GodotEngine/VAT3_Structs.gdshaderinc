#ifndef VAT3_STRUCTS
#define VAT3_STRUCTS

struct Vat3_NonTexInputs {
    bool autoPlayback;
	bool isTexHdr;
    float gameTimeAtFirstFrame;
    float displayFrame;
    float playbackSpeed;
    float HoudiniFPS;
    bool interframeInterpolation;
    float frameCount;
   	#if defined(VAT_LOAD_COL_TEX) ||  (defined(_VAT3MODE_RIGIDBODY) && defined(VAT_SMOOTH_TRAJECTORIES))
        bool interpolateColor;
    #endif
    #if defined(VAT_LOAD_SPARE_COL_TEX)
        bool interpolateSpareColor;
    #endif
	#ifndef NO_VAT_NORMAL
    	bool supportSurfaceNormalMaps;
	#endif
    vec3 boundMax;
    vec3 boundMin;
    float inputTime;
    vec3 additionalObjectSpaceOffset;

    #if defined(_VAT3MODE_DYNAMICMESH)
        bool surfaceUVsfromColorRG;
		bool isLookuptexHdr;
    #elif defined(_VAT3MODE_RIGIDBODY)
        bool stretchByVelocity;
        float stretchByVelocityAmount;
        bool animateFirstFrame;
    #elif defined(_VAT3MODE_PARTICLES)
		mat4 modelMatrix;
		mat4 viewMatrix;
		mat4 transposeModelViewMatrix;
        float particleSpinPhase;
        float perParticleRandomVelocityScale;
        float perParticleRandomSpinSpeed;
        bool computeSpinfromHeadingVector;
        float originEffectiveRadius;
        float additionalParticleScaleUniformMultiplier;
        bool hideParticlesOverlappingObjectOrigin;
        float scalebyVelocityAmount;
        float particleHeightBaseScale;
        float particleWidthBaseScale;
        float particleTextureUScale;
        float particleTextureVScale;
    #endif
    #if defined(_VAT3MODE_RIGIDBODY) || defined(_VAT3MODE_PARTICLES)
        bool particlesPiecesScaleAreInPositionAlpha;
        float globalParticlePiecesPcaleMultiplier;
    #endif
};
struct Vat3_Outputs {
    vec3 outPosition;
    #if !defined(NO_VAT_NORMAL)
        vec3 outNormal;
    #endif
    vec2 surfaceUv;
    #if !defined(NO_VAT_NORMAL) && !defined(NO_VAT_TANGENT)
        vec3 outTangent;
    #endif
    #if defined(VAT_LOAD_COL_TEX)
        vec4 outColorAndAlpha;
    #endif
    #if defined(VAT_LOAD_SPARE_COL_TEX)
        vec4 outSpareColorAndAlpha;
    #endif
    #if defined(_VAT_OUTPUT_FULL)
        float samplingVThisFrame;
        float samplingVNextFrame;
        float dataInPositionAlphaThisFrame;
        float dataInPositionAlphaNextFrame;
        #if defined(VAT_LOAD_COL_TEX)
            vec4 outColorRgbaThisFrame;
            vec4 outColorRgbaNextFrame;
        #endif
        #if defined(VAT_LOAD_SPARE_COL_TEX)
            vec4 outSpareColorRGBAThisFrame;
            vec4 outSpareColorRGBANextFrame;
        #endif

        float outInterframeInterpolationAlpha;
        float outAnimationProgressThisFrame;
        float outAnimationProgressNextFrame;
        vec3 outPointLocalPositionThisFrame;
        vec3 outPointLocalPositionNextFrame;
        #if defined(_VAT3MODE_RIGIDBODY)
            vec3 outPieceLocalPositionFinal;
            vec3 outPieceRestFrameLocalPosition;
        #endif
        #if defined(_VAT3MODE_PARTICLES)
            vec3 outParticleLocalPositionFinal;
        #endif
    #endif
};

struct Vat3_Vertex_Input {
    vec3 vertexPosition;
    vec2 texCoord0;
    #if !defined(_VAT3MODE_DYNAMICMESH) 
        vec2 texCoord1;
    #endif
    #if defined(_VAT3MODE_RIGIDBODY)
        vec2 texCoord2;
        vec2 texCoord3;
        #if !defined(NO_VAT_NORMAL)
            vec3 vertexNormal;
            #if !defined(NO_VAT_TANGENT) 
                vec3 vertexTangent;
            #endif
        #endif
    #endif
};


#define defaultColor vec4(0.8f, 0.8f, 0.8f, 1.0f);
float VatRandomFloat(vec2 seed)
{
	return fract(sin(dot(seed, vec2(12.9898, 78.233)))*43758.5453);
}
#endif
