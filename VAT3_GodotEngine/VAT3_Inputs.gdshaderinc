#ifndef VAT3_DEFAULT_HLSL
#define VAT3_DEFAULT_HLSL
	#define normalDefault vec3(0.0f, 1.0f, 0.0f)
	#define tangentDefault vec3(-1.0f, 0.0f, 0.0f)  
	uniform bool _isTexHdr;
	
	uniform vec3 _boundMax;
	uniform vec3 _boundMin;
	//uniform float _boundMaxX;
	//uniform float _boundMaxY;
	//uniform float _boundMaxZ;
			
	//uniform float _boundMinX;
	//uniform float _boundMinY;
	//uniform float _boundMinZ;
		
	uniform float _houdiniFPS; //
	
	 #if defined(_VAT3MODE_DYNAMICMESH)
        uniform bool _uvFromRG;
    #elif defined(_VAT3MODE_RIGIDBODY)
        uniform bool _stretchByVel;
        uniform float _stretchByVelAmount;
       	uniform bool _animateFirstFrame;
    #elif defined(_VAT3MODE_PARTICLES)
        uniform bool _spinFromHeading;
      	uniform float _originRadius;
        uniform bool _hideOverlappingOrigin;
        uniform float _scaleByVelAmount;
        uniform float _heightBaseScale;
		uniform float _widthBaseScale;
		uniform float _particleTexUScale;
		uniform float _particleTexVScale;
    #endif
    #if defined(_VAT3MODE_RIGIDBODY) || defined(_VAT3MODE_PARTICLES)
        	uniform bool _pscaleAreInPosA;
        	uniform float _globalPscaleMul;
    #endif

	uniform float _frameCount; 
	#if !defined(NO_VAT_TANGENT) && !defined(NO_VAT_NORMAL)
		uniform bool _surfaceNormals;
	#endif
	
	uniform bool _interpolate;
	uniform float _gameTimeAtFirstFrame;
	uniform float _playbackSpeed;
	uniform float _displayFrame;
	uniform bool _autoPlayback;
	
	#if defined(VAT_LOAD_COL_TEX) ||  (defined(_VAT3MODE_RIGIDBODY) && defined(VAT_SMOOTH_TRAJECTORIES))
		uniform bool _interpolateCol;
   		uniform sampler2D vatColTex : filter_nearest, repeat_disable;
   	#endif

	#if defined(VAT_LOAD_SPARE_COL_TEX)
		uniform bool _interpolateSpareCol;
        uniform sampler2D vatSpareColTex : filter_nearest, repeat_disable;
    #endif
	uniform sampler2D vatPosTex : hint_normal, filter_nearest,repeat_disable;
	#if defined(VAT_LOAD_POS_TWO_TEX)
		uniform sampler2D vatPos2Tex : filter_nearest, repeat_disable;
	#endif
	

	#if !defined(NO_VAT_NORMAL) && !defined(VAT_USE_COMPRESSED_NORMALS)
    	uniform sampler2D vatRotTex : filter_nearest, repeat_disable;
	#endif
	#if defined(_VAT3MODE_DYNAMICMESH) 
		uniform bool _lookupTexIsHdr;
		uniform sampler2D vatLookupTex : filter_nearest, repeat_disable;
	#endif

	void GetVatInputsFromMatProps(inout Vat3_NonTexInputs nonTexInputs)
	{
		nonTexInputs.autoPlayback = _autoPlayback;
		nonTexInputs.gameTimeAtFirstFrame = _gameTimeAtFirstFrame;
		#if defined(_VAT3MODE_DYNAMICMESH) 
			nonTexInputs.isLookuptexHdr = _lookupTexIsHdr;
		#endif
		
		nonTexInputs.playbackSpeed = _playbackSpeed;
		nonTexInputs.displayFrame = _displayFrame;

		nonTexInputs.HoudiniFPS = _houdiniFPS;
		nonTexInputs.frameCount = _frameCount;
		
		nonTexInputs.interframeInterpolation = _interpolate;
		#if defined(VAT_LOAD_COL_TEX)
	        nonTexInputs.interpolateColor = _interpolateCol;
	    #endif
	    #if defined(VAT_LOAD_SPARE_COL_TEX)
	        nonTexInputs.interpolateSpareColor = _interpolateSpareCol;
	    #endif

		#if defined(_VAT3MODE_DYNAMICMESH)
			nonTexInputs.surfaceUVsfromColorRG = _uvFromRG ;
		#elif defined(_VAT3MODE_RIGIDBODY)
			nonTexInputs.stretchByVelocity = _stretchByVel;
			nonTexInputs.stretchByVelocityAmount = _stretchByVelAmount;
			nonTexInputs.animateFirstFrame = _animateFirstFrame;
		#elif defined(_VAT3MODE_PARTICLES)
			nonTexInputs.computeSpinfromHeadingVector = _spinFromHeading;
			nonTexInputs.originEffectiveRadius = _originRadius;
			nonTexInputs.hideParticlesOverlappingObjectOrigin =_hideOverlappingOrigin;
			nonTexInputs.scalebyVelocityAmount = _scaleByVelAmount;
			nonTexInputs.particleHeightBaseScale = _heightBaseScale;
			nonTexInputs.particleWidthBaseScale = _widthBaseScale;
			nonTexInputs.particleTextureUScale = _particleTexUScale;
			nonTexInputs.particleTextureVScale = _particleTexVScale;
		#endif

		#if defined(_VAT3MODE_RIGIDBODY) || defined(_VAT3MODE_PARTICLES)
			nonTexInputs.particlesPiecesScaleAreInPositionAlpha = _pscaleAreInPosA;
			nonTexInputs.globalParticlePiecesPcaleMultiplier = _globalPscaleMul; // also piece
		#endif
		nonTexInputs.isTexHdr = _isTexHdr;
		nonTexInputs.autoPlayback = _autoPlayback;
		nonTexInputs.gameTimeAtFirstFrame = _gameTimeAtFirstFrame;
		
		nonTexInputs.playbackSpeed = _playbackSpeed;
		nonTexInputs.displayFrame = _displayFrame;

		nonTexInputs.HoudiniFPS = _houdiniFPS;
		nonTexInputs.frameCount = _frameCount;
		
		nonTexInputs.interframeInterpolation = _interpolate;
		#if defined(VAT_LOAD_COL_TEX)
        	nonTexInputs.interpolateColor = _interpolateCol;
    	#endif
	    #if defined(VAT_LOAD_SPARE_COL_TEX)
	        nonTexInputs.interpolateSpareColor = _interpolateSpareCol;
	    #endif
		
		#if !defined(NO_VAT_TANGENT) && !defined(NO_VAT_NORMAL)
			nonTexInputs.supportSurfaceNormalMaps = _surfaceNormals;
		#endif
		nonTexInputs.boundMax = _boundMax;
		nonTexInputs.boundMin = _boundMin;


		#if defined(_VAT3MODE_DYNAMICMESH)
			nonTexInputs.surfaceUVsfromColorRG = _uvFromRG;
		#elif defined(_VAT3MODE_RIGIDBODY)
			nonTexInputs.stretchByVelocity = _stretchByVel;
			nonTexInputs.stretchByVelocityAmount = _stretchByVelAmount;
			nonTexInputs.animateFirstFrame = _animateFirstFrame ;
		#elif defined(_VAT3MODE_PARTICLES)
			nonTexInputs.computeSpinfromHeadingVector = _spinFromHeading;
			nonTexInputs.originEffectiveRadius = _originRadius;
			nonTexInputs.hideParticlesOverlappingObjectOrigin =_hideOverlappingOrigin;
			nonTexInputs.scalebyVelocityAmount = _scaleByVelAmount;
			nonTexInputs.particleHeightBaseScale = _heightBaseScale;
			nonTexInputs.particleWidthBaseScale = _widthBaseScale;
			nonTexInputs.particleTextureUScale = _particleTexUScale;
			nonTexInputs.particleTextureVScale = _particleTexVScale;
		#endif

		#if defined(_VAT3MODE_RIGIDBODY) || defined(_VAT3MODE_PARTICLES)
			nonTexInputs.particlesPiecesScaleAreInPositionAlpha = _pscaleAreInPosA;
			nonTexInputs.globalParticlePiecesPcaleMultiplier = _globalPscaleMul; // also piece
		#endif

	}
	Vat3_NonTexInputs GetVat3DefualtInputs(Vat3_Vertex_Input vertInput)
	{
		Vat3_NonTexInputs defaultNonTexInputs;
		GetVatInputsFromMatProps(defaultNonTexInputs);
		defaultNonTexInputs.additionalObjectSpaceOffset = vec3(0.0f, 0.0f, 0.0f);
		defaultNonTexInputs.inputTime= TIME;
		#if defined(_VAT3MODE_PARTICLES)
			defaultNonTexInputs.particleSpinPhase = TIME;
			float VatRandomFloat = VatRandomFloat(vertInput.texCoord1);
			defaultNonTexInputs.perParticleRandomVelocityScale = VatRandomFloat * 0.5f + 1.0f;
			defaultNonTexInputs.perParticleRandomSpinSpeed = 1.0f;
			defaultNonTexInputs.additionalParticleScaleUniformMultiplier = VatRandomFloat + 1.0f;
		#endif
		return defaultNonTexInputs;
	}
	
	#if defined(_VAT3MODE_PARTICLES)
		mat4 transpModelView = transpose(MODEL_MATRIX * VIEW_MATRIX);
	#endif
#endif