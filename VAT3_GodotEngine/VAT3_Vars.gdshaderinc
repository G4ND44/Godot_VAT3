#ifndef VAT3_DEFAULT_GLSL
#define VAT3_DEFAULT_GLSL
	#include "VAT3_Structs.gdshaderinc"
	#define normalDefault vec3(0.0f, 1.0f, 0.0f)
	#define tangentDefault vec3(-1.0f, 0.0f, 0.0f)  
	uniform bool _isTexHdr;
	
	uniform vec3 _boundMax;
	uniform vec3 _boundMin;

	uniform float _houdiniFPS; //
	
	 #if defined(VAT3MODE_DYNAMICMESH)
        uniform bool _uvFromRG;
    #elif defined(VAT3MODE_RIGIDBODY)
        uniform bool _stretchByVel;
        uniform float _stretchByVelAmount;
       	uniform bool _animateFirstFrame;
    #elif defined(VAT3MODE_PARTICLES)
        uniform bool _spinFromHeading;
      	uniform float _originRadius;
        uniform bool _hideOverlappingOrigin;
        uniform float _scaleByVelAmount;
        uniform float _heightBaseScale;
		uniform float _widthBaseScale;
		uniform float _particleTexUScale;
		uniform float _particleTexVScale;
    #endif
    #if defined(VAT3MODE_RIGIDBODY) || defined(VAT3MODE_PARTICLES)
        	uniform bool _pscaleAreInPosA;
        	uniform float _globalPscaleMul;
    #endif

	uniform float _frameCount; 
	#if !defined(NO_VAT_TANGENT) && !defined(NO_VAT_NORMAL)
		uniform bool _surfaceNormals;
	#endif
	#ifndef NO_LERPING
		uniform bool _interpolate;
	#endif
	uniform float _gameTimeAtFirstFrame;
	uniform float _playbackSpeed;
	uniform float _displayFrame;
	uniform bool _autoPlayback;
	
	#if defined(VAT_LOAD_COL_TEX) ||  ((defined(VAT3MODE_RIGIDBODY) && defined(VAT_SMOOTH_TRAJECTORIES))) 
		#if !defined(NO_LERPING) && defined(VAT_LOAD_COL_TEX)
			uniform bool _interpolateCol;
		#endif
   		uniform sampler2D vatColTex : filter_nearest, repeat_disable;
   	#endif

	#if defined(VAT_LOAD_SPARE_COL_TEX)
		#ifndef NO_LERPING
			uniform bool _interpolateSpareCol;
		#endif
        uniform sampler2D vatSpareColTex : filter_nearest, repeat_disable;
    #endif
	uniform sampler2D vatPosTex : hint_normal, filter_nearest,repeat_disable;
	#if defined(VAT_LOAD_POS_TWO_TEX)
		uniform sampler2D vatPos2Tex : filter_nearest, repeat_disable;
	#endif
	

	#if !defined(NO_VAT_NORMAL) && !defined(VAT_USE_COMPRESSED_NORMALS) && !defined(VAT3MODE_PARTICLES) || defined(VAT3MODE_RIGIDBODY)
    	uniform sampler2D vatRotTex : filter_nearest, repeat_disable;
	#endif
	#if defined(VAT3MODE_DYNAMICMESH) 
		uniform bool _lookupTexIsHdr;
		uniform sampler2D vatLookupTex : filter_nearest, repeat_disable;
	#endif

	void GetVatInputsFromMatProps(inout Vat3_NonTexInputs nonTexInputs)
	{
		nonTexInputs.autoPlayback = _autoPlayback;
		nonTexInputs.gameTimeAtFirstFrame = _gameTimeAtFirstFrame;
		#if defined(VAT3MODE_DYNAMICMESH) 
			nonTexInputs.isLookuptexHdr = _lookupTexIsHdr;
		#endif
		
		nonTexInputs.playbackSpeed = _playbackSpeed;
		nonTexInputs.displayFrame = _displayFrame;

		nonTexInputs.HoudiniFPS = _houdiniFPS;
		nonTexInputs.frameCount = _frameCount;
		#ifndef NO_LERPING
			nonTexInputs.interframeInterpolation = _interpolate;
		#endif
		#if defined(VAT_LOAD_COL_TEX) && !defined(NO_LERPING)
	        nonTexInputs.interpolateColor = _interpolateCol;
	    #endif
	    #if defined(VAT_LOAD_SPARE_COL_TEX) && !defined(NO_LERPING)
	        nonTexInputs.interpolateSpareColor = _interpolateSpareCol;
	    #endif

		#if defined(VAT3MODE_DYNAMICMESH)
			nonTexInputs.surfaceUVsfromColorRG = _uvFromRG ;
		#elif defined(VAT3MODE_RIGIDBODY)
			nonTexInputs.stretchByVelocity = _stretchByVel;
			nonTexInputs.stretchByVelocityAmount = _stretchByVelAmount;
			nonTexInputs.animateFirstFrame = _animateFirstFrame;
		#elif defined(VAT3MODE_PARTICLES)
			nonTexInputs.computeSpinfromHeadingVector = _spinFromHeading;
			nonTexInputs.originEffectiveRadius = _originRadius;
			nonTexInputs.hideParticlesOverlappingObjectOrigin =_hideOverlappingOrigin;
			nonTexInputs.scalebyVelocityAmount = _scaleByVelAmount;
			nonTexInputs.particleHeightBaseScale = _heightBaseScale;
			nonTexInputs.particleWidthBaseScale = _widthBaseScale;
			nonTexInputs.particleTextureUScale = _particleTexUScale;
			nonTexInputs.particleTextureVScale = _particleTexVScale;
		#endif

		#if defined(VAT3MODE_RIGIDBODY) || defined(VAT3MODE_PARTICLES)
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
		#ifndef NO_LERPING
			nonTexInputs.interframeInterpolation = _interpolate;
		#endif
		#if defined(VAT_LOAD_COL_TEX)  && !defined(NO_LERPING)
        	nonTexInputs.interpolateColor = _interpolateCol;
    	#endif
	    #if defined(VAT_LOAD_SPARE_COL_TEX)  && !defined(NO_LERPING)
	        nonTexInputs.interpolateSpareColor = _interpolateSpareCol;
	    #endif
		
		#if !defined(NO_VAT_TANGENT) && !defined(NO_VAT_NORMAL)
			nonTexInputs.supportSurfaceNormalMaps = _surfaceNormals;
		#endif
		nonTexInputs.boundMax = _boundMax;
		nonTexInputs.boundMin = _boundMin;


		#if defined(VAT3MODE_DYNAMICMESH)
			nonTexInputs.surfaceUVsfromColorRG = _uvFromRG;
		#elif defined(VAT3MODE_RIGIDBODY)
			nonTexInputs.stretchByVelocity = _stretchByVel;
			nonTexInputs.stretchByVelocityAmount = _stretchByVelAmount;
			nonTexInputs.animateFirstFrame = _animateFirstFrame;
		#elif defined(VAT3MODE_PARTICLES)
			nonTexInputs.computeSpinfromHeadingVector = _spinFromHeading;
			nonTexInputs.originEffectiveRadius = _originRadius;
			nonTexInputs.hideParticlesOverlappingObjectOrigin = _hideOverlappingOrigin;
			nonTexInputs.scalebyVelocityAmount = _scaleByVelAmount;
			nonTexInputs.particleHeightBaseScale = _heightBaseScale;
			nonTexInputs.particleWidthBaseScale = _widthBaseScale;
			nonTexInputs.particleTextureUScale = _particleTexUScale;
			nonTexInputs.particleTextureVScale = _particleTexVScale;
		#endif

		#if defined(VAT3MODE_RIGIDBODY) || defined(VAT3MODE_PARTICLES)
			nonTexInputs.particlesPiecesScaleAreInPositionAlpha = _pscaleAreInPosA;
			nonTexInputs.globalParticlePiecesPcaleMultiplier = _globalPscaleMul; // also piece
		#endif

	}
	Vat3_NonTexInputs GetVat3Inputs(Vat3_Vertex_Input vertInput)
	{
		Vat3_NonTexInputs defaultNonTexInputs;
		GetVatInputsFromMatProps(defaultNonTexInputs);
		defaultNonTexInputs.additionalObjectSpaceOffset = vec3(0.0f, 0.0f, 0.0f);
		defaultNonTexInputs.inputTime = TIME;
		#if defined(VAT3MODE_PARTICLES)
			defaultNonTexInputs.particleSpinPhase = TIME;
			float VatRandomFloat = VatRandomFloat(vertInput.texCoord1);
			defaultNonTexInputs.perParticleRandomVelocityScale = VatRandomFloat * 0.5f + 1.0f;
			defaultNonTexInputs.perParticleRandomSpinSpeed = 1.0f;
			defaultNonTexInputs.additionalParticleScaleUniformMultiplier = VatRandomFloat + 1.0f;
		#endif
		return defaultNonTexInputs;
	}
	
#endif /*VAT3_DEFAULT_GLSL*/
