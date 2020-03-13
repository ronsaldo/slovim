Class {
	#name : #SLVMSampleDepthRefImplicitLod,
	#superclass : #SLVMSampleInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSampleDepthRefImplicitLod class >> mnemonic [
	^ #sampleDepthRefImplicitLOD
]

{ #category : #'as yet unclassified' }
SLVMSampleDepthRefImplicitLod class >> sampledTexture: sampledTexture texcoord: texcoord depthReference: depthReference [
	^ self new sampledTexture: sampledTexture texcoord: texcoord depthReference: depthReference
]

{ #category : #printing }
SLVMSampleDepthRefImplicitLod >> accept: aVisitor [
	^ aVisitor visitSampleDepthRefImplicitLod: self
]

{ #category : #'as yet unclassified' }
SLVMSampleDepthRefImplicitLod >> depthReference [
	^ parameters third
]

{ #category : #'as yet unclassified' }
SLVMSampleDepthRefImplicitLod >> sampledTexture: sampledTexture texcoord: texcoord depthReference: depthReference [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord . depthReference}.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := sampledTextureType texture sampledType
]
