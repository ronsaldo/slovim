Class {
	#name : #SLVMSampleDepthImplicitLod,
	#superclass : #SLVMSampleInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSampleDepthImplicitLod class >> mnemonic [
	^ #sampleDepthImplicitLOD
]

{ #category : #construction }
SLVMSampleDepthImplicitLod class >> sampledTexture: sampledTexture texcoord: texcoord [
	^ self new sampledTexture: sampledTexture texcoord: texcoord
]

{ #category : #visiting }
SLVMSampleDepthImplicitLod >> accept: aVisitor [
	^ aVisitor visitSampleDepthImplicitLod: self
]

{ #category : #construction }
SLVMSampleDepthImplicitLod >> sampledTexture: sampledTexture texcoord: texcoord [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord }.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := sampledTextureType texture sampledType
]
