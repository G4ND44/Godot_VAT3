
#ifndef VAT3_HANDLER
#define VAT3_HANDLER
	#include "VAT3_Structs.gdshaderinc"
	#include "VAT3_Inputs.gdshaderinc"
	
	vec3 Interframe_Position(vec3 V, vec3 A, vec3 P, float T)
	{
		return  (V * T + 0.5 * A * T * T + P);
	}

	void DecodeRotationTextureNoTangent(vec4 rotTexData,out vec3 normals, vec3 normalDefaults)
	{
		vec3 crossNormal = cross(rotTexData.rgb, normalDefaults.xyz);
		vec3 normalLengMul = rotTexData.aaa * normalDefaults.xyz;
		vec3 normalToUnpack = cross(rotTexData.rgb,normalLengMul + crossNormal);
		normals = normalToUnpack * 2.0 + normalDefaults;

	}
	void DecodeRotationTexture(vec4 rotTexData,out vec3 normal, out vec3 tangent, vec3 normalDefaults, vec3 tangentDefaults)
	{
		vec3 crossNormal = cross(rotTexData.rgb, normalDefaults.xyz);
		vec3 normalLengMul = rotTexData.aaa * normalDefaults.xyz;
		vec3 normalToUnpack = cross(rotTexData.rgb,normalLengMul + crossNormal);
		normal = normalToUnpack * 2.0f + normalDefaults;

		vec3 crossTangent = cross(rotTexData.rgb, tangentDefaults.xyz);
		vec3 tangentLengMul = rotTexData.aaa * tangentDefaults.xyz;
		vec3 tangentToUnpack = cross(rotTexData.rgb,tangentLengMul + crossTangent);
		tangent = tangentToUnpack * 2.0f + tangentDefaults;
	}
        
    vec4 Decode_Quaterion(vec3 XYZ, int maxComponent)
    {
        float w = sqrt(1.0 - dot(XYZ,XYZ));
        vec4 q = vec4(0, 0, 0, 1);
		
        switch(maxComponent)
        {
            case 0:
                q = vec4(XYZ.x, XYZ.y, XYZ.z, w);
                break;
            case 1:
                q = vec4(w, XYZ.y, XYZ.z, XYZ.x);
                break;
            case 2:
                q = vec4(XYZ.x, w, XYZ.z, XYZ.y);
                break;
            case 3:
                q = vec4(XYZ.x, XYZ.y, w, XYZ.z);
                break;
            default:
                q = vec4(XYZ.x, XYZ.y, XYZ.z, w);
                break;
        }

        return q;
    }
	vec3 RotateVectorByQuaterion(vec3 vect, vec4 quat)
	{
		vec3 crossXYZ = cross(quat.xyz, vect.xyz);
		vec3 qautWvec = quat.www * vect.xyz;
		return cross(quat.xyz, crossXYZ + qautWvec) * 2.0f + vect.xyz;
	}
	vec4 MultiRPFQuaterionSlerp(float rpf, float interpolationAlpha,float rotTexAlpha, vec4 quaterionThisFrame, vec4 quaterionNextFrame)
	{
		float rpfCycle = fract(rpf) * 0.5;
		float rpfAlphaCycle = fract(rpf * interpolationAlpha) * 0.5;
		float sinRpfAlphaDif = sin((rpfCycle - rpfAlphaCycle) * TAU);
		float sinAlpha = sin(rpfAlphaCycle * TAU);
		float sinRpf= sin(rpfCycle * TAU);
		vec4 rpfQuaterionThisFrame = sinRpfAlphaDif * quaterionThisFrame;
		vec4 rpfQuaterionNextFrame = sinAlpha * quaterionNextFrame * sign(rotTexAlpha);
		vec4 lerpedQuaterion = (rpfQuaterionThisFrame + rpfQuaterionNextFrame)/sinRpf;
		return normalize(lerpedQuaterion);
	}
	vec3 RecoverCompressedNormal(float normalInAlpha)
	{
		float highRange = normalInAlpha * 1024.0;
		float lowRange = floor(normalInAlpha * 32.0);
		
		vec2 angleToUnpack = vec2(lowRange/31.5, (highRange - (lowRange * 32.0f))/31.5);
		vec2 unpackedAngle = angleToUnpack * 4.0f - vec2(2.0f, 2.0f);
		float dotSquare = dot(unpackedAngle,unpackedAngle);
		float dotSquareRemaped = sqrt(1.0f - (dotSquare*0.25f)); // instead of divide /4
		vec2 normalXZ = dotSquareRemaped * unpackedAngle;
		vec3 unclampedNormal = vec3(normalXZ.x, 1.0f - (dotSquare * 0.5f), normalXZ.y); // instead of /2
		return clamp(unclampedNormal, vec3(-1.0f, -1.0f,-1.0f), vec3(1.0f, 1.0f, 1.0f));
	}



	Vat3_Outputs ApplyVAT3_Deformation(in Vat3_Vertex_Input vertInput, in Vat3_NonTexInputs nonTexInputs)
	{
		
		// Decode Basic Data #START#
		vec3 boundMax = nonTexInputs.boundMax * 10.0f;
		vec3 boundMin  = nonTexInputs.boundMin * 10.0f;
		//float boundMaxMinusMin = boundMax - boundMin;
		vec3 inputBoundsRange =  nonTexInputs.boundMax -  nonTexInputs.boundMin;

		float activePixelsRatioX = 1.0f - (ceil(boundMin.z) - boundMin.z);
		float activePixelsRatioY = 1.0f - fract(boundMax.x * (-1.0f));

		bool isTexHdr = nonTexInputs.isTexHdr;
		float maxDataPscale = 1.0f / (1.0f - fract(boundMax.y));


		#if defined(_VAT3MODE_DYNAMICMESH) || defined(_VAT3MODE_RIGIDBODY)
			float reverseBoundXFract = fract(boundMin.x * (-1.0f));
		#endif
		// Decode Basic Data  #END#

		//Time calculations #START#
		float timeElapsed = nonTexInputs.inputTime - nonTexInputs.gameTimeAtFirstFrame;
		float animationProgress = (nonTexInputs.HoudiniFPS/(nonTexInputs.frameCount - 0.01f)) * timeElapsed;
		float loopedAnimFrame = fract(animationProgress * nonTexInputs.playbackSpeed) * nonTexInputs.frameCount;
		float currentFrame = nonTexInputs.autoPlayback ? loopedAnimFrame : nonTexInputs.displayFrame;
		float currentFramePlusOne = nonTexInputs.autoPlayback ? floor(loopedAnimFrame + 1.0f) : floor(nonTexInputs.displayFrame);
		float interpolationAlpha = fract(currentFrame);
		float frameCountInverse = (1.0f/ nonTexInputs.frameCount);
		float animProgressThisFrame = mod( currentFramePlusOne - 1.0f, nonTexInputs.frameCount) * frameCountInverse;
		float animProgressNextFrame = mod(currentFramePlusOne, nonTexInputs.frameCount) * frameCountInverse;
		// Time calculations  #END#

		// Frames UVs #START#
		#if defined(_VAT3MODE_DYNAMICMESH) 
			vec2 samplingInputUvs = vertInput.texCoord0;
		#else
			vec2 samplingInputUvs = vertInput.texCoord1;
		#endif
		float scaledU = (samplingInputUvs.x) * activePixelsRatioX;
		float scaledV = (samplingInputUvs.y) * activePixelsRatioY ;
		float samplingVThisFrame = scaledV + animProgressThisFrame * activePixelsRatioY;
		float samplingVNextFrame =  scaledV + animProgressNextFrame * activePixelsRatioY;
		vec2 relativeThisFrameUv = vec2(scaledU, samplingVThisFrame);
		vec2 relativeNextFrameUv= vec2(scaledU, samplingVNextFrame);

		#if defined(_VAT3MODE_DYNAMICMESH) 
			float lookupTableMaxRange = reverseBoundXFract > 0.5f ? 2048.0f : 255.0f;
			vec4 lookupTableThisFrame = textureLod( vatLookupTex,relativeThisFrameUv,0);
			vec4 lookupTableNextFrame = textureLod( vatLookupTex,relativeNextFrameUv.,0);
			vec2 dynameshThisFrameUv = vec2(lookupTableThisFrame.x + lookupTableThisFrame.y/lookupTableMaxRange, 1.0f - (lookupTableThisFrame.z + lookupTableThisFrame.w/lookupTableMaxRange));
			vec2 dynameshThisNextUv = vec2(lookupTableNextFrame.x + lookupTableNextFrame.y/lookupTableMaxRange, 1.0f - (lookupTableNextFrame.z + lookupTableNextFrame.w/lookupTableMaxRange));

			vec2 thisFrameUv = dynameshThisFrameUv;
			vec2 nextFrameUv = dynameshThisNextUv;
		#else
			vec2 thisFrameUv = relativeThisFrameUv;
			vec2 nextFrameUv = relativeNextFrameUv;
		#endif
		#if defined(_VAT3MODE_RIGIDBODY) 
			float animProgressLastFrame = mod(currentFramePlusOne -2.0f, nonTexInputs.frameCount) * frameCountInverse;
			float samplingLastFrame =  scaledV + animProgressLastFrame * activePixelsRatioY;
			vec2 lastFrameUV =  vec2(scaledU,  samplingLastFrame);
		#endif
		// Frames UVs  #END#

		// Sample Color Textures #START#
		// Base Color Tex
		#if defined(VAT_LOAD_COL_TEX) ||  (defined(_VAT3MODE_RIGIDBODY) && defined(VAT_SMOOTH_TRAJECTORIES))
			vec4 outColorRgbaThisFrame = textureLod( vatColTex, thisFrameUv,0);
			vec4 outColorRgbaNextFrame = textureLod( vatColTex, nextFrameUv,0);
			vec4 interpolatedColorAndAlpha;
			if(nonTexInputs.interframeInterpolation && nonTexInputs.interpolateColor)
			{
				interpolatedColorAndAlpha = mix(outColorRgbaThisFrame, outColorRgbaNextFrame, interpolationAlpha);
			}else
				interpolatedColorAndAlpha = outColorRgbaThisFrame;
		#else
			vec4 outColorRgbaThisFrame = defaultColor;
			vec4 outColorRgbaNextFrame = defaultColor;
			vec4 interpolatedColorAndAlpha = defaultColor;
		#endif
		// Spare Color Tex
		#ifdef VAT_LOAD_SPARE_COL_TEX
			vec4 spareColorRGBAThisFrame = textureLod( vatSpareColTex, thisFrameUv,0);
			vec4 spareColorRGBANextFrame = textureLod( vatSpareColTex, nextFrameUv,0 );
			vec4 spareColorRGBA;
			if(nonTexInputs.interframeInterpolation && nonTexInputs.interpolateSpareColor)
			{
				spareColorRGBA = mux(spareColorRGBAThisFrame, spareColorRGBANextFrame, interpolationAlpha);
			}else
				spareColorRGBA = defaultColor;
		#endif
		// Sample Color Textures #END#
		vec2 texSize = vec2(textureSize(vatPosTex,0));
		// This frame, next and lerped position #START#
		vec4 posTexThisFrame = textureLod( vatPosTex, thisFrameUv,0);
		vec4 posTexNextFrame = textureLod( vatPosTex, nextFrameUv,0);
		if(isTexHdr)
		{
			posTexThisFrame.xyz*= 0.01f;
			posTexNextFrame.xyz*= 0.01f;
		}
				//posTexThisFrame.r *=-1.0f; 
		//posTexNextFrame.rgb *=0.5; 
		//posTexThisFrame.rgb *= sqrt(posTexThisFrame.rgb);
		//posTexNextFrame.rgb *= sqrt(posTexNextFrame.rgb);
		float posAlphaThisFrame = posTexThisFrame.a;
		float posAlphaNextFrame = posTexNextFrame.a;
		#if defined(_VAT3MODE_RIGIDBODY)
			float posAlphaThisFrameMul4 = posAlphaThisFrame * 4.0f;
			float posAlphaNextFrameMul4 = posAlphaNextFrame * 4.0f;
		#endif
		vec3 thisFramePosSampleSum = posTexThisFrame.xyz;
		vec3 nextFramePosSampleSum = posTexNextFrame.xyz;
		#if defined(VAT_LOAD_POS_TWO_TEX)
			vec3 addPosTexThisFrame = textureLod( vatPos2Tex,thisFrameUv,0).xyz;
			vec3 addPosTexNextFrame = textureLod( vatPos2Tex, nextFrameUv,0 ).xyz;
			if(isTexHdr)
			{
				addPosTexThisFrame*=0.01;
				addPosTexNextFrame*=0.01;
			}
			thisFramePosSampleSum += addPosTexThisFrame;
			nextFramePosSampleSum += addPosTexNextFrame;
		#endif
				///thisFramePosSampleSum/=inputBoundsRange;
					//nextFramePosSampleSum/=inputBoundsRange;
					//	thisFramePosSampleSum*=10.0;
					//nextFramePosSampleSum*=10.0;
					
		if(!isTexHdr)
		{
			thisFramePosSampleSum*=inputBoundsRange;
			nextFramePosSampleSum*=inputBoundsRange;
			thisFramePosSampleSum += nonTexInputs.boundMin;
			nextFramePosSampleSum += nonTexInputs.boundMin;
			//nextFramePosSampleSum*=0.01;
		}
		vec3 thisFramePos = thisFramePosSampleSum;
		vec3 nextFramePos = nextFramePosSampleSum;
		vec3 lerpPos2Frames = mix(thisFramePos,nextFramePos, interpolationAlpha);
		vec3 lerpedPos = nonTexInputs.interframeInterpolation ? lerpPos2Frames : thisFramePos;
		// This frame, next and lerped position  #END#

		// pscale #START#
		#if defined(_VAT3MODE_RIGIDBODY) || defined(_VAT3MODE_PARTICLES) 
			#if defined(_VAT3MODE_PARTICLES)
				float clampedPscaleThisFrame = posAlphaThisFrame;
				float clampedPscaleNextFrame = posAlphaNextFrame;
			#else
				float clampedPscaleThisFrame = 1.0f - fract(posAlphaThisFrameMul4);
				float clampedPscaleNextFrame = 1.0f - fract(posAlphaNextFrameMul4);
			#endif
			float posAlphaInterpolated = mix(clampedPscaleThisFrame,clampedPscaleNextFrame,interpolationAlpha );
			#if defined(_VAT_OUTPUT_FULL)
				float pscaleThisFrame = clampedPscaleThisFrame * maxDataPscale;
				float pscaleNextFrame = clampedPscaleNextFrame * maxDataPscale;
				float originalPscale;
				if(nonTexInputs.interframeInterpolation)
					originalPscale = lerp(pscaleThisFrame,pscaleNextFrame,interpolationAlpha );
				else
					originalPscale = pscaleThisFrame;
			#else
				float originalPscale;
				if(nonTexInputs.interframeInterpolation)
					originalPscale = posAlphaInterpolated *maxDataPscale;
				else
					originalPscale = clampedPscaleThisFrame * maxDataPscale;

			#endif
		#endif
		// pscale #END#
		// Decode compressed normals #START#
		#if !defined(NO_VAT_NORMAL) || defined(_VAT3MODE_RIGIDBODY)
			#if (defined(_VAT3MODE_DYNAMICMESH) || defined(_VAT3MODE_SOFTBODY)) && defined(VAT_USE_COMPRESSED_NORMALS)
					vec3 recoverComprNormal;
					if(nonTexInputs.interframeInterpolation)
						recoverComprNormal = normalize(mix(RecoverCompressedNormal(posAlphaThisFrame), RecoverCompressedNormal(posAlphaNextFrame), interpolationAlpha)).xyz;
					else
						recoverComprNormal = normalize(RecoverCompressedNormal(posAlphaThisFrame));
				#else
					vec4 rotTexThisFrame = textureLod(vatRotTex,thisFrameUv,0);
					vec4 rotTexNextFrame =  textureLod(vatRotTex,nextFrameUv,0);
					if(!isTexHdr)
					{
						rotTexThisFrame -= vec4(0.5f, 0.5f, 0.5f, 0.5f);
						rotTexNextFrame -= vec4(0.5f, 0.5f, 0.5f, 0.5f);
						rotTexThisFrame *= 2.0f;
						rotTexNextFrame *= 2.0f;
					}else	
					{
						//rotTexThisFrame*=0.01;
						//rotTexNextFrame*=0.01;
					}
					vec4 rotThisFrameToDecode = rotTexThisFrame;
					vec4 rotNextFrameToDecode = rotTexNextFrame;
			#endif
		#endif


		// Decode compressed normals #END#

		// Sample Rotation Textures #START#
	
		// Sample Rotation Textures #END#


		#if defined(_VAT3MODE_RIGIDBODY)
			// Object Space Acceleration #START#
			#if defined(VAT_SMOOTH_TRAJECTORIES)
				vec3 objectSpaceAcceleration = vec3(outColorRgbaThisFrame.x * (-1.0f),outColorRgbaThisFrame.y, outColorRgbaThisFrame.z);
				if(isTexHdr)
					objectSpaceAcceleration*=0.01;
			#else
				vec3 objectSpaceAcceleration = vec3(0.0f, 0.0f, 0.0f);
			#endif
			// Object Space Acceleration #END#

			// Object Space Velocity #START#
			vec3 objectSpaceVelocity =nonTexInputs.stretchByVelocity ? vec3(interpolatedColorAndAlpha.r * (-1.0f), interpolatedColorAndAlpha.g, interpolatedColorAndAlpha.b) : vec3(0.0f, 0.0f, 0.0f);
			// Object Space Velocity #END#

			// Piece Pivot #START#
				vec3 pieceRestFrameLocalPosition = vec3(vertInput.texCoord2.x, vertInput.texCoord3.x, vertInput.texCoord3.y);
				vec3 pieceRelativePivot = vertInput.vertexPosition - pieceRestFrameLocalPosition;
			// Piece Pivot #END#

			// Quaterion #START#
				vec4 quaterionThisFrame = Decode_Quaterion(rotThisFrameToDecode.xyz, int(floor(posAlphaThisFrameMul4)));
				vec4 quaterionNextFrame = Decode_Quaterion(rotNextFrameToDecode.xyz, int(floor(posAlphaNextFrameMul4)));

				float rotThisFrameToDecodeAlphaAbs = abs(rotThisFrameToDecode.w);
				float rpf = isTexHdr ? rotThisFrameToDecodeAlphaAbs : (1.0f/(1.0f - reverseBoundXFract)) * rotThisFrameToDecodeAlphaAbs;

				vec4 slerpedQaterion = MultiRPFQuaterionSlerp(rpf,interpolationAlpha, rotThisFrameToDecode.w,quaterionThisFrame, quaterionNextFrame);
				vec4 lerpedQuaterion = rotThisFrameToDecode.w != 0.0f ? slerpedQaterion : quaterionThisFrame;
			// Quaterion #END#
		#endif

		#if defined(_VAT3MODE_PARTICLES)
			// Particle Velocity and Vector #START#
			#if defined(VAT_VIEWXY_SOURCE_COLOR_RGB)
				vec3 particlePosDelta = vec3(interpolatedColorAndAlpha.x * (-1.0f), interpolatedColorAndAlpha.y, interpolatedColorAndAlpha.z);
			#else
				vec3 particlePosDelta = nextFramePos - thisFramePos;
			#endif


			vec3 particleWorldPosDelta =  (MODEL_MATRIX * vec4(particlePosDelta.x, particlePosDelta.y, particlePosDelta.z, 0.0f)).xyz;
			vec3 particlesViewPosDelta =  (VIEW_MATRIX * vec4(particleWorldPosDelta.x, particleWorldPosDelta.y, particleWorldPosDelta.z, 0.0f)).xyz;
			vec2 posDeltaView2d = particlesViewPosDelta.xy;
			vec3 posDeltaView = vec3(posDeltaView2d.x, posDeltaView2d.y, 0.0f);
			vec3 particleViewSpaceVector = normalize(posDeltaView);
			float particleVelocity = length(particleVelocity);
			// Particle Velocity and Vector #END#

			// Particle Velocity Scale #START# ??
			#if defined(VAT_CAN_SPIN)
				float particleVelocityScale = nonTexInputs.computeSpinfromHeadingVector ? nonTexInputs.scalebyVelocityAmount * nonTexInputs.perParticleRandomVelocityScale * particleVelocity * nonTexInputs.particleHeightBaseScale : nonTexInputs.particleHeightBaseScale;
			#else
			//	float particleVelocityScale = nonTexInputs.particleHeightBaseScale;
			#endif
			// Particle Velocity Scale #END#
			 
			// Particle Local Pos #START#
			vec3 particleLocalPositionFinal;
			float particleEnabledThisFrame = saturate(sign(length(thisFramePos) - nonTexInputs.originEffectiveRadius));
			float particleEnabledNextFrame = saturate(sign(length(nextFramePos) - nonTexInputs.originEffectiveRadius));

			// theres should be another co if particles are looped then lerped pos should be diffrent
			if(!nonTexInputs.particlesPiecesScaleAreInPositionAlpha)
			{
				vec3 lepredParticlePos = particleEnabledNextFrame > 0.0f ? lerpedPos : thisFramePos;
				particleLocalPositionFinal = particleEnabledThisFrame > 0.0f ? lepredParticlePos : nextFramePos; 
			}else
				particleLocalPositionFinal = lerpedPos;
			// Particle Local Pos #END#

			// Particle Scale #START#
			float particleScaleMultiplier = nonTexInputs.globalParticlePiecesPcaleMultiplier * nonTexInputs.additionalParticleScaleUniformMultiplier;
			float particleScale;
			if(nonTexInputs.particlesPiecesScaleAreInPositionAlpha)
			{
				float pscaleParticle = originalPscale * particleScaleMultiplier;
				particleScale= nonTexInputs.hideParticlesOverlappingObjectOrigin ? pscaleParticle * particleEnabledThisFrame : pscaleParticle;
			}else
			{
				if(nonTexInputs.hideParticlesOverlappingObjectOrigin)
				{
					if(nonTexInputs.interframeInterpolation)
					{
						particleScale = mix(particleEnabledThisFrame * particleScaleMultiplier, particleEnabledNextFrame * particleScaleMultiplier, interpolationAlpha); // maybe just * particleScale
					}else
					{
						particleScale = particleEnabledThisFrame * particleScaleMultiplier;
					}
				}else
					particleScale = particleScaleMultiplier;
			}
			// Particle Scale #END#

			// Particle Up and Right #START#
			#if defined(VAT_CAN_SPIN)
				vec3 viewRightVector;
				if(nonTexInputs.computeSpinfromHeadingVector)
				{
					viewRightVector = normalize(cross(particleViewSpaceVector, vec3(0.0f, 0.0f, 1.0f))); 
				}else
				{
					#if defined(VAT_SPIN_SOURCE_POS_ALPHA)
						float particleSpin =  fract(posAlphaInterpolated * nonTexInputs.perParticleRandomSpinSpeed) * TAU;
					#else
						float particleSpin = fract(nonTexInputs.particleSpinPhase * nonTexInputs.perParticleRandomSpinSpeed) * TAU;
					#endif
					viewRightVector = vec3(cos(particleSpin), sin(particleSpin), 0.0f);
				}
				vec3 particleRightDir = ( transpModelView * vec4(viewRightVector.x, viewRightVector.y, viewRightVector.z, 0.0f) ).xyz; // view to object
				vec3 particleUpDirView = cross(viewRightVector,vec3(0.0f, 0.0f, -1.0f));
				vec3 particleUpDir = ( transpModelView * vec4(particleUpDirView.x, particleUpDirView.y, particleUpDirView.z, 0.0f)).xyz;
			#else
				vec3 particleRightDir = ( transpModelView * vec4(1.0f, 0.0f, 0.0f,0.0f)).xyz;
				vec3 particleUpDir = ( transpModelView * vec4(0.0f, 1.0f, 0.0f,0.0f)).xyz;
			#endif
			// Particle Up and Right #END#

			//Particle Final Pos 
			vec3 particleRelRightPos = particleRightDir * nonTexInputs.particleWidthBaseScale * particleScale * (vertInput.texCoord0.x - 0.5f);
			vec3 particleRelUpPos= particleUpDir  * (vertInput.texCoord0.y - 0.5f) * particleVelocityScale * particleScale;
			vec3 particleFinalPos = particleRelRightPos + particleRelUpPos + particleLocalPositionFinal;
			
			//

		#endif
			
		#if defined(_VAT3MODE_RIGIDBODY)
			//Rigidbody pos offset #START#
			#if defined(VAT_SMOOTH_TRAJECTORIES)
				vec4 posTexLastFrame =  textureLod( vatPosTex,lastFrameUV,0);
				if(isTexHdr)
					posTexLastFrame*=0.01;
				vec3 lastFramePosSampleSum = posTexLastFrame.xyz;
				#if defined(VAT_LOAD_POS_TWO_TEX)
					vec4 addPosTexLastFrame = textureLod( vatPos2Tex, lastFrameUV, 0 );
					lastFramePosSampleSum= addPosTexLastFrame.xyz;
				#endif
				vec3 lastFramePosition = isTexHdr ? lastFramePosSampleSum : (lastFramePosSampleSum * inputBoundsRange + nonTexInputs.boundMin);
			
				vec3 centralDifferenceVelocity = (nextFramePos - lastFramePosition) * 0.5f * nonTexInputs.HoudiniFPS;
				vec3 interFramePos = Interframe_Position(centralDifferenceVelocity, objectSpaceAcceleration,thisFramePos, interpolationAlpha/ nonTexInputs.HoudiniFPS);
				float framePlusOneFmod = mod( floor(currentFramePlusOne), nonTexInputs.frameCount);
				float interframeCompare = clamp(abs(framePlusOneFmod -1.0f),0.0, 1.0) * clamp(abs(framePlusOneFmod - nonTexInputs.frameCount),0.0, 1.0);
				vec3 interFramePosClamped = (interframeCompare > 0.0f ? interFramePos : lerpPos2Frames);
				vec3 pieceLocalPositionFinal = nonTexInputs.interframeInterpolation ? interFramePosClamped : thisFramePos;
			#else
				vec3 pieceLocalPositionFinal = nonTexInputs.interframeInterpolation ? lerpPos2Frames : thisFramePos;
			#endif
			pieceLocalPositionFinal*=100.0;
			float finalPscale = nonTexInputs.particlesPiecesScaleAreInPositionAlpha ? originalPscale : 1.0f;
			
			vec3 pieceVectorWithScale = RotateVectorByQuaterion(pieceRelativePivot, lerpedQuaterion) * ((abs(objectSpaceVelocity) * nonTexInputs.stretchByVelocityAmount + vec3(1.0f, 1.0f, 1.0f))*nonTexInputs.globalParticlePiecesPcaleMultiplier * finalPscale); 
			vec3 pieceVertexPositon = pieceVectorWithScale + pieceLocalPositionFinal;
			vec3 piecePos = mod(currentFramePlusOne, nonTexInputs.frameCount) != 1.0f ? pieceVertexPositon : vertInput.vertexPosition;
			vec3 rigidbodyPos = nonTexInputs.animateFirstFrame ? pieceVertexPositon : piecePos;

			vec3 rigidBodyPosPlusOffset = rigidbodyPos+ nonTexInputs.additionalObjectSpaceOffset;
			//vec3 rigidBodyPosPlusOffset = vertInput.vertexPosition - pieceRestFrameLocalPosition;
			//Rigidbody pos offse #END#
		#endif

		// out Pos #START#
		#if defined(_VAT3MODE_RIGIDBODY)
			vec3 vertexObjectPos = rigidBodyPosPlusOffset;

		#else
			#if defined(_VAT3MODE_SOFTBODY)
				vec3 offset = vertInput.vertexPosition + nonTexInputs.additionalObjectSpaceOffset;
				vec3 relPos = lerpedPos;
			#else
				vec3 offset =  nonTexInputs.additionalObjectSpaceOffset;
				#if defined(_VAT3MODE_PARTICLES)
					vec3 relPos = particleFinalPos;
				#else // then it is dynamic mesh
					vec3 relPos = thisFramePos;
				#endif
			#endif
			//if(isTexHdr)
			//	relPos *= 0.01f;

			vec3 vertexObjectPos = relPos + offset;
		#endif
		vec3 outPosition = samplingInputUvs.y >= 0.9f ? vec3(0.0f, 0.0f, 0.0f) : vertexObjectPos;
		// out Pos #END#

		#if !defined(NO_VAT_NORMAL)
			// out Normal And Tagent #START#
			vec3 outNormal;
			#if !defined(NO_VAT_TANGENT)
				vec3 outTangent;
			#endif
			#if defined(_VAT3MODE_RIGIDBODY)
				#if !defined(NO_VAT_TANGENT)
					DecodeRotationTexture(lerpedQuaterion,outNormal,outTangent,vertInput.vertexNormal, vertInput.vertexTangent); 
				#else
					DecodeRotationTextureNoTangent(lerpedQuaterion,outNormal,vertInput.vertexNormal); 
				#endif
				outNormal = normalize(outNormal); 
				#if !defined(NO_VAT_TANGENT)
					outTangent = nonTexInputs.supportSurfaceNormalMaps ? normalize(outTangent) : vec3(0.0f, 0.0f, 0.0f);
				#endif

			#else
				#if defined(_VAT3MODE_SOFTBODY) || defined(_VAT3MODE_DYNAMICMESH)
					#if !defined(VAT_USE_COMPRESSED_NORMALS)
						vec3 decodedNormalThisFrame;

						#if !defined(NO_VAT_TANGENT)
							vec3 decodedTangentThisFrame;
							DecodeRotationTexture(rotThisFrameToDecode,decodedNormalThisFrame,decodedTangentThisFrame,normalDefault,tangentDefault);
						#else
							DecodeRotationTextureNoTangent(rotThisFrameToDecode,decodedNormalThisFrame,normalDefault);
						#endif
						#if defined(_VAT3MODE_SOFTBODY)
							if(nonTexInputs.interframeInterpolation)
							{
								vec3 decodedNormalNextFrame;
								#if !defined(NO_VAT_TANGENT)
									vec3 decodedTangentNextFrame;
									DecodeRotationTexture(rotNextFrameToDecode,decodedNormalNextFrame,decodedTangentNextFrame,normalDefault,tangentDefault);
									outNormal = mix(decodedNormalThisFrame,decodedNormalNextFrame, interpolationAlpha);
									outTangent = mix(decodedTangentThisFrame,decodedTangentNextFrame, interpolationAlpha);
								#else
									DecodeRotationTextureNoTangent(rotNextFrameToDecode,decodedNormalNextFrame,normalDefault);
									outNormal = mix(decodedNormalThisFrame,decodedNormalNextFrame, interpolationAlpha);
								#endif
							}else
							{
								outNormal = decodedNormalThisFrame;
								#if !defined(NO_VAT_TANGENT)
									outTangent = decodedTangentThisFrame;
								#endif
							}
							outNormal = normalize(outNormal);
							#if !defined(NO_VAT_TANGENT)
								outTangent = nonTexInputs.supportSurfaceNormalMaps ? normalize(outTangent)  :  vec3(0.0f, 0.0f, 0.0f);
							#endif
						#else
							outNormal = normalize(decodedNormalThisFrame);
							#if !defined(NO_VAT_TANGENT)
								outTangent =  nonTexInputs.supportSurfaceNormalMaps ? normalize(decodedTangentThisFrame) :  vec3(0.0f, 0.0f, 0.0f);
							#endif
						#endif
					
					#else
						outNormal = recoverComprNormal;
						#if !defined(NO_VAT_TANGENT)
							outTangent = vec3(0.0f, 0.0f, 0.0f); // not valid
						#endif
					#endif
				#elif defined(_VAT3MODE_PARTICLES)// particles
					#if !defined(NO_VAT_NORMAL)
						outNormal = normalize( ( transpModelView * vec4(0.0f, 0.0f, 1.0f,0.0f) ).xyz);
						#if !defined(NO_VAT_TANGENT)
							outTangent = nonTexInputs.supportSurfaceNormalMaps ? particleRightDir :  vec3(0.0f, 0.0f, 0.0f); 
						#endif
					#endif
				#else // not valid but to make sure no cimpiling error
					#if !defined(NO_VAT_NORMAL)
						outNormal = vec3(0.0f, 0.0f, 0.0f); 
						#if !defined(NO_VAT_TANGENT)
							outTangent = vec3(0.0f, 0.0f, 0.0f); 
						#endif
					#endif
				#endif

				// outputs 

			#endif
		#endif

		// out SurfaceUV #START#
		#if defined(_VAT3MODE_PARTICLES)
			vec2 particleUvScale= vec2( nonTexInputs.particleTextureUScale, nonTexInputs.particleTextureVScale );
			vec2 particleUvScaleRemaped = particleUvScale * (-0.5f) + vec2(0.5f, 0.5f);
			vec2 surfaceUv = particleUvScaleRemaped + vertInput.texCoord0 * particleUvScale;
		#elif defined(_VAT3MODE_DYNAMICMESH)
			vec2 surfaceUv;
			if(nonTexInputs.surfaceUVsfromColorRG)
			{
				surfaceUv = vec2(interpolatedColorAndAlpha.r, 1.0f - interpolatedColorAndAlpha.g);
			}else
			{
				surfaceUv = vec2(posAlphaThisFrame, 1.0f - interpolatedColorAndAlpha.a); 
			}
		#else
			vec2 surfaceUv =  vertInput.texCoord0;
		#endif
		// out SurfaceUV #END#
		Vat3_Outputs vertOutputs;
		//ZERO_INITIALIZE(Vat3_Outputs, vertOutputs);
		vertOutputs.outPosition = outPosition;
		#if !defined(NO_VAT_NORMAL)
			vertOutputs.outNormal = outNormal;
			#if !defined(NO_VAT_TANGENT)
				vertOutputs.outTangent = outTangent;
			#endif
		#endif
		vertOutputs.surfaceUv = surfaceUv;
		#if defined(VAT_LOAD_COL_TEX)
			vertOutputs.outColorAndAlpha = interpolatedColorAndAlpha;
		#endif
		#if defined(VAT_LOAD_SPARE_COL_TEX)
			vertOutputs.outSpareColorAndAlpha = spareColorRGBA;
		#endif
        #if defined(_VAT_OUTPUT_FULL)
			vertOutputs.samplingVThisFrame = samplingVThisFrame;
			vertOutputs.samplingVNextFrame = samplingVNextFrame;
			#if defined(_VAT3MODE_RIGIDBODY)
				vertOutputs.dataInPositionAlphaThisFrame = pscaleThisFrame;
				vertOutputs.dataInPositionAlphaNextFrame = pscaleNextFrame;
			#else
				float dataInPositionAlphaThisFrame = posAlphaThisFrame * maxDataPscale;
				float dataInPositionAlphaNextFrame = posAlphaNextFrame * maxDataPscale; 
				vertOutputs.dataInPositionAlphaThisFrame = dataInPositionAlphaThisFrame;
				vertOutputs.dataInPositionAlphaNextFrame = dataInPositionAlphaNextFrame;
			#endif

			#if defined(VAT_LOAD_COL_TEX)
				vertOutputs.outColorRgbaThisFrame = outColorRgbaThisFrame;
				vertOutputs.outColorRgbaNextFrame = outColorRgbaNextFrame;
			#endif
			#if defined(VAT_LOAD_SPARE_COL_TEX)
				vertOutputs.outSpareColorRGBAThisFrame = spareColorRGBAThisFrame; 
				vertOutputs.outSpareColorRGBANextFrame = spareColorRGBANextFrame;
			#endif
			vertOutputs.outInterframeInterpolationAlpha = interpolationAlpha;
			vertOutputs.outAnimationProgressThisFrame = animProgressThisFrame;
			vertOutputs.outAnimationProgressNextFrame = animProgressNextFrame;
			vertOutputs.outPointLocalPositionThisFrame = thisFramePos;
			vertOutputs.outPointLocalPositionNextFrame = nextFramePos;
			#if defined(_VAT3MODE_SOFTBODY)
				vertOutputs.outPointLocalPositionThisFrame += vertInput.vertexPosition;
				vertOutputs.outPointLocalPositionNextFrame += vertInput.vertexPosition;
			#endif
			#if defined(_VAT3MODE_RIGIDBODY)
				vertOutputs.outPieceLocalPositionFinal = pieceLocalPositionFinal;
				vertOutputs.outPieceRestFrameLocalPosition = pieceRestFrameLocalPosition;
			#endif
			#if defined(_VAT3MODE_PARTICLES)
				vertOutputs.outParticleLocalPositionFinal = particleLocalPositionFinal;
			#endif
		#endif

		return vertOutputs;
	}
#endif