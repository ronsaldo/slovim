Class {
	#name : #SLVMSampleImplicitLod,
	#superclass : #SLVMInstruction,
	#instVars : [
		'type'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #construction }
SLVMSampleImplicitLod class >> sampledTexture: sampledTexture texcoord: texcoord [
	^ self new sampledTexture: sampledTexture texcoord: texcoord
]

{ #category : #'as yet unclassified' }
SLVMSampleImplicitLod >> accept: aVisitor [
	^ aVisitor visitSampleImplicitLod: self
]

{ #category : #printing }
SLVMSampleImplicitLod >> mnemonic [
	^ #sampleImplicitLOD
]

{ #category : #accessing }
SLVMSampleImplicitLod >> sampledTexture [
	^ parameters first
]

{ #category : #construction }
SLVMSampleImplicitLod >> sampledTexture: sampledTexture texcoord: texcoord [
	| sampledTextureType |
	self parameters: { sampledTexture . texcoord }.
	sampledTextureType := sampledTexture type.
	self assert: sampledTextureType isSampledTextureType.
	type := SLVMVectorType baseType: sampledTextureType texture sampledType elements: 4
]

{ #category : #accessing }
SLVMSampleImplicitLod >> texcoord [
	^ parameters second
]

{ #category : #accessing }
SLVMSampleImplicitLod >> type [
	^ type
]
