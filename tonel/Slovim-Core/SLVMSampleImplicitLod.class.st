Class {
	#name : #SLVMSampleImplicitLod,
	#superclass : #SLVMSampleInstruction,
	#category : #'Slovim-Core-SSA'
}

{ #category : #printing }
SLVMSampleImplicitLod class >> mnemonic [
	^ #sampleImplicitLOD
]

{ #category : #construction }
SLVMSampleImplicitLod class >> sampledTexture: sampledTexture texcoord: texcoord [
	^ self new sampledTexture: sampledTexture texcoord: texcoord
]

{ #category : #'as yet unclassified' }
SLVMSampleImplicitLod >> accept: aVisitor [
	^ aVisitor visitSampleImplicitLod: self
]

{ #category : #construction }
SLVMSampleImplicitLod >> sampledTexture: sampledTexture texcoord: texcoord [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord }.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := SLVMVectorType baseType: sampledTextureType texture sampledType elements: 4
]
