#ifndef VAT3_STRUCTS
#define VAT3_STRUCTS

struct Vat3_NonTexInputs {
    bool autoPlayback;
	bool isTexHdr;
    float gameTimeAtFirstFrame;
    float displayFrame;
    float playbackSpeed;
    float HoudiniFPS;
	#ifndef NO_LERPING
    	bool interframeInterpolation;
	#endif
    float frameCount;
   	#if defined(VAT_LOAD_COL_TEX) ||  (defined(VAT3MODE_RIGIDBODY) && defined(VAT_SMOOTH_TRAJECTORIES)) && !defined(NO_LERPING)
        bool interpolateColor;
    #endif
    #if defined(VAT_LOAD_SPARE_COL_TEX) && !defined(NO_LERPING)
        bool interpolateSpareColor;
    #endif
	#ifndef NO_VAT_NORMAL
    	bool supportSurfaceNormalMaps;
	#endif
    vec3 boundMax;
    vec3 boundMin;
    float inputTime;
    vec3 additionalObjectSpaceOffset;

    #if defined(VAT3MODE_DYNAMICMESH)
        bool surfaceUVsfromColorRG;
		bool isLookuptexHdr;
    #elif defined(VAT3MODE_RIGIDBODY)
        bool stretchByVelocity;
        float stretchByVelocityAmount;
        bool animateFirstFrame;
    #elif defined(VAT3MODE_PARTICLES)
		mat4 modelViewMatrix;
		mat4 viewToModelMatrix;
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
    #if defined(VAT3MODE_RIGIDBODY) || defined(VAT3MODE_PARTICLES)
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
    #if defined(VAT_OUTPUT_FULL)
        float samplingVThisFrame;
		#ifndef NO_LERPING
        	float samplingVNextFrame;
		#endif
        float dataInPositionAlphaThisFrame;
		#ifndef NO_LERPING
        	float dataInPositionAlphaNextFrame;
		#endif
        #if defined(VAT_LOAD_COL_TEX)
            vec4 outColorRgbaThisFrame;
			#ifndef NO_LERPING
            	vec4 outColorRgbaNextFrame;
			#endif
        #endif
        #if defined(VAT_LOAD_SPARE_COL_TEX)
            vec4 outSpareColorRGBAThisFrame;
			#ifndef NO_LERPING
            	vec4 outSpareColorRGBANextFrame;
			#endif
        #endif
		#ifndef NO_LERPING
        	float outInterframeInterpolationAlpha;
		    float outAnimationProgressNextFrame;
		#endif
        float outAnimationProgressThisFrame;
    
        vec3 outPointLocalPositionThisFrame;
		#ifndef NO_LERPING
	        vec3 outPointLocalPositionNextFrame;
		#endif
        #if defined(VAT3MODE_RIGIDBODY)
            vec3 outPieceLocalPositionFinal;
            vec3 outPieceRestFrameLocalPosition;
        #endif
        #if defined(VAT3MODE_PARTICLES)
            vec3 outParticleLocalPositionFinal;
        #endif
    #endif
};

struct Vat3_Vertex_Input {
    vec3 vertexPosition;
    vec2 texCoord0;
    #if !defined(VAT3MODE_DYNAMICMESH) 
        vec2 texCoord1;
    #endif
    #if defined(VAT3MODE_RIGIDBODY)
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


#define defaultColor vec4(0.8f, 0.8f, 0.8f, 1.0f)
	#if defined(VAT3MODE_PARTICLES)
	float VatRandomFloat(vec2 seed)
	{
		return fract(sin(dot(seed, vec2(22.9898, 178.24313)))*12858.24161);
	}
	#endif
#endif /*VAT3_STRUCTS*/